`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:09:00 05/06/2017
// Design Name:   bit_destuff
// Module Name:   C:/Users/eron/Documents/canbtl/canbtl/tb_bit_destuff.v
// Project Name:  canbtl
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: bit_destuff
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_bit_destuff;

	// Inputs
	reg CLK;
	reg bit_in;

	// Outputs
	wire bit_out;
	//wire error;

	// Instantiate the Unit Under Test (UUT)
	bit_destuff uut (
		.CLK(CLK), 
		.bit_in(bit_in), 
		//.error(error),
		.bit_out(bit_out)
	);

	always begin
		CLK = 0;
		#1;	// 10 nsec
		CLK = 1;
		#1;	// 10 nsec
	end

	initial begin
		// Initialize Inputs
		//CLK = 0;
		bit_in = 0;
		#3
		bit_in = 1;
		#3
		bit_in = 0;
		#2
		bit_in = 1;
		// Wait 100 ns for global reset to finish
		#50;
		$stop;
        
		// Add stimulus here

	end
      
endmodule

