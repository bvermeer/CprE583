`timescale 1ns / 1ps

module mult16(clk, rst, ce, sub, a, b, c, p);

parameter REG_IN  = 1'b1;
parameter REG_OUT = 1'b0;

input clk, rst, ce, sub;
input [17:0] a;
input [17:0] b;
input [35:0] c;
output [35:0] p;

//synthesis attribute clock_signal clk true;

// DSP48: DSP Function Block
// Virtex-4
// Xilinx HDL Libraries Guide version 7.1i
wire [11:0] nil;
DSP48 DSP48_0 (
   .BCOUT(),                     // 18-bit B cascade output
   .P({nil, p}),                 // 48-bit product output
   .PCOUT(),                     // 48-bit cascade output
   .A(a[17:0]),                  // 18-bit A data input
   .B(b[17:0]),                  // 18-bit B data input
   .BCIN(18'h0),                 // 18-bit B cascade input
   .C({12'h0, c[35:0]}),         // 48-bit cascade input
   .CARRYIN(1'b0),               // Carry input signal
   .CARRYINSEL(2'h0),            // 2-bit carry input select
   .CEA(ce),                     // A data clock enable input
   .CEB(ce),                     // B data clock enable input
   .CEC(ce),                     // C data clock enable input
   .CECARRYIN(1'b0),             // CARRYIN clock enable input
   .CECINSUB(ce),                // CINSUB clock enable input
   .CECTRL(ce),                  // Clock Enable input for CTRL registers
   .CEM(ce),                     // Clock Enable input for multiplier registers
   .CEP(ce),                     // Clock Enable input for P registers
   .CLK(clk),                    // Clock input
   .OPMODE(7'h35),               // 7-bit operation mode input
   .PCIN(48'h0),                 // 48-bit PCIN input
   .RSTA(rst),                   // Reset input for A pipeline registers
   .RSTB(rst),                   // Reset input for B pipeline registers
   .RSTC(rst),                   // Reset input for C pipeline registers
   .RSTCARRYIN(rst),             // Reset input for CARRYIN registers
   .RSTCTRL(rst),                // Reset input for CTRL registers
   .RSTM(rst),                   // Reset input for multiplier registers
   .RSTP(rst),                   // Reset input for P pipeline registers
   .SUBTRACT(sub)                // SUBTRACT input
);

// The following defparams specify the behavior of the DSP48 block. If the
// instance name to the DSP48 is changed, that change needs to be reflected
// in the defparam statements.
defparam DSP48_0.AREG = REG_IN;              // Number of pipeline registers on the A input, 0, 1 or 2
defparam DSP48_0.BREG = REG_IN;              // Number of pipeline registers on the B input, 0, 1 or 2
defparam DSP48_0.B_INPUT = "DIRECT";         // B input DIRECT from fabric or CASCADE from another DSP48
defparam DSP48_0.CARRYINREG = 0;             // Number of pipeline registers for the CARRYIN input, 0 or 1
defparam DSP48_0.CARRYINSELREG = 0;          // Number of pipeline registers for the CARRYINSEL, 0 or 1
defparam DSP48_0.CREG = REG_IN;              // Number of pipeline registers on the C input, 0 or 1
defparam DSP48_0.LEGACY_MODE = "NONE";       // Backward compatibility, NONE, MULT18X18 or defparam MULT18X18S
defparam DSP48_0.MREG = 0;                   // Number of multiplier pipeline registers, 0 or 1
defparam DSP48_0.OPMODEREG = REG_IN;         // Number of pipeline registers on OPMODE input, 0 or 1
defparam DSP48_0.PREG = REG_OUT;             // Number of pipeline registers on the P output, 0 or 1
defparam DSP48_0.SUBTRACTREG = 0;            // Number of pipeline registers on the SUBTRACT input, 0 or 1
// End of DSP48_inst instantiation

endmodule