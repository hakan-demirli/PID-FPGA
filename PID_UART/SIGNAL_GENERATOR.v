
module SIGNAL_GENERATOR(
	output [13:0]signal_dc,
	input SW,
	input i_Clk
);
parameter WAIT = 1'b0,
		  OUT = 1'b1;
reg siggen_state;
reg [13:0]signal_dc_0;
assign signal_dc = signal_dc_0;

reg [23:0]counter;
reg [3:0]signal_state;

always@(posedge i_Clk)
begin
	case(siggen_state)
	WAIT:begin
		counter <= 0;
		if(SW == 1'b1)
			siggen_state <= OUT;
		else
			siggen_state <= WAIT;
	end
	OUT:begin
		if(signal_state == 4'd14)begin
			counter = 24'b0;
			signal_state = 4'b0;
			siggen_state <= WAIT;
		end
		else if(counter  == 24'd5_000_000)begin
			counter = 24'b0;
			signal_state <= signal_state + 4'b1;
			siggen_state <= OUT;
		end
		else begin
			siggen_state <= OUT;
			counter = counter + 24'b1;
		end
	end
	default: begin
			signal_state <= 4'd0;
			siggen_state <= WAIT;
	end
	endcase
end

always@(posedge i_Clk)//SIGNALS
begin
	case(signal_state)
	4'd0:	signal_dc_0 = 14'h0000;
	4'd1:	signal_dc_0 = 14'h2707;
	4'd2:	signal_dc_0 = 14'h06AF;
	4'd3:	signal_dc_0 = 14'h0146;
	4'd4:	signal_dc_0 = 14'h15EC;
	4'd5:	signal_dc_0 = 14'h2273;
	4'd6:	signal_dc_0 = 14'h2710;
	4'd7:	signal_dc_0 = 14'h0770;
	4'd8:	signal_dc_0 = 14'h0E69;
	4'd9:	signal_dc_0 = 14'h11FF;
	4'd10:	signal_dc_0 = 14'h2658;
	4'd11:	signal_dc_0 = 14'h061C;
	4'd12:	signal_dc_0 = 14'h216B;
	4'd13:	signal_dc_0 = 14'h1930;
	default:
		signal_dc_0 = 14'h0000;
	endcase
end
endmodule//END OF SIGNAL_GENERATOR

////////////////////////////////////////
///////////COPY PASTE TRASH/////////////
//////////////DONT CARE/////////////////
////////////////////////////////////////
/*
Original_input_1 = 
	4'd0: 	signal_dc_0 = 14'h0000;
	4'd1: 	signal_dc_0 = 14'h0762;
	4'd2: 	signal_dc_0 = 14'h1AD4;
	4'd3: 	signal_dc_0 = 14'h072B;
	4'd4: 	signal_dc_0 = 14'h0E65;
	4'd5:	signal_dc_0 = 14'h1870;
	4'd6:	signal_dc_0 = 14'h2710;
	4'd7: 	signal_dc_0 = 14'h032B;
	4'd8: 	signal_dc_0 = 14'h244E;
	4'd9: 	signal_dc_0 = 14'h1E4D;
	4'd10: 	signal_dc_0 = 14'h1304;
	4'd11: 	signal_dc_0 = 14'h1107;
	4'd12: 	signal_dc_0 = 14'h1174;
	4'd13: 	signal_dc_0 = 14'h0BF7;




				//delayed_signal[0] <= number_of_ticks[0];
//				delayed_signal[1] <= number_of_ticks[1];
	//			delayed_signal[2] <= number_of_ticks[2];
		//		delayed_signal[3] <= number_of_ticks[3];
			//	delayed_signal[4] <= number_of_ticks[4];
				//delayed_signal[5] <= number_of_ticks[5];
				//delayed_signal[6] <= number_of_ticks[6];
				//delayed_signal[7] <= number_of_ticks[7];







*/
