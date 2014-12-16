`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:24:39 06/12/2005
// Design Name:   mm_radix16_pipe
// Module Name:   mm_radix16_pipe_test.v
// Project Name:  modexp
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mm_radix16_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mm_radix16_pipe_test_v;

	// Inputs
	reg clk;
	reg rst;
	reg ce;
	reg init;
	reg [15:0] A;
	reg [15:0] B;
	reg [15:0] M;
	reg [15:0] M0;
	reg [15:0] D;

	// Outputs
	wire [15:0] D_o;

	// Instantiate the Unit Under Test (UUT)
	mm_radix16_pipe uut (
		.clk(clk), 
		.rst(rst), 
		.ce(ce), 
		.init(init), 
		.A(A), 
		.B(B), 
		.M(M), 
		.M0(M0), 
		.D(D), 
		.D_o(D_o)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		ce = 0;
		init = 0;
		A = 0;
		B = 0;
		M = 0;
		M0 = 0;
		D = 0;

		// Wait 100 ns for global reset to finish
		#100;
      @(posedge clk);
      rst = 0;
      ce = 1;
		// Add stimulus here
      @(posedge clk);
      A = 16'd5;           // A * B + D == 32
      B = 16'd5;
      M = 16'd9;           // M * M0 == 45
      M0 = 16'd5;
      D = 16'd7;           // D == 7
      rst = 0;
      ce = 1;
      init = 1;
      @(posedge clk);
      init = 0;
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
   end

   always #1 clk <= ~clk;
      
endmodule

