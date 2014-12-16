`timescale 1ns / 1ps

module mm_setup(clk, rst, ce, n, p, ready);

input clk, rst, ce;
input [15:0] n;
output [15:0] p;
output ready;

reg [15:0] p;
reg ready;
reg [3:0] state;
//synthesis attribute init p     0000000000000000;
//synthesis attribute init ready 0;
//synthesis attribute init state 0000;
initial begin
   p     = 16'h0;
   ready = 1'b0;
   state = 4'h0;
end

always @(posedge clk) begin
   if(rst | ~ce | ready)
      state <= 4'h0;
   else
      state <= state + 4'h1;
end

reg [15:0] x_0, m_a, m_b, m_c;
reg m_sub;
//synthesis attribute init x_0   0000000000000000;
//synthesis attribute init m_a   0000000000000000;
//synthesis attribute init m_b   0000000000000000;
//synthesis attribute init m_c   0000000000000000;
//synthesis attribute init m_sub 0;
initial begin
   x_0   = 16'h0;
   m_a   = 16'h0;
   m_b   = 16'h0;
   m_c   = 16'h0;
   m_sub = 1'b0;
end

wire [15:0] m_p;
always @(posedge clk) begin
   if(rst | ~ce) begin
      x_0   <= 16'h0;
      m_a   <= 16'h0;
      m_b   <= 16'h0;
      m_c   <= 16'h0;
      m_sub <= 1'b0;
      ready <= 1'b0;
   end else begin
      case(state)
      4'h0: begin
         m_a   <= 16'h1;                     // x = (((m0 + 2) & 4) << 1) + m0
         m_b   <= {^n[2:1], 3'h0};
         m_c   <= n[15:0];
         m_sub <= 1'b0;
      end
      4'h2: begin
         m_a   <= n;                         // x *= 2 - (m0 * x)
         m_b   <= m_p;
         m_c   <= 16'h2;
         x_0   <= m_p;
         m_sub <= 1'b1;
      end
      4'h4: begin
         m_a <= x_0;
         m_b <= m_p;
         m_c <= 16'h0;
         m_sub <= 1'b0;
      end
      4'h6: begin
         m_a   <= n;                         // x *= 2 - (m0 * x)
         m_b   <= m_p;
         m_c   <= 16'h2;
         x_0   <= m_p;
         m_sub <= 1'b1;
      end
      4'h8: begin
         m_a   <= x_0;
         m_b   <= m_p;
         m_c   <= 16'h0;
         m_sub <= 1'b0;
      end
      4'ha: begin
         m_a   <= 16'h1;                     // p = ((1 << W) - x) & W_MASK
         m_b   <= m_p;
         m_c   <= 16'h0;
         m_sub <= 1'b1;
      end
      4'hc: begin
         p     <= m_p; 
         ready <= 1'b1;
      end
      endcase
   end
end

wire [19:0] nil;
mult16 mult16(
   .clk(clk),
   .rst(rst),
   .ce(ce),
   .sub(m_sub),
   .a({2'h0,  m_a}),
   .b({2'h0,  m_b}),
   .c({20'h0, m_c}),
   .p({nil,   m_p})
);

endmodule
