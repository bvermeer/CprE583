/*
 *            REGISTERS
 *          ,---,---,---,---,---,---,---,---,---,---,---,---,---,---,---,---, 
 *          | f | e | d | c | b | a | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
 *          +---'---'---'---+---'---'---'---+---'---'---'---'---'---'---'---+
 *   0x0    |       0       |   mm_e[3:0]   |         mm_addr_in[7:0]       |
 *          +---------------'---------------'-------------------------------+
 *   0x2    |                           mm_a[15:0]                          |
 *          +---------------------------------------------------------------+
 *   0x4    |                           mm_b[15:0]                          |
 *          +---------------------------------------------------------------+
 *   0x6    |                           mm_m[15:0]                          |
 *          +-------------------------------,-------------------------------+
 *   0x8    |          mm_stat[7:0]*        |          mm_ctrl[7:0]*        |
 *          +-------------------------------+-------------------------------+
 *   0xA    |               0               |        mm_addr_out[7:0]       |
 *          +-------------------------------'-------------------------------+
 *   0xC    |                           mm_d[15:0]                          |
 *          '---------------------------------------------------------------'
 *
 *            * REGISTER FLAGS
 *          ,-------,-------,-------,-------,-------,-------,-------,-------,
 *          |   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |
 *          +-------+-------+-------+-------+-------+-------+-------+-------+
 * mm_ctrl  |                       0                       | start | reset |
 *          +-----------------------------------------------+-------+-------+
 * mm_stat  |                           0                           | done  |
 *          '-------------------------------------------------------'-------'
 *
 * start = 0 (mm_ctrl = 0)       // Pauses the internal state machine
 * reset = 1 (mm_ctrl = 1)       // Resets internal registers (sets status bits to 1)
 *
 * mm_e = 6                      // set our bit size (2**6+4 = 1024)
 * for mm_addr_in = 0 ... 63
 *    mm_a[i] = a[mm_addr_in]    // Insert our mm a, b, and m values
 *    mm_b[i] = b[mm_addr_in]
 *    mm_m[i] = m[mm_addr_in]
 * 
 * start = 1 (mm_ctrl = 2)       // Start mm!
 */


