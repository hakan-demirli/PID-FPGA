module PWM(
input clk,
output PWM_signal,
input [13:0]DC
);

 
parameter PWM_ONE = 14'b1;
parameter PWM_ZERO = 14'b0;
reg [13:0]PWM_counter;

reg PWM_signal_0;
assign PWM_signal = PWM_signal_0;
////parameter DUTY_CYCLE = 12'b0001_1111_0100; //%25 dtycycle
parameter RESOLUTION = 14'b10_0111_0001_0000; //10000 dtycycle>> 5khz

always@(posedge clk)
begin
	if(PWM_counter < RESOLUTION)
		PWM_counter <= PWM_counter + PWM_ONE;
	else
		PWM_counter <= PWM_ZERO;
	
	if((PWM_counter <= DC) && (PWM_counter != 14'b0))
		PWM_signal_0 <= 1'b1;
	else 
		PWM_signal_0 <= 1'b0;
end
endmodule