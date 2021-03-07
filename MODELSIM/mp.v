`timescale 1 ns / 100 ps
module mp();

reg CLOCK_50;
reg CLOCK_100;
reg CLOCK_3;
always #10 CLOCK_50 = ~CLOCK_50;
always #5 CLOCK_100 = ~CLOCK_100;
always #166666.6 CLOCK_3 = ~CLOCK_3;

initial
begin
	CLOCK_100 = 1;
	CLOCK_50 = 1;
	CLOCK_3 = 1;
end
//######## DUT AREA ###########
//######## DUT AREA ###########
reg direction;
wire uart_tx;
wire pwm;
reg [14:0]SW;
//wire [13:0]signal_dc;
initial
begin
	direction = 1;
	SW = 0;
	#5 SW[14] = 1;
	#100 SW = 15'b1111_1111_1111_111;
	#5 SW = 0;
	#5 SW = 15'b0111_1111_1111_111;
	#1000 direction = 0;
	#1000 direction = 1;
	#2000 direction = 0;
	#1000 direction = 0;
end

MOTOR DUT_MOTOR(
	.CLK(CLOCK_3),
	.direction(direction),
	.oA(oA),
	.oB(oB)
); 


	//wire [2:0]stateTX;
	//.state_TX_0(stateTX),
	//.signal_dc(signal_dc)

wire [2:0]state_pid;
TOP DUTTOP(
	.i_Clk(CLOCK_50),
	.o_UART_TX(uart_tx),
	.LEDG(),
	.GPIO_AB({oA,oB}), // GPIO_AB[0] = A, GPIO_AB[1] = B
	.GPIO_PWM(pwm),
	.SW(SW),
	.state_pid(state_pid)
);
 
//reg ce;

	///////////////////////////////////
	////////// PID CONTROL ////////////
	///////////////////////////////////
	

/*
module mp(
	input [15:0]audio_inR,
	output toggle_w,
	input CLOCK_50
);
reg toggle;
reg [15:0]audio_inR_previous;
assign toggle_w = toggle;

always@(posedge CLOCK_50)
begin
	audio_inR_previous <= audio_inR;
	
	if(audio_inR != audio_inR_previous)
	begin
		toggle <= ~toggle;
	end
	else
		toggle <= toggle;
end
	


endmodule
*/


////////////////////////////////////
///////////STATE MACHINE DEBUG/////
////////////////////////////////////

parameter	WAIT_TIME = 3'd0,
			CALCULATE_PWM_0 = 3'd1,
			CALCULATE_PWM_1 = 3'd2,
			CALCULATE_PWM_2 = 3'd3,
			CALCULATE_PWM_3 = 3'd4,
			CALCULATE_PWM_4 = 3'd5,
			CALCULATE_PWM_5 = 3'd6,
			LIMIT_CHECK = 3'd7;

reg [13*8-1:0] next_state;				 
always@(state_pid) begin 
    case(state_pid) 
		WAIT_TIME		: next_state 		= "WAIT_TIME";
		CALCULATE_PWM_0	: next_state 		= "CALCULATE_PWM_0";
		CALCULATE_PWM_1	: next_state 		= "CALCULATE_PWM_1";
		CALCULATE_PWM_2	: next_state 		= "CALCULATE_PWM_2";
		CALCULATE_PWM_3	: next_state		= "CALCULATE_PWM_3";		 
		CALCULATE_PWM_4	: next_state		= "CALCULATE_PWM_4";
		CALCULATE_PWM_5	: next_state		= "CALCULATE_PWM_5";
		LIMIT_CHECK	: next_state			= "LIMIT_CHECK";
		default			: next_state 		= "UNKNOWN";
     endcase
 end
 
endmodule