`timescale 1ns / 1ps

module mm_bridge(clk, addr, read, write, din, dout);

parameter MM_BRIDGE_BASEADDR = 42'h313370;
parameter MM_BRIDGE_HIGHADDR = 42'h31337F;

input clk;
input [41:0] addr;
input read;
input write;
input [15:0] din;
output [15:0] dout;

wire master_en    = (addr >= MM_BRIDGE_BASEADDR) & (addr <= MM_BRIDGE_HIGHADDR);
wire master_write = master_en & write;
wire master_read  = master_en & read;

reg [7:0] mm_addr_in, mm_addr_out;
reg [3:0] mm_e;
reg [1:0] mm_ctrl;
reg [15:0] mm_m0;
//synthesis attribute init mm_addr_in  00000000;
//synthesis attribute init mm_addr_out 00000000;
//synthesis attribute init mm_e        0000;
//synthesis attribute init mm_ctrl     00;
//synthesis attribute init mm_m0       0000000000000000;
initial begin
   mm_addr_in  <= 8'h0;
   mm_addr_out <= 8'h0;
   mm_e        <= 4'h0;
   mm_ctrl     <= 2'h0;
   mm_m0       <= 16'h0;
end

wire mm_rst = mm_ctrl[0];
wire mm_ce  = mm_ctrl[1];


/* handle reading in data from pcmcia bus */
always @(posedge master_write) begin
   case(addr[3:0])
   4'h0: begin
      mm_addr_in     <= din[7:0];
      mm_e           <= din[11:8];
   end
   4'h8: mm_ctrl     <= din[1:0];
   4'ha: mm_addr_out <= din[7:0];
   endcase
end


/* internal counter state machine */
reg [1:0] stage;                    // stage state sorta-shift register
reg [12:0] counter;                 // general counter to control our state
reg counter_k_o;                    // this gets inverted whenever the output is swapped (basically delayed in mult logic)
reg counter_done;
reg counter_k;
reg mult_ready_0, mult_ready_1;
//synthesis attribute init stage          00;
//synthesis attribute init counter        0000000000000;
//synthesis attribute init counter_k_o    0;
//synthesis attribute init counter_done   0;
//synthesis attribute init counter_k      0;
//synthesis attribute init mult_ready_0   0;
//synthesis attribute init mult_ready_1   0;
initial begin
   stage          <= 2'b00;
   counter        <= 13'h0;
   counter_k_o    <= 1'b0;
   counter_done   <= 1'b0;
   counter_k      <= 1'b0;
   mult_ready_0   <= 1'b0;
   mult_ready_1   <= 1'b0;
end

wire mult_ready,    mult_ready_o;
wire residue_ready, residue_ready_o;
wire setup_ready;
wire [15:0] setup_m0;
always @(posedge clk) begin         // when rst is low and ce is asserted start off the counter and count until 2**e+4, assert counter_done when done 
   if(mm_rst | ~mm_ce) begin
      counter        <= 13'h0;
      counter_k_o    <= 1'h0;
      stage          <= 2'b00;
   end else begin
      if(~counter_done) begin
         if(mult_ready)
            counter        <= counter + 1;

         if(mult_ready_o)
            counter_k_o    <= ~counter_k_o;  // same as +1 modulo 2
      end

      case({stage[1:0], residue_ready, residue_ready_o, counter_done})
      5'b00000: stage[1:0] <= 2'b01;
      5'b01100: stage[1:0] <= 2'b11;
      5'b11110: stage[1:0] <= 2'b10;
      5'b10001: stage[1:0] <= 2'b00;
      endcase
   end

   if(mult_ready_o)
      counter_done  <= counter[mm_e + 4];

   if(setup_ready)
      mm_m0         <= setup_m0;

   counter_k      <= counter[0];
   mult_ready_0   <= mult_ready;
   mult_ready_1   <= mult_ready_0;
end

/* storage roms for our values */
wire a_rom_we = ~mm_ce & master_write & (addr[3:0] == 4'h2);
wire b_rom_we = ~mm_ce & master_write & (addr[3:0] == 4'h4);
wire m_rom_we = ~mm_ce & master_write & (addr[3:0] == 4'h6);

wire [15:0] a_rom_dout_0;
mm_rom a_rom(
   .clk   (clk),
   .addr_0(mm_addr_in),
   .din_0 (din),
   .we_0  (a_rom_we),
   .addr_1(mm_addr_in),
   .dout_0(a_rom_dout_0),
   .dout_1()
);

wire [7:0] b_rom_addr_1;
wire [15:0] b_rom_dout_0, b_rom_dout_1;
mm_rom b_rom(
   .clk   (clk),
   .addr_0(mm_addr_in),
   .din_0 (din),
   .we_0  (b_rom_we),
   .addr_1(b_rom_addr_1),
   .dout_0(b_rom_dout_0),
   .dout_1(b_rom_dout_1)
);

wire [7:0] m_rom_addr_0, m_rom_addr_1;
wire [15:0] m_rom_dout_0, m_rom_dout_1;
mm_rom m_rom(
   .clk   (clk),
   .addr_0(mm_ce ? m_rom_addr_0 : mm_addr_in),
   .din_0 (din),
   .we_0  (m_rom_we),
   .addr_1(m_rom_addr_1),
   .dout_0(m_rom_dout_0),
   .dout_1(m_rom_dout_1)
);


/*
 * these roms will swap each round and interchangably do
 * t1 = t0*t0, t0 = t1*t1 to perform our squaring operations
 * we use quad-port blockrams for the t roms (made out of
 * 3 dual-port blockrams) because we need to do 3 simultaneous
 * reads.
 */
wire t0_rom_we;
wire [7:0]  t0_rom_addr_0, t0_rom_addr_1, t0_rom_addr_2, t0_rom_addr_3;
wire [15:0] t0_rom_din,    t0_rom_dout_1, t0_rom_dout_2, t0_rom_dout_3;
mm_rom2 t0_rom(
   .clk   (clk),
   .addr_0(mm_ce ? t0_rom_addr_0 : mm_addr_in),
   .din_0 (mm_ce ? t0_rom_din    : din),
   .we_0  (mm_ce ? t0_rom_we     : a_rom_we),
   .addr_1(t0_rom_addr_1),
   .addr_2(t0_rom_addr_2),
   .addr_3(t0_rom_addr_3),
   .dout_0(),
   .dout_1(t0_rom_dout_1),
   .dout_2(t0_rom_dout_2),
   .dout_3(t0_rom_dout_3)
);

wire t1_rom_we;
wire [7:0]  t1_rom_addr_0, t1_rom_addr_1, t1_rom_addr_2, t1_rom_addr_3;
wire [15:0] t1_rom_din,    t1_rom_dout_1, t1_rom_dout_2, t1_rom_dout_3;
mm_rom2 t1_rom(
   .clk   (clk),
   .addr_0(mm_ce ? t1_rom_addr_0 : mm_addr_in),
   .din_0 (mm_ce ? t1_rom_din    : din),
   .we_0  (mm_ce ? t1_rom_we     : a_rom_we),
   .addr_1(t1_rom_addr_1),
   .addr_2(t1_rom_addr_2),
   .addr_3(t1_rom_addr_3),
   .dout_0(),
   .dout_1(t1_rom_dout_1),
   .dout_2(t1_rom_dout_2),
   .dout_3(t1_rom_dout_3)
);


/* initialize the t0 and t1 roms in our first stage with the residue value of A */
wire [7:0] res_A_addr, res_M_addr, res_D_addr, res_A_o_addr, res_D_o_addr;
wire [15:0] res_A_o, res_D_o;
wire res_A_o_we, res_D_o_we;
mm_residue mm_residue(
   .clk     (clk),
   .rst     (mm_rst),
   .ce      (stage[0]),
   .e       (mm_e),
   .A       (t0_rom_dout_1),
   .M       (m_rom_dout_0),
   .D       (t1_rom_dout_1),
   .A_addr  (res_A_addr),
   .M_addr  (res_M_addr),
   .D_addr  (res_D_addr),
   .A_o     (res_A_o),
   .A_o_addr(res_A_o_addr),
   .A_o_we  (res_A_o_we),
   .D_o     (res_D_o),
   .D_o_addr(res_D_o_addr),
   .D_o_we  (res_D_o_we),
   .ready   (residue_ready),
   .ready_o (residue_ready_o)
);

wire [7:0]  setup_M_addr = 8'h0;
mm_setup mm_setup(
   .clk     (clk),
   .rst     (mm_rst), 
   .ce      (stage[0]),
   .n       (m_rom_dout_1),
   .p       (setup_m0),
   .ready   (setup_ready)
);


/* initialize our c values to 1 so we're ready to multiply for the first round */
wire [15:0] c_rom_din = (a_rom_we) ?
   (mm_addr_in == 8'h0) ? 16'h1 :
   16'h0 : 16'h0;

wire c0_rom_we;
wire [7:0]  c0_rom_addr_0, c0_rom_addr_1;
wire [15:0] c0_rom_din,    c0_rom_dout_1;
mm_rom c0_rom(
   .clk   (clk),
   .addr_0(mm_ce ? c0_rom_addr_0 : mm_addr_in),
   .din_0 (mm_ce ? c0_rom_din    : c_rom_din),
   .we_0  (mm_ce ? c0_rom_we     : a_rom_we),
   .addr_1(c0_rom_addr_1),
   .dout_0(),
   .dout_1(c0_rom_dout_1)
);

wire c1_rom_we;
wire [7:0]  c1_rom_addr_0, c1_rom_addr_1;
wire [15:0] c1_rom_din,    c1_rom_dout_1;
mm_rom c1_rom(
   .clk   (clk),
   .addr_0(mm_ce ? c1_rom_addr_0 : mm_addr_in),
   .din_0 (mm_ce ? c1_rom_din    : c_rom_din),
   .we_0  (mm_ce ? c1_rom_we     : a_rom_we),
   .addr_1(c1_rom_addr_1),
   .dout_0(),
   .dout_1(c1_rom_dout_1)
);


/*
 * we're basically trying to wire this so that:
 *
 * B[0] = 1    T1 <- MM0(T0, T0)    C1 <- MM1(C0, T1)
 * B[1] = 1    T0 <- MM0(T1, T1)    C0 <- MM1(C1, T0)
 * B[2] = 0    T1 <- MM0(T0, T0)    C1 <- C0
 * B[3] = 1    T0 <- MM0(T1, T1)    C0 <- MM1(C1, T0)
 */
wire [7:0] mm0_A_addr, mm0_B_addr, mm0_M_addr, mm0_D_addr, mm0_D_o_addr;
wire [15:0] mm0_D_o;
wire mm0_D_o_we;
mm_radix16_mult mm_radix16_mult0(
   .clk     (clk),                                                // clock
   .rst     (mm_rst),                                             // reset       (ctrl:reset)
   .ce      (stage[1]),                                           // chip enable (ctrl:start)
   .cp      (1'b0),                                               // when this is high, copy straight from A to the output (not needed for this)
   .e       (mm_e),                                               // number of 16-bit words
   .A       (counter_k ? t1_rom_dout_1 : t0_rom_dout_1),          // T0 on even,
   .B       (counter_k ? t1_rom_dout_2 : t0_rom_dout_2),          // T1 on odd
   .M       (m_rom_dout_0),                                       // we'll give MM0 the 0 bank for M
   .M0      (mm_m0),                                              // our static M0 value XXX this will become dynamic eventually XXX
   .D       (counter_k ? t0_rom_dout_1 : t1_rom_dout_1),          // use t as our temporary result storage rom
   .A_addr  (mm0_A_addr),
   .B_addr  (mm0_B_addr),
   .M_addr  (mm0_M_addr),
   .D_addr  (mm0_D_addr),
   .D_o     (mm0_D_o),                                            // pipe our output to the din port
   .D_o_addr(mm0_D_o_addr),                                       // we control the write through port 0
   .D_o_we  (mm0_D_o_we),                                         // and the we
   .ready   (mult_ready),
   .ready_o (mult_ready_o)
);

/* this enable will be delayed by one clock cycle when we're switching pages, so make sure we delay the signal by one clock cycle when we aren't */
assign b_rom_addr_1 = counter[11:4];
wire mm1_en_wire = ~b_rom_dout_1[counter[3:0]];
reg mm1_en;
//synthesis attribute init mm1_en 0;
initial mm1_en <= 1'b0;

always @(posedge clk)
   if(mult_ready_1)
      mm1_en <= mm1_en_wire;

wire [7:0] mm1_A_addr, mm1_B_addr, mm1_M_addr, mm1_D_addr, mm1_D_o_addr;
wire [15:0] mm1_D_o;
wire mm1_D_o_we;
mm_radix16_mult mm_radix16_mult1(
   .clk     (clk),                                                // clock
   .rst     (mm_rst),                                             // reset       (ctrl:reset)
   .ce      (stage[1]),                                           // chip enable (ctrl:start)
   .cp      (mm1_en),                                             // when this is high, copy straight from the A to the output
   .e       (mm_e),                                               // number of 16-bit words
   .A       (counter_k ? c1_rom_dout_1 : c0_rom_dout_1),          // C0 on even, C1 on odd
   .B       (counter_k ? t1_rom_dout_3 : t0_rom_dout_3),          // T0 on even, T1 on odd (this should work, although we may have to mux the addrs)
   .M       (m_rom_dout_1),                                       // we'll give MM1 the 1 bank for M
   .M0      (mm_m0),                                              // our static M0 value XXX this will become dynamic eventually XXX
   .D       (counter_k ? c0_rom_dout_1 : c1_rom_dout_1),
   .A_addr  (mm1_A_addr),
   .B_addr  (mm1_B_addr),
   .M_addr  (mm1_M_addr),
   .D_addr  (mm1_D_addr),
   .D_o     (mm1_D_o),                                            // pipe our output to the din port
   .D_o_addr(mm1_D_o_addr),                                       // we control the write through port 0
   .D_o_we  (mm1_D_o_we),                                         // and the we
   .ready   (),
   .ready_o ()
);


/* t0 */
assign t0_rom_addr_0 = stage[0]     ? res_A_o_addr : mm0_D_o_addr;// make sure our inputs are muxed for their respective stages
assign t0_rom_din    = stage[0]     ? res_A_o      : mm0_D_o;
assign t0_rom_we     = stage[0]     ? res_A_o_we   :
                       counter_k_o  ? mm0_D_o_we   : 1'b0;
assign t0_rom_addr_1 = stage[0]     ? res_A_addr   :
                       counter_k    ? mm0_D_addr   : mm0_A_addr;
assign t0_rom_addr_2 = counter_k    ? 8'h0         : mm0_B_addr;
assign t0_rom_addr_3 = mm1_B_addr;
/* t1 */
assign t1_rom_addr_0 = stage[0]     ? res_D_o_addr : mm0_D_o_addr;// same here.
assign t1_rom_din    = stage[0]     ? res_D_o      : mm0_D_o;
assign t1_rom_we     = stage[0]     ? res_D_o_we   :
                       counter_k_o  ? 1'b0         : mm0_D_o_we;
assign t1_rom_addr_1 = stage[0]     ? res_D_addr   :
                       counter_k    ? mm0_A_addr   : mm0_D_addr;
assign t1_rom_addr_2 = counter_k    ? mm0_B_addr   : 8'h0;
assign t1_rom_addr_3 = mm1_B_addr;

/* c0 */
assign c0_rom_addr_0 = mm1_D_o_addr;
assign c0_rom_din    = mm1_D_o;
assign c0_rom_we     = counter_k_o  ? mm1_D_o_we   : 1'b0;
assign c0_rom_addr_1 = counter_done ? mm_addr_out  :
                       counter_k    ? mm1_D_addr   : mm1_A_addr;
/* c1 */
assign c1_rom_addr_0 = mm1_D_o_addr;
assign c1_rom_din    = mm1_D_o;
assign c1_rom_we     = counter_k_o  ? 1'b0         : mm1_D_o_we;
assign c1_rom_addr_1 = counter_k    ? mm1_A_addr   : mm1_D_addr;

/* m */
assign m_rom_addr_0  = stage[0]     ? res_M_addr   : mm0_M_addr;
assign m_rom_addr_1  = stage[0]     ? setup_M_addr : mm1_M_addr;

/* ship out the data from our roms and registers */
assign dout = (master_read) ?
   (addr[3:0] == 4'h0) ? {4'h0, mm_e, mm_addr_in} :
   (addr[3:0] == 4'h2) ? a_rom_dout_0 & {16{~mm_ce}} :
   (addr[3:0] == 4'h4) ? b_rom_dout_0 & {16{~mm_ce}} :
   (addr[3:0] == 4'h6) ? m_rom_dout_0 & {16{~mm_ce}} :
   (addr[3:0] == 4'h8) ? {7'h0, counter_done, 6'h0, mm_ctrl[1:0]} :
   (addr[3:0] == 4'ha) ? {8'h0, mm_addr_out} :
   (addr[3:0] == 4'hc) ? c0_rom_dout_1 :
   (addr[3:0] == 4'he) ? mm_m0 : 16'h0 :
   16'h0;

endmodule