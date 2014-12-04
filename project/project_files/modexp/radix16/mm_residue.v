`timescale 1ns / 1ps

module mm_residue(clk, rst, ce, e, A, M, D, A_addr, M_addr, D_addr, A_o, A_o_addr, A_o_we, D_o, D_o_addr, D_o_we, ready, ready_o);

input clk, rst, ce;
input [3:0] e;
input [15:0] A;
input [15:0] M;
input [15:0] D;
output [7:0] A_addr;
output [7:0] M_addr;
output [7:0] D_addr;
output [15:0] A_o;
output [7:0] A_o_addr;
output [15:0] D_o;
output [7:0] D_o_addr;
output A_o_we;
output D_o_we;
output ready;
output ready_o;

reg ready_o;

// first we need to create our state counter
wire [3:0] r = e + 4;      // e * W = e + 4
wire [7:0] j;              // this will be a max of e(8)-bits long
wire next;
reg [20:0] counter;        // where it will copy the value of the result rom to the other so we end
reg countere_0;            // up with the same info in both roms.
reg [7:0] j_0;
reg we_0;
reg done;
//synthesis attribute init ready_o     0;
//synthesis attribute init counter     00000000000000000000;
//synthesis attribute init countere_0  0;
//synthesis attribute init j_0         00000000;
//synthesis attribute init we_0        0;
//synthesis attribute init done        0;
initial begin
   ready_o     <= 1'b0;
   counter     <= 21'h0;
   countere_0  <= 1'b0;
   j_0         <= 8'h0;
   we_0        <= 1'b0;
   done        <= 1'b0;
end

always @(posedge clk) begin
   if(rst | ~ce) begin
      counter     <= 20'h0;
      we_0        <= 1'b0;
   end else if(ready)
      we_0        <= 1'b0;
   else begin
      counter     <= counter + 1;
      we_0        <= 1'b1;
   end

   j_0         <= j;
   countere_0  <= counter[e];
   ready_o     <= ready;
   done        <= counter[e + r];
end
assign j     = counter[7:0] & ~(8'hff << e);
assign next  = counter[e] != countere_0;
assign ready = done & counter[e];

reg swap;                           // this will control what X and Y point to.
//synthesis attribute init swap     0;
initial swap <= 1'b0;

wire [15:0] X, Y, X_o, Y_o;         // 0 - X = A, Y = D
wire [7:0] X_addr, X_o_addr;        // 1 - X = D, Y = A
wire [7:0] Y_addr, Y_o_addr;        // depending on the swap setting at the end we may
wire X_o_we, Y_o_we;                // steal extra cycles for cleanup

assign X        = swap ? D        : A;
assign Y        = swap ? A        : D;
assign A_o      = swap ? Y_o      : X_o;
assign D_o      = swap ? X_o      : Y_o;
assign A_addr   = swap ? Y_addr   : X_addr;
assign D_addr   = swap ? X_addr   : Y_addr;
assign A_o_addr = swap ? Y_o_addr : X_o_addr;
assign D_o_addr = swap ? X_o_addr : Y_o_addr;
assign A_o_we   = swap ? Y_o_we   : X_o_we;
assign D_o_we   = swap ? X_o_we   : Y_o_we;

reg [2:0] t_reg;
reg c_reg;
//synthesis attribute init t_reg 000;
//synthesis attribute init c_reg 0;
initial begin
   t_reg <= 3'b000;
   c_reg <= 1'b0;
end

wire [18:0] t = {{17{t_reg[2]}}, t_reg[1:0]} + ({2'h0, X[15:0], 1'b0} - {3'h0, M}); // clock 0 (t_reg is our carry bit)
always @(posedge clk) begin
   if(rst | ~ce) begin
      t_reg    <= 3'b000;
      c_reg    <= 1'b0;
      swap     <= 1'b0;
   end else if(|j) begin
      t_reg    <= t[18:16];
      c_reg    <= X[15];
   end else begin
      t_reg    <= 3'h0;
      c_reg    <= 1'b0;
   end

   if(next & ~(&t[18:16]))
      swap     <= ~swap;
end

assign X_addr     = j;
assign Y_addr     = j;
assign M_addr     = j;
assign Y_o        = done  ? X    : t[15:0];            // clock 1 (will need to be delayed)
assign Y_o_addr   = j_0;                               // single clock cycle delay
assign X_o        = done  ? Y    : {X[14:0], c_reg};   // clock 1
assign X_o_addr   = j_0;                               // another delay
assign X_o_we     = ~done ? we_0 :
                    swap  ? 1'b0 : we_0;
assign Y_o_we     = ~done ? we_0 :
                    swap  ? we_0 : 1'b0;
                    
endmodule