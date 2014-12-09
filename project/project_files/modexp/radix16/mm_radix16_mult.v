`timescale 1ns / 1ps

/*
 * generate counter signals for the pipeline so we properly
 * address i, and j indexes in the corresponding roms for
 * the montgomery multiplication
 */
module mm_radix16_mult(clk, rst, ce, cp, e, A, B, M, D, M0, A_addr, B_addr, M_addr, D_addr, D_o, D_o_addr, D_o_we, ready, ready_o);

input clk, rst, ce, cp;
input [3:0] e;                   // number of bits of iterations required (6 -> 2**6 * 16 = 1024-bit)
input [15:0] A, B, M, M0, D;
output [7:0] A_addr, B_addr, M_addr, D_addr;
output [15:0] D_o;
output [7:0] D_o_addr;
output D_o_we;
output ready;
output ready_o;


/*
 * this counter will represent i and j depending on e:
 * e.g. e = 6,
 * i = counter[5:0]
 * j = counter[11:6]
 */
reg [16:0] counter;
//synthesis attribute init counter 0000000000000000;
initial counter <= 17'h0;

wire [7:0] e_mask = ~(8'hff << e);
wire [7:0] i = counter[7:0] & e_mask;
wire [7:0] j = (counter[15:0] >> e) & e_mask;
assign ready = counter[16:0] == ~(17'h1ffff << (e + e));     // counter[12]
always @(posedge clk) begin
   if(rst | ~ce | ready)
      counter <= 16'h0;
   else
      counter <= counter + 1;
end


/*
 * delay write enable from ce by 8 clock cycles
 */
reg [7:0] D_o_we_delay, ready_o_delay;
//synthesis attribute init D_o_we_delay   00000000;
//synthesis attribute init ready_o_delay  00000000;
initial begin
   D_o_we_delay   <= 8'h0;
   ready_o_delay  <= 8'h0;
end

always @(posedge clk) begin
   if(rst | ~ce) begin
      D_o_we_delay   <= 8'h0;
      ready_o_delay  <= 8'h0;
   end else begin
      D_o_we_delay   <= {1'b1, D_o_we_delay[7:1]};
      ready_o_delay  <= {ready, ready_o_delay[7:1]};
   end
end
assign D_o_we  = D_o_we_delay[0] & ce;
assign ready_o = ready_o_delay[0];


/*
 * delay init by one clock cycle to give the bram's enough time to lookup
 */
reg init;
//synthesis attribute init init  0;
initial init  <= 1'b0;

always @(posedge clk)
   init <= ~(|i);

assign A_addr = i;
assign B_addr = j;
assign M_addr = i;
assign D_addr = i;
assign D_o_addr = (i + 248) & e_mask; // make this wrap around to - 8

reg D_mask;
//synthesis attribute init D_mask 0;
initial D_mask <= 1'b0;

always @(posedge clk)
   D_mask <= |j;

mm_radix16_pipe mm_radix16_pipe(
   .clk(clk),
   .rst(rst),
   .ce(ce),
   .cp(cp),
   .init(init),
   .A(A),
   .B(B),
   .M(M),
   .M0(M0),
   .D(D & {16{D_mask}}),
   .D_o(D_o)
);


endmodule