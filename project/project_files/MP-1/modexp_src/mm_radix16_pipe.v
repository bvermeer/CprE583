`timescale 1ns / 1ps

/*
 * pipeline has a few stages:
 *
 * 0: P0 = (A[i] * B[j]) + D
 * 
 * 1:
 *    if(init)
 *       U = P0[15:0] * M0
 *    P1 = P0 (dummy stage)
 *
 * 2: P2 = (M[i] * U) + P1
 *
 * 3: 
 *    if(init)
 *       CS <- rst (one clock cycle beforehand)
 *    CS = CS + P2 (accumulate stage)
 */

module mm_radix16_pipe(clk, rst, ce, cp, init, A, B, M, M0, D, D_o);

input clk, rst, ce, cp, init;
input [15:0] A;
input [15:0] B;
input [15:0] M;
input [15:0] M0;
input [15:0] D;
output [15:0] D_o;

reg [4:0] cp_, init_;
reg [15:0] A_, A_0, A_1, A_2, A_3, A_4;
reg [15:0] B_;
reg [15:0] M_, M_0, M_1;
reg [15:0] M0_, M0_0;
reg [15:0] D_;
reg [15:0] U;
reg [15:0] D_o;
//synthesis attribute init cp_   00000;
//synthesis attribute init init_ 00000;
//synthesis attribute init A_    0000000000000000;
//synthesis attribute init A_0   0000000000000000;
//synthesis attribute init A_1   0000000000000000;
//synthesis attribute init A_2   0000000000000000;
//synthesis attribute init A_3   0000000000000000;
//synthesis attribute init A_4   0000000000000000;
//synthesis attribute init B_    0000000000000000;
//synthesis attribute init M_    0000000000000000;
//synthesis attribute init M_0   0000000000000000;
//synthesis attribute init M_1   0000000000000000;
//synthesis attribute init M0_   0000000000000000;
//synthesis attribute init M0_0  0000000000000000;
//synthesis attribute init D_    0000000000000000;
//synthesis attribute init U     0000000000000000;
//synthesis attribute init D_o   0000000000000000;
initial begin
   cp_   <= 5'h0;
   init_ <= 5'h0;
   A_    <= 16'h0;
   A_0   <= 16'h0;
   A_1   <= 16'h0;
   A_2   <= 16'h0;
   A_3   <= 16'h0;
   A_4   <= 16'h0;
   B_    <= 16'h0;
   M_    <= 16'h0;
   M_0   <= 16'h0;
   M_1   <= 16'h0;
   M0_   <= 16'h0;
   M0_0  <= 16'h0;
   D_    <= 16'h0;
   U     <= 16'h0;
   D_o   <= 16'h0;
end

always @(posedge clk) begin
   cp_   <= {cp_[3:0], cp};
   init_ <= {init_[3:0], init};
   A_    <= A;
   B_    <= B;
   M_    <= M;
   M0_   <= M0;
   D_    <= D;
end


/*
 * stage 0
 *
 * P0 = (A[i] * B[j]) + D
 */
wire [35:0] P0;
mult16 mult16_0(
   .clk(clk),
   .rst(rst),
   .ce(ce),
   .sub(1'b0),
   .a({2'h0, A_}),
   .b({2'h0, B_}),
   .c({20'h0, D_}),
   .p(P0)
);

always @(posedge clk) begin
   A_0   <= A_;
   M_0   <= M_;
   M0_0  <= M0_;
end


/*
 * stage 1
 *
 * if(init)
 *    U = P0[15:0] * M0
 * P1 = P0 (dummy stage)
 */
wire [15:0] U_;
wire [19:0] nil0;
mult16 mult16_1(
   .clk(clk),
   .rst(rst),
   .ce(ce),
   .sub(1'b0),
   .a(init_[1] ? {2'h0, P0[15:0]} : 18'h0),
   .b(init_[1] ? {2'h0, M0_0} : 18'h0),
   .c(36'h0),
   .p({nil0, U_})
);

reg [35:0] P1;
//synthesis attribute init P1 000000000000000000000000000000000000;
initial P1 <= 36'h0;

always @(posedge clk) begin
   A_1      <= A_0;
   M_1      <= M_0;

   if(init_[2])
      U     <= U_;
   P1       <= P0;
end


/*
 * stage 2
 *
 * P2 = (M[i] * U) + P1
 */
wire [35:0] P2;
mult16 mult16_2(
   .clk(clk),
   .rst(rst),
   .ce(ce),
   .sub(1'b0),
   .a({2'h0, M_1}),
   .b(init_[2] ? U_ : {2'h0, U}),
   .c(P1),
   .p(P2)
);

always @(posedge clk) begin
   A_2      <= A_1;
end


/*
 * stage 3
 *
 * CS = CS + P2 (accumulate stage)
 */
wire [33:0] P3;
wire [1:0] nil1;
mult16 mult16_3(
   .clk(clk),
   .rst(rst),
   .ce(ce),
   .sub(1'b0),
   .a(18'h1),
   .b(init_[3] ? 18'h0 : P3[33:16]),
   .c(P2),
   .p({nil1, P3})
);

always @(posedge clk) begin
   A_3      <= A_2;
   A_4      <= A_3;
end


/*
 * D[i-1] = CS[15:0]
 * CS >> w
 * D[e-1] = CS[15:0]
 */
reg latch_out;
reg [15:0] D_o_sustain;     // saves the P3 value for the D[e-1] = CS
//synthesis attribute init latch_out   0;
//synthesis attribute init D_o_sustain 0000000000000000;
initial begin
   latch_out   <= 1'b0;
   D_o_sustain <= 16'h0;
end

always @(posedge clk) begin
   if(rst | ~ce)
      latch_out   <= 1'b0;
   else begin
      D_o_sustain <= P3[31:16];

      if(cp_[4])              // if we're in cp state, just copy A to D_o without modification
         D_o      <= A_4;
      else if(init_[4]) begin
         if(latch_out)        // on our init state, return the CS for e-1 to maintain a smooth (power of 2) pipeline
            D_o       <= D_o_sustain;
         else if(~init_[3])
            latch_out <= 1'b1;
      end else
         D_o      <= P3[15:0];
   end
   $display("D: %x\n", D_o);
end

endmodule