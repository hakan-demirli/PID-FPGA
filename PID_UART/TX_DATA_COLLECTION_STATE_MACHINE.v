module TX_DATA_COLLECTION_STATE_MACHINE(
	input i_Clk,
	input [63:0]number_of_ticks,
	input w_TX_Active,
	output w_TX_DV,
	output [7:0]w_TX_Byte_reg
);
				
	reg [3:0]byte_counter;
	reg [7:0]store_nt[7:0];
	reg [7:0]w_TX_Byte_reg_0;
	reg [2:0]state_TX;
	reg w_TX_DV_0;

	parameter	WAIT_TX = 3'd0,
					START = 3'd1,
					SEND = 3'd2,
					DATA_VALID = 3'd3,
					WAIT_DONE = 3'd4,
					WAIT_CYCLE = 3'd5;
					
	assign w_TX_Byte_reg = w_TX_Byte_reg_0;
	assign w_TX_DV = w_TX_DV_0;
	
	always@(posedge i_Clk)
	begin
		case(state_TX)
			WAIT_TX: begin
				w_TX_DV_0 <= 1'b0;
				if(w_TX_Active == 1'b1)
					state_TX <= WAIT_TX;
				else
					state_TX <= START;
			end
			START: begin
				store_nt[0] <= 8'hBB;
				store_nt[1] <= number_of_ticks[7:0];
				store_nt[2] <= number_of_ticks[15:8];
				store_nt[3] <= number_of_ticks[23:16];
				store_nt[4] <= number_of_ticks[31:24];
				store_nt[5] <= number_of_ticks[39:32];
				store_nt[6] <= number_of_ticks[47:40];
				store_nt[7] <= 8'hAA;
				
				byte_counter <= 4'b0;
				w_TX_DV_0 <= 1'b0;
				state_TX <= SEND;
			end
			SEND: begin
				if(byte_counter != 4'd8) begin
					w_TX_Byte_reg_0 <= store_nt[byte_counter];
					w_TX_DV_0 <= 1'b0;
					state_TX <= DATA_VALID;
				end
				else begin
					w_TX_DV_0 <= 1'b0;
					byte_counter <= 4'b0;
					state_TX <= WAIT_TX;
				end
			end
			DATA_VALID: begin
				w_TX_DV_0 <= 1'b1;
				state_TX <= WAIT_CYCLE;
			end
			WAIT_DONE: begin
				if(w_TX_Active == 1'b1)begin
					state_TX <= WAIT_CYCLE;
					w_TX_DV_0 <= 1'b0;
				end
				else begin
					byte_counter <= byte_counter + 4'b1;				
					w_TX_DV_0 <= 1'b0;
					state_TX <= SEND;
				end
			end
			WAIT_CYCLE:
				state_TX <= WAIT_DONE;
			default:
				state_TX <= WAIT_TX;
		endcase
	end
	endmodule