`timescale 1ns / 1ps

module mm_rom2(clk, addr_0, din_0, we_0, addr_1, addr_2, addr_3, dout_0, dout_1, dout_2, dout_3);

input clk;
input [7:0] addr_0;
input [15:0] din_0;
input we_0;
input [7:0] addr_1;
input [7:0] addr_2;
input [7:0] addr_3;
output [15:0] dout_0;
output [15:0] dout_1;
output [15:0] dout_2;
output [15:0] dout_3;

reg [15:0] dout_0, dout_1, dout_2, dout_3;
reg [15:0] mm_rom0 [255:0];
reg [15:0] mm_rom1 [255:0];
reg [15:0] mm_rom2 [255:0];

always @(posedge clk) begin
   if(we_0) begin
      mm_rom0[addr_0] <= din_0;
      mm_rom1[addr_0] <= din_0;
      mm_rom2[addr_0] <= din_0;
      dout_0 <= din_0;
   end else
      dout_0 <= mm_rom0[addr_0];

   dout_1 <= mm_rom0[addr_1];
   dout_2 <= mm_rom1[addr_2];
   dout_3 <= mm_rom2[addr_3];
end

endmodule
