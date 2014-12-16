`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:59:23 06/13/2005
// Design Name:   mm_radix16_mult
// Module Name:   mm_radix16_mult_test.v
// Project Name:  modexp
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mm_radix16_mult
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mm_radix16_mult_test_v;

	// Inputs
	reg clk;
	reg rst;
	reg ce;
	reg [3:0] e;
	reg [15:0] A;
	reg [15:0] B;
	reg [15:0] M;
	reg [15:0] D;
	reg [15:0] M0;

	// Outputs
	wire [7:0] A_addr;
	wire [7:0] B_addr;
	wire [7:0] M_addr;
	wire [7:0] D_addr;
	wire [15:0] D_o;
	wire [7:0] D_o_addr;

	// Instantiate the Unit Under Test (UUT)
	mm_radix16_mult uut (
		.clk(clk), 
		.rst(rst), 
		.ce(ce), 
		.e(e), 
		.A(A), 
		.B(B), 
		.M(M), 
		.D(D), 
		.M0(M0), 
		.A_addr(A_addr), 
		.B_addr(B_addr), 
		.M_addr(M_addr), 
		.D_addr(D_addr), 
		.D_o(D_o), 
		.D_o_addr(D_o_addr)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		ce = 0;
		e = 6;
		A = 0;
		B = 3;
		M = 19;
		D = 0;
		M0 = 231;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
      @(posedge clk);
      rst = 0;
      ce = 1;
	end
   
   always #1 clk = ~clk;
   always @(posedge clk) begin
      if(~rst & ce) begin
         A = A + 1;
         B = B + 1;
         M = M + 1;
      end
   end

endmodule

