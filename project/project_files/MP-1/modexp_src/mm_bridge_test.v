`timescale 1ns / 1ps

module mm_bridge_test_v;

	// Inputs
	reg clk;
	reg [41:0] addr;
	reg read;
	reg write;
	reg [15:0] din;

	// Outputs
	wire [15:0] dout;

	// Instantiate the Unit Under Test (UUT)
	mm_bridge # (
      .MM_BRIDGE_BASEADDR(42'h0),
      .MM_BRIDGE_HIGHADDR(42'hf)
   )
   uut (
		.clk(clk), 
		.addr(addr), 
		.read(read), 
		.write(write), 
		.din(din), 
		.dout(dout)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		addr = 0;
		read = 0;
		write = 0;
		din = 0;

		// Wait 100 ns for global reset to finish
		#100;

      // our test is:
      // 3324 3238 1919 2191 3324 3238 1919 2191 ** 7538 1923 0191 1337 7538 1923 0191 1337 % 3939 9910 2282 3317 3939 9910 2282 3317
      // A = 3324 3238 1919 2191 3324 3238 1919 2191 3324 3238 1919 2191 3324 3238 1919 2191
      // m0 = cb59

		// Add stimulus here
      @(posedge clk);
      addr = 42'h8;        // set reset high, start low
      din = 16'h0001;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // set M0
      addr = 42'hE;
      din = 16'hcb59;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 4, mm_addr_in = 0
      din = 16'h0400;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 2191
      din = 16'h2191;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 1337
      din = 16'h1337;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 3317
      din = 16'h3317;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = 1
      din = 16'h0401;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 1919
      din = 16'h1919;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 0191
      din = 16'h0191;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 2282
      din = 16'h2282;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = 2
      din = 16'h0402;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 3238
      din = 16'h3238;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 1923
      din = 16'h1923;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 9910
      din = 16'h9910;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = 3
      din = 16'h0403;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 3324
      din = 16'h3324;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 7538
      din = 16'h7538;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 3939
      din = 16'h3939;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = 4
      din = 16'h0404;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 2191
      din = 16'h2191;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 1337
      din = 16'h1337;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 3317
      din = 16'h3317;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = 5
      din = 16'h0405;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 1919
      din = 16'h1919;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 0191
      din = 16'h0191;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 2282
      din = 16'h2282;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = 6
      din = 16'h0406;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 3238
      din = 16'h3238;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 1923
      din = 16'h1923;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 9910
      din = 16'h9910;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = 7
      din = 16'h0407;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 3324
      din = 16'h3324;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 7538
      din = 16'h7538;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 3939
      din = 16'h3939;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = 8
      din = 16'h0408;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 2191
      din = 16'h2191;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 1337
      din = 16'h1337;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 3317
      din = 16'h3317;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = 9
      din = 16'h0409;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 1919
      din = 16'h1919;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 0191
      din = 16'h0191;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 2282
      din = 16'h2282;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = a
      din = 16'h040a;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 3238
      din = 16'h3238;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 1923
      din = 16'h1923;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 9910
      din = 16'h9910;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = b
      din = 16'h040b;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 3324
      din = 16'h3324;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 7538
      din = 16'h7538;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 3939
      din = 16'h3939;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = c
      din = 16'h040c;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 2191
      din = 16'h2191;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 1337
      din = 16'h1337;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 3317
      din = 16'h3317;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = d
      din = 16'h040d;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 1919
      din = 16'h1919;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 0191
      din = 16'h0191;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 2282
      din = 16'h2282;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = e
      din = 16'h040e;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 3238
      din = 16'h3238;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 1923
      din = 16'h1923;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 9910
      din = 16'h9910;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h0;        // mm_e = 3, mm_addr_in = f
      din = 16'h040f;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h2;        // mm_a[0] = 3324
      din = 16'h3324;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h4;        // mm_b[0] = 7538
      din = 16'h7538;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h6;        // mm_m[0] = 3939
      din = 16'h3939;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
      addr = 42'h8;        // rst = 0, ce = 1
      din = 16'h0002;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;

      #140000;
      @(posedge clk);
      addr = 42'hA;        // addr_out = 0
      din = 16'h0;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[0]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("0: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = 1
      din = 16'h1;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[1]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("1: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = 2
      din = 16'h2;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[2]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("2: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = 3
      din = 16'h3;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[3]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("3: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = 4
      din = 16'h4;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[4]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("4: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = 5
      din = 16'h5;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[5]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("5: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = 6
      din = 16'h6;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[6]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("6: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = 7
      din = 16'h7;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[7]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("7: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = 8
      din = 16'h8;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[8]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("8: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = 9
      din = 16'h9;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[9]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("9: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = A
      din = 16'hA;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[A]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("10: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = B
      din = 16'hB;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[B]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("11: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = C
      din = 16'hC;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[C]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("12: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = D
      din = 16'hD;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[D]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("13: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = E
      din = 16'hE;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[E]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("14: %x", dout);
      @(posedge clk);
      addr = 42'hA;        // addr_out = F
      din = 16'hF;
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);      // read mm_d[F]
      addr = 42'hC;
      read = 1'b1;
      @(posedge clk);
      read = 1'b0;
      $display("15: %x", dout);
	end

   always #1 clk = ~clk;
endmodule

