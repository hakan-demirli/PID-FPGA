module MOTOR(
	input CLK,
	input direction,//direction 1 clockwise, direction 0 counter clockwise
	output oA,
	output oB	//50ms period//50000000ns
);

parameter S0 = 2'b00,
		  S1 = 2'b10,
		  S2 = 2'b11,
		  S3 = 2'b01;

reg [1:0] state;
assign oB = state[0];
assign oA = state[1];

always@(posedge CLK)//every 1/CLK ns
begin
	case(state)
		S0:
		begin
			if(direction == 1)
				state <= S1;
			else
				state <= S3;
		end
		S1:
		begin
			if(direction == 1)
				state <= S2;
			else
				state <= S0;
		end		
		S2:
		begin
			if(direction == 1)
				state <= S3;
			else
				state <= S1;
		end		
		S3:
		begin
			if(direction == 1)
				state <= S0;
			else
				state <= S2;
		end		
		default:
			state <= 2'b00;
	endcase
end

endmodule
