`timescale 1ns / 1ps

module mm_rom(clk, addr_0, din_0, dout_0, we_0, addr_1, dout_1);

input clk;
input [7:0] addr_0;
input [15:0] din_0;
input we_0;
input [7:0] addr_1;
output [15:0] dout_0;
output [15:0] dout_1;

reg [15:0] dout_0, dout_1;
reg [15:0] mm_rom [255:0];

always @(posedge clk) begin
   if(we_0)
      mm_rom[addr_0] <= din_0;
   else
      dout_0 <= mm_rom[addr_0];

   dout_1 <= mm_rom[addr_1];
end

endmodule
