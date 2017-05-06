

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:26:26 04/01/2015 
// Design Name: 
// Module Name:    clock 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module bit_destuff(input CLK, input bit_in, output reg bit_out);

reg previous_bit = 0;
reg [2:0] previous_count = 1;

always@(posedge CLK)
	begin
        if (previous_bit && bit_in)
        begin
          previous_count = previous_count + 1;
        end
        else 
        begin
            previous_bit = bit_in
            previous_count = 1;
        end
        bit_out = bit_in;
        if (previous_count == 5)
        begin
            bit_out = ~bit_in;
        end
	 end
endmodule
