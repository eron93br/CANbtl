`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:57:18 05/04/2017 
// Design Name: 
// Module Name:    candecoder 
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
module candecoder
      ( input sample,                       // Sample point, indica bit disponivel!
		  input can_data_bit,                 // data bit!!!
		  input [14:0] crc,
		  output reg ack_error = 1'bz,
		  output reg eof_error = 1'bz,
		  output reg crc_error = 1'bz,
		  output reg frame_remote=0,
		  output reg frame_data=0,
		  output reg frame_error=0,
		  output reg error_type=1'bz,
		  output reg frame_overload=0,
		  output reg getframe=0, 
		  output reg crc_match=1'b0,
		  output reg [6:0] error_flag=7'bzzzzzzz,
		  output reg [5:0] error_frame=6'bzzzzzz,
		  output reg [3:0] nbytes = 0,
		  output reg [12:0] overload_check,
		  output reg [10:0] bit_id_11=11'bz,        // 11-bit ID
		  output reg [28:0] bit_id_29=29'bz,        // 29-bit ID
		  output reg [63:0] can_data=64'bz,          // data byte 0
		  output reg [1:0] bit_classifier=0,
		  // STM flags
		  output reg start_crc = 1'b0,
		  output reg crcclk = 1'b0,
		  output  [14:0] crcout,
		  output reg getcrc = 1'b0, 
		  output  [6:0] debug_state
      );
		
///  CAN protocol data frame
///  SOF - BIT = 0

 reg [28:0] arbitration=0; // 29 or 11-bit data of ID!
 reg [7:0] state=0;		
 reg arbitration_field = 0;
 reg control_field = 0;
 reg data_field = 0;
 reg crc_field_flag = 0;
 reg eof_field = 0;
 reg [14:0] crc_field = 0; 
 reg [14:0] crc_calculado; 
 reg [9:0] cont=0; 
 reg [9:0] cont2=0;
 //reg [5:0] error_frame=0;
 reg s0;
 reg ov_flag=0;
 // Previous mesage codification
 // 11 --> remote frame
 // 10 --> data frame
 // 01 --> error frame
 // 00 --> overload frame
 reg [1:0] previous = 2'bzz;
 //reg [12:0] overload_check;
 
 
assign debug_state = state;
assign crcout = crc_calculado;
 
always@(posedge sample)
begin
				case (state)
				// IDLE STATE, ESPERA INICIO DA TRANSMISSAO
				0: begin 
				      //  reset ERROR flags
						ov_flag = 0;
						frame_data = 0;
						frame_error = 0;
						frame_overload = 0;
						frame_remote = 0;
						crcclk=0;
						start_crc = 0;
						crc_match = 0;
						crc_calculado = 15'bzzzzzzzzzzzzzzz;
						bit_classifier=2'bzz;
						frame_error=1'b0;
						frame_overload=1'b0;
						ack_error = 1'b0;
		            eof_error = 1'b0;
		            crc_error = 1'b0;						
						getframe = 1'b0; 
						getcrc = 1'b0; 
						error_flag=7'bzzzzzzz;
						// BIT 0!!!!!!
						if ( can_data_bit == 0 )
						begin
						      start_crc = 1'b1; 
						      arbitration_field = 1;
								// pegar os 11-bits ou 29-bits de arbitracao
								cont = 29;
								state = 1;
						end
						else
						// BIT 1!!!!!
						begin
						   state = 0; 
							start_crc=0;
							cont = cont + 1;  // ficar contando pra saber quantos bits '1' vem...
							if( (cont == 6) && (previous == 2'b10) )
							begin
							// detectou 6'b111111
							       // PASSIVE ERROR FLAG!
									 start_crc = 1'b0;    // para de calcular CRC!
									 frame_error = 1'b1;
									 error_type = 1'b0;   // PASSIVE ERROR !
									 cont = 7;
									 state = 14;
							end 
							/*else
							begin
							   cont = 0;
							end*/
						end
						s0 = can_data_bit; 
						// se o bit for 1, ou seja, recesivo, nao comeca transmissao!
					end
				//  start ARBITRATION -----------------------------
				// alterar para adaptar a transmissao com 29-bits
				// observacao feita por eron, colocar uma logica que pegue 11 ou 29 bits
				// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
				1: begin
				      state = 1; 
				      start_crc=0;
						arbitration[(cont-1)] = can_data_bit; 
						cont = cont - 1;
						// logica pra checar ERROR frame!
						if( cont == 24)
						begin
						    error_frame = {s0,arbitration[28:24]}; 
							 if(( error_frame == 6'b000000)  && (previous == 2'b10) )
							 begin
							       // MENSAGEM DE ERRO DETECTADA!!!!
									 // proximo passo = pegar + 7 bits....
									 ov_flag = 1'b1; 
									 start_crc = 1'b0; 
									 frame_error=1'b1;
									 error_type = 1'b1;  // ACTIVE ERROR!
									 cont = 7;
									 state = 14; 
							 end
						end 
						//-------------------------------
						if(cont == 18)  // pegou os 11-bits , saberemos depois se [11] ou [29] 3
						begin
					         state = 2; 
							   cont = 2;
						end
						      /*else 
					       	begin
						           state = 1;
					         end */
					end
				// End of ARBITRATION -----------------------------	
				// RTR bit 
				// Must be dominant (0) for data frames 
				//    and recessive (1) for remote request frames 
				2: begin
	               bit_classifier[(cont-1)] = can_data_bit;
						cont = cont - 1;
						if(cont == 0 )
						begin
				          overload_check = { arbitration[28:18] , bit_classifier};
						    if((overload_check == 13'b0000011111111))
							 begin
							     frame_overload=1'b1;
								  start_crc = 1'b0; 
								  bit_classifier = 2'b01;
								  previous = 2'b00;
								  state = 16;
							 end
							 else
							 if( bit_classifier == 2'b00 )
							 // 11-bits ID, DATA FRAME!
							 begin
							     frame_data = 1'b1;
							     bit_id_11 = arbitration[28:18];
							     state = 6; // estado para continuar...
							 end
							 else if(bit_classifier == 2'b10)
							 // 11-bits ID, REMOTE REQUEST FRAME!
							 begin
							     frame_remote = 1'b1;
							     bit_id_11 = arbitration[28:18];
							     state = 6; // estado para continuar...
							 end
							 else if(bit_classifier == 2'b11)   // OS DOIS BITs RECESSIVOS!!!
							 // 29-bits ID
							 begin
							     if((overload_check == 13'b0000011111111))
								  begin
								        frame_overload=1'b1;
								        bit_classifier = 2'b01;
								        //previous = 2'b00;
								        state = 16;
								  end
								  else
								  begin
							           cont = 18;
							           state = 3; // pega os outros 18-bits! 
								  end
							 end
						end 
					end
				// estado para pegar os bits restantes do 29-bit ID!
				3: begin
						arbitration[(cont-1)] = can_data_bit; 
						cont = cont - 1;                 
						if(cont == 0)
						begin
						   bit_id_29[28:0] = arbitration[28:0];
						   state = 44; // acabou de pegar todos os 29-bits do ID!
						end
						else
						   state = 3; // continua pegando os bits do ID........
					end
            // (11) , pega bit para classificar frame!	 - APENAS P/ 11-BIT				
				4: begin
	               if( can_data_bit == 1 )
						begin
						// remote rquest frame
						frame_remote = 1'b1;
						end
						else
						begin
						// data frame!
						frame_data = 1'b1;
						end 
						state=15;
					end
				// (29), pega bit para classificar fram! - apenas P/ 29-bit
				44: begin
	               if( can_data_bit == 1 )
						begin
						// remote rquest frame
						frame_remote = 1'b1;
						end
						else
						begin
						// data frame!
						frame_data = 1'b1;
						end 
						state=5;
					end
				// (29) dois bits que podem ser qualquer coisa...
				5: begin
				      state = 6;
				   end
			   6: begin
				      cont = 4;
				      state = 7;
				   end
				// ------->>> NUMBER OF BYTES OF DATA!!! <<<<< ------------
				7: begin
						nbytes[(cont-1)] = can_data_bit; 
						cont = cont - 1;
						if( (cont == 0) && (nbytes>0) )
						begin
						    cont = (8*nbytes);
							 if(frame_remote)
							 begin
							       can_data = 64'bz; 
									 cont = 15;
									 getcrc = 1'b1; 
							       crc_calculado = crc;
							       state = 9;     // REMOTE FRAME!!!!!!
							 end
							 else
							 begin
							       state = 8;     // go to get DATA bits
							 end
						end 
		            else
						begin
						    state = 7;
						end
					end			
				// ----- end of NUMBER of BYTES ----------------------------
				// -----> BEGIN OF DATA <-----------------------------------
				8: begin
				       can_data[(cont-1)] = can_data_bit; 
                   cont = cont - 1;
						 if( cont == 0)
						 begin
						    // PEGA O CRC!!!!!
							 getcrc = 1'b1; 
							 crc_calculado = crc;
						    cont = 15;
						    state = 9;   // go to CRC field...
						 end 
					end
				// -------------- CRC FIELD ---------------------------
				9: begin
	               getcrc=0;
                  crc_field[(cont-1)] = can_data_bit; 
						cont = cont - 1;
						if (cont == 0)
						begin
						    crcclk = 1;
						    // checa o CRC!
							 if( crc_calculado == crc_field)
							 begin
							      crc_match = 1'b1;
							 end
							 else
							 begin
							      crc_match = 1'b0;
							 end
							 //
						    state = 10;
						end
						else
						begin
						   state = 9;
						end
					end	
				// -------------- CRC  DELIMITER ---------------------------
				10: begin
				       crcclk = 0;
						 if( can_data_bit == 1)
						 begin
						    // nao deu erro!
							 crc_error = 1'b0;
							 state = 11;
						 end
						 else
						 begin
						    // error!!!
							 crc_error = 1'b1; 
							 state = 11;
						 end
					end
				// -------------- ACK slot  --------------------------------
				// deixa em aberto....
				11: begin
						// ???
						state=12;
					end				
				// -------------- ACK delimiter ---------------------------					
				12: begin
						if( can_data_bit == 1)
						begin
						    ack_error = 1'b0;  // NAO TEM ERRO!
							 cont = 0;
							 state = 13;
						end
						else
						begin
							ack_error = 1'b1;   // ACK_ERROR!!!!
							cont = 0;
							state = 13;
						end
						//
					end
				// -------------- EOF - 7-bits -----------------------------
				// todos os 7-bits devem ser RECESSIVOS '1'
				13: begin
						if(can_data_bit == 1)
						begin
						     cont = cont + 1;
							  if(cont == 7)
							  begin
							     getframe = 1'b1; 
								  cont = 0;
							     state = 0;  // go to IDLE state!
							  end
						end
						else
						begin
						    eof_error = 1'b1;
						end
						
						if( frame_data == 1'b1)
						begin
						     previous = 2'b10;  // FRAME anterior eh DATA!
						end 
						if ( frame_remote == 1'b1)
						begin
						     previous = 2'b11;  // FRAME anterior eh REMOTE
						end 
					end
				// aconteceu erro! esse etsado pega o ERROR FLAG!
            14: begin
						 error_flag[(cont-1)] = can_data_bit; 
                   cont = cont - 1;
						 if( cont == 0)
						 begin
						    cont = 0;
						    state = 15;   // proximo passo = ERROR DELIMITER!
						 end 
				     
                end	
			   // ERROR DELIMITER = 8'hFF - 8bits recessivos!!!!
            15: begin
				       eof_error = 1'b0; 
						 
				       if( can_data_bit == 1'b1)
						 begin
						      cont = cont + 1'b1;
						 end
						 else
						 begin
						       eof_error = 1'b1;
						 end
						 
						 if( cont == 8 )
						 begin
						     cont = 0;
							  getframe = 1'b1; 
						     state = 16;
						 end
						 else
						 begin
						     state = 15;
						 end
                end
				 // tem que esperar ciclo de 3-bits para proximo passo........
             16: begin
				       cont = cont + 1;
						 if ( cont == 3)
						 begin
						     state = 0;
						 end
                 end				 
			   // priority logic
				default: state=34;
			endcase
		end
endmodule 
