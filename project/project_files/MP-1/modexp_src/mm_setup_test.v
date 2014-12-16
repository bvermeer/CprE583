`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:08:49 06/29/2005
// Design Name:   mm_setup
// Module Name:   mm_setup_test.v
// Project Name:  modexp
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mm_setup
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mm_setup_test_v;

	// Inputs
	reg clk;
	reg rst;
	reg ce;
	reg [15:0] n;

	// Outputs
	wire [15:0] p;
	wire ready;

	// Instantiate the Unit Under Test (UUT)
	mm_setup uut (
		.clk(clk), 
		.rst(rst), 
		.ce(ce), 
		.n(n), 
		.p(p), 
		.ready(ready)
	);

	initial begin
		// Initialize Inputs
		clk = 1'b0;
		rst = 1'b1;
		ce = 1'b0;
		n = 16'h0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
      n   = 16'h3317;
      rst = 1'b0;
      ce  = 1'b1;
      wait(ready);
      $display("%x", p);
	end
      
   always #1 clk <= ~clk;
endmodule

