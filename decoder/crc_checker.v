`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:00:01 05/13/2017 
// Design Name: 
// Module Name:    crc_checker 
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
module crc_checker(BITVAL, clock, CLEAR, CRC);
   input        BITVAL;                            // Next input bit
   input        clock;                           // Current bit valid (Clock)
   input        CLEAR;                             // Init CRC value
   output [14:0] CRC;                               // Current output CRC value

   reg    [14:0] CRC;                               // We need output registers
   wire         inv;
   
   assign inv = BITVAL ^ CRC[14];                   // XOR required?
   
   always @(posedge clock or posedge CLEAR) begin
      if (CLEAR) begin
         CRC = 0;                                  // Init before calculation
         end
      else begin
         CRC[14] = CRC[13] ^ inv;
         CRC[13] = CRC[12];
         CRC[12] = CRC[11];
         CRC[11] = CRC[10];
         CRC[10] = CRC[9] ^ inv;
         CRC[9] = CRC[8];
         CRC[8] = CRC[7] ^ inv;
         CRC[7] = CRC[6] ^ inv;
         CRC[6] = CRC[5];
         CRC[5] = CRC[4];
         CRC[4] = CRC[3] ^ inv;
         CRC[3] = CRC[2] ^ inv;
         CRC[2] = CRC[1];
         CRC[1] = CRC[0];
         CRC[0] = inv;
         end
      end
   
endmodule
