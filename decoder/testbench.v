`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:36:18 05/06/2017
// Design Name:   candecoder
// Module Name:   C:/Users/eron/Documents/canbtl/canbtl/tb_decoder.v
// Project Name:  canbtl
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: candecoder
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_decoder;

	// Inputs
	reg sample;
	reg can_data_bit;

	
	// MSG1 :: 11-bits  :: 4bytes :: DATA FRAME :: CRC OK 
	reg [79:0] mensagem = {2'b11, 1'b0, 11'h551, 3'b000, 4'b0100 ,  32'hABCD1234 , 15'd30322, 3'b101 , 7'b1111111 ,2'b11}; 
	
	// MSG2 :: 11-bits  :: 8bytes :: DATA FRAME :: CRC NOT OK 
	//reg[109:0] mensagem = {2'b11, 1'b0, 11'h1AF, 3'b000, 4'b1000, 64'hB1C2D3E4F5, 15'd09908, 3'b101, 7'b1111111}; 
	
	// MSG3 :: 29-bits  :: 8bytes :: DATA FRAME :: CRC OK
	//reg [129:0] mensagem = {2'b11, 1'b0, 11'h7FF, 2'b11, 18'h3FFFF, 3'b000, 4'b1000, 64'h9A07AA55FF00C2FE, 25'b0101010101010110000000000 }; 
   
	// MSG4 :: 29-bits  :: 1bytes :: DATA FRAME :: CRC OK
	//reg [75:0] mensagem = {4'b1111, 1'b0, 11'h0A5, 2'b11, 18'h0F1FA, 3'b011, 4'b0001, 8'hAF, 15'h03F5C, 3'b101 , 7'b1111111}; 
	
	// MSG5 :: 11-bits  :: 3bytes :: OVERLOAD FRAME :: CRC ok
	//reg [86:0] mensagem = {2'b11, 1'b0, 11'h551, 3'b100, 4'b0011 ,  24'hFFAAB3 , 15'd10631, 3'b101 , 7'b1111111 ,2'b11, 15'b000000111111111};
	
	// MSG6 :: teste de error frame
	//reg [101:0] mensagem = {1'b1, 1'b0, 11'h551, 3'b000, 4'b0011 ,  24'hFFAAB3 , 15'b010101010101010, 3'b101 , 7'b1111111,6'b111111, 7'b1111111, 8'hFF , 12'd15}; 

	
	// mensagem 3 :: 11-bits
	//reg [111:0] mensagem = {4'b1111, 1'b0, 11'h70F, 3'b101, 4'b1000, 64'hF0E0D0C0B0A0FF55, 25'b0101010101010110000000000};
   
	// mensagem 4 :: 11-bits
	//reg [109:0] mensagem = {2'b11, 1'b0, 11'b11010101010, 3'b101, 4'b1000, 64'hAABBCCDDEEFF0015, 25'b0101010101010110000000000};
	
	// msg 5
	//reg [85:0] mensagem = {2'b11, 1'b0, 11'h3F1, 3'b000, 4'b0101 , 40'hFF00AAB2B1, 25'b0101010101010110000000000}; 
	
	// testar erro
	//reg [101:0] mensagem = {1'b1, 1'b0, 11'h551, 3'b000, 4'b0011 ,  24'hFFAAB3 , 15'b010101010101010, 3'b101 , 7'b1111111,
	//6'b111111, 7'b1111111, 8'hFF , 12'd15}; 
	// testar overload frame...
	//reg [86:0] mensagem = {2'b11, 1'b0, 11'h551, 3'b100, 4'b0011 ,  24'hFFAAB3 , 15'b010101010101010, 3'b101 , 7'b1111111 ,2'b11, 15'b000000111111111};
	
	
	// Outputs
	wire ack_error;
	wire eof_error;
	wire crc_error;
	wire frame_remote;
	wire frame_data;
	wire frame_error;
   wire frame_overload;
   wire getframe;
	wire [3:0] nbytes;
	wire [5:0] error_frame;
	wire [6:0] error_flag;
	wire [10:0] bit_id_11;
	wire [28:0] bit_id_29;
	wire [63:0] can_data;
	wire [6:0] debug_state;
	wire [1:0] bit_classifier;
	wire [12:0] overload_check;
	wire start_crc;
	wire [14:0] crcout;
	wire getcrc;
	wire crcclk;
	reg [9:0] contador=1;
	wire [14:0] crc;

	// Instantiate the Unit Under Test (UUT)
    candecoder decoder( 
    .sample(sample), 
    .can_data_bit(can_data_bit), 
    .crc(crc), 
    .ack_error(ack_error), 
    .eof_error(eof_error), 
    .crc_error(crc_error), 
    .frame_remote(frame_remote), 
    .frame_data(frame_data), 
    .frame_error(frame_error), 
    .error_type(error_type), 
    .frame_overload(frame_overload), 
    .getframe(getframe), 
    .crc_match(crc_match), 
    .error_flag(error_flag), 
    .error_frame(error_frame), 
    .nbytes(nbytes), 
    .overload_check(overload_check), 
    .bit_id_11(bit_id_11), 
	 .crcout(crcout),
    .bit_id_29(bit_id_29), 
    .can_data(can_data), 
	 .crcclk(crcclk),
    .bit_classifier(bit_classifier), 
    .start_crc(start_crc), 
    .getcrc(getcrc), 
    .debug_state(debug_state)
    );
 
 /*crc modulo_crc(
    .getcrc(getcrc), 
    .start(start_crc), 
    .clk(sample), 
    .candata(can_data_bit), 
    .CRC(crc)
    );*/
	 
   crc_checker CRC_dp
	 (
    .BITVAL(can_data_bit),  //ok 
    .clock(sample),  // ok
    .CLEAR(start_crc),  // ok
    .CRC(crc)   // ok
    );


	always begin
		sample = 1;
		can_data_bit = mensagem[(102-contador)];
		#1;	// 10 nsec
		sample = 0;
		contador = contador + 1;
		#1;	// 10 nsec	  
	end

   always@(posedge ack_error)
	begin
	      $display("                                            ");
	      $display(" ERRO! ACK DELIMITER ERROR!");
	end

   always@(posedge eof_error)
	begin
	      $display("                                            ");
	      $display(" ERRO! EOF ERROR! NAO TEMOS 7-BITS RECESSIVOS..");
	end

   always@(posedge crc_error)
	begin
	      $display("                                            ");
	      $display(" ERRO! CRC DELIMITER ERROR!");
	end	
	
	always@(posedge crcclk)
	begin
				 $display("                                            ");
				 $display("--------------------------------------------");
				 $display(" CRC calculado da mensagem: %h", crcout);
				 if(crc_match)
				 begin
				       $display("                                            ");
				       $display("CRC CHECADO COM SUCESSO!");
				 end
				 else
				 begin  
				       $display("                                            ");
				       $display("ERRO! CRC CHECK ERROR!");
				 end
	end

	always@(posedge getframe)
	begin
	    $display("                                            ");
	    $display(" >>>> Acabou uma mensagem completa! <<<< ");
		 
		 // --------------------- TIPO -----------------------
		 if(frame_data)
		 begin
		      $display("                                            ");
		      $display(" DATA frame detected !");
		 end
		 else if(frame_remote)
		 begin
		      $display("                                            ");
		      $display("REMOTE frame detected !");
		 end 
		 else if(frame_error)
		 begin
		      $display("                                            ");
		      $display("ERROR frame detected !");
		 end
		 else
		 begin
		      $display("                                            ");
		      $display(" OVERLOAD frame detected !");
		 end
		 // --------------------- ID -------------------------
		 if ( (frame_data) || (frame_remote) )
		 begin
		       $display("                                            ");
		       if(bit_classifier == 2'b11)
		           $display("ID [29-bits] da mensagem: %h" , bit_id_29);
				 else
				     $display("ID [11-bits] da mensagem: %h" , bit_id_11);
		 end
		 // ---------------------nbytes & DATA -------------------------
		 if ( (frame_data) || (frame_remote) )
		 begin
				 $display("A mensagem possui %d bytes" , nbytes);
				 $display("                                            ");
				 $display("--------------------------------------------");
				 $display(" MESSAGE DATA: %h", can_data);
				 $display("--------------------------------------------");
				 $display("                                            ");
		 end
	end 

	initial begin
		// Initialize Inputs
	   $display("-------------------Redes Automotivas 2017.1------------------");
      $display("Iniciando simulacao!");
     //#150;
	end
      
endmodule

