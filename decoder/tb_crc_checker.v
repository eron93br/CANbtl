`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:14:00 05/13/2017
// Design Name:   crc_checker
// Module Name:   C:/Users/eron/Documents/canbtl/canbtl/tb_crc_checker.v
// Project Name:  canbtl
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: crc_checker
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_crc_checker;

	// Inputs
	reg BITVAL;
	reg clock;
	reg CLEAR;

    
	reg [9:0] contador=1;
	reg [44:0] mensagem = 44'h055103FAAB3;
	//reg [44:0] mensagem = {1'b0, 11'h7FF, 2'b11, 18'h3FFFF, 3'b000, 4'b0010, 16'hC2FE};

	// Outputs
	wire [14:0] CRC;

	// Instantiate the Unit Under Test (UUT)
	crc_checker uut (
		.BITVAL(BITVAL), 
		.CLEAR(CLEAR),
		.clock(clock), 
		.CRC(CRC)
	);

	always begin
		clock = 1;
		BITVAL = mensagem[(45-contador)];
		#1;	// 10 nsec
		clock = 0;
		contador = contador + 1;
		#1;	// 10 nsec
	end


	initial begin
	CLEAR=0;
   #1;
	CLEAR=1;
	#1;
	CLEAR=0;
	#93;
	$stop; 
	end
      
endmodule

