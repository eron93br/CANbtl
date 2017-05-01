`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:00:39 04/30/2017
// Design Name:   clkdiv
// Module Name:   C:/Users/eron/Documents/canbtl/canbtl/clk_tb.v
// Project Name:  canbtl
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: clkdiv
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module clk_tb;

	// Inputs
	reg CLK;
	reg [31:0] clkscale;

	// Outputs
	wire sclclk;

	// Instantiate the Unit Under Test (UUT)
	clkdiv uut 
	(
		.CLK(CLK), 
		.clkscale(clkscale), 
		.sclclk(sclclk)
	);

	always begin
		CLK = 0;
		#1;	// 10 nsec
		CLK = 1;
		#1;	// 10 nsec
	end

	initial begin
	   clkscale = 250; 
	   #25; 
		$display("Simulation complete!!!");
		$finish;
	end
      
endmodule

