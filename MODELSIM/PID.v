module PID(
	input i_Clk,
	input [13:0]number_of_pulses,
	input [4:0]SW,
	input PID_timer,
	output reset_nop_0,
	input reset,
	output [13:0]signal_dc,
	input [35:0] KP,
	input [35:0] KI,
	input [35:0] KD,
	///////DEBUG///////
	output [2:0]state_pid
	///////////////////
);

	reg reset_nop;
	assign reset_nop_0 = reset_nop;

	reg [2:0]PID_STATE;
	reg [35:0]sample_data;
	wire [35:0]mult_out_0, mult_out_1, mult_out_2, mult_out_3;
	reg [35:0]mult_out_0_reg, mult_out_1_reg, mult_out_2_reg, mult_out_3_reg;
	wire [71:0]mult_step_0, mult_step_1, mult_step_2, mult_step_3;
	reg [35:0]current_speed, desired_speed;
	reg [35:0]e_speed ,e_speed_pre, e_speed_sum, e_speed_de, pwm_pulse;
	reg [13:0]dc_out;
	
	///////DEBUG///////
	assign state_pid = PID_STATE;
	///////////////////
	
	parameter	WAIT_TIME = 3'd0,
				CALCULATE_PWM_0 = 3'd1,
				CALCULATE_PWM_1 = 3'd2,
				CALCULATE_PWM_2 = 3'd3,
				CALCULATE_PWM_3 = 3'd4,
				CALCULATE_PWM_4 = 3'd5,
				CALCULATE_PWM_5 = 3'd6,
				LIMIT_CHECK = 3'd7;
	/*
	parameter 	FP_36_9_d10 = 36'b1010_000_000_000,
					KP = 36'b0_1011_1111_1010_000_000_000,
					KI = 36'b0_1111_1101_1010_000_000_000,
					KD = 36'b0_1111_1111_1001_000_000_000;
	*/				
	// FIXED POINT NUMBERS 36 BIT, 1 SIGN 26 DECIMAL 9 FRACTION
	///////////////////////////////////////////////////
	
	//pwm_pulse = e_speed*kp + e_speed_sum*ki + e_speed_de*kd;
	assign signal_dc = dc_out;
	
	always@(posedge i_Clk) 
	begin	
		case(PID_STATE)
			WAIT_TIME: begin
				if(reset)begin
					PID_STATE <= WAIT_TIME;	
					reset_nop <= 1'b1;					
					e_speed_pre <= 0;
					e_speed <= 0;
					e_speed_sum <= 0;
					pwm_pulse <= 0;
					dc_out <= 0;
				end
				else if(PID_timer)begin
					sample_data <= {1'b0, 12'b0, number_of_pulses, 9'b0};
					desired_speed <= {1'b0, 21'b0, SW[4:0], 9'b0};
					reset_nop <= 1'b1;
					PID_STATE <= CALCULATE_PWM_0;
				end
				else begin
					reset_nop <= 1'b0;
					PID_STATE <= WAIT_TIME;
					dc_out <= pwm_pulse[22:9];
				end
			end
			CALCULATE_PWM_0: begin
				mult_out_0_reg <= mult_out_0;
				PID_STATE <= CALCULATE_PWM_1;
			end
			CALCULATE_PWM_1: begin
				current_speed <= mult_out_0_reg >>  9;
				PID_STATE <= CALCULATE_PWM_2;
			end
			CALCULATE_PWM_2: begin
				e_speed <= desired_speed - current_speed;
				PID_STATE <= CALCULATE_PWM_3;
			end
			CALCULATE_PWM_3: begin
				mult_out_1_reg <= mult_out_1;
				mult_out_2_reg <= mult_out_2;
				e_speed_de <= (e_speed - e_speed_pre);
				PID_STATE <= CALCULATE_PWM_4;
			end
			CALCULATE_PWM_4: begin
				mult_out_3_reg <= mult_out_3;
				pwm_pulse <= mult_out_2_reg + mult_out_1_reg;
				PID_STATE <= CALCULATE_PWM_5;
			end
			CALCULATE_PWM_5: begin
				pwm_pulse <= pwm_pulse + mult_out_3_reg;
				e_speed_pre <= e_speed;  				//save last (previous) error
				e_speed_sum <= e_speed_sum + e_speed; 	//sum of error
				PID_STATE <= LIMIT_CHECK;
			end
			LIMIT_CHECK: begin
				if(pwm_pulse[22:9] > 14'd10_000) begin
					pwm_pulse[22:9] <= 14'd10_000;
				end
				PID_STATE <= WAIT_TIME;
			end
			default: begin
				PID_STATE <= WAIT_TIME;
			end
		endcase
	end
	
	assign mult_step_0 = $signed(sample_data) * $signed(FP_36_9_d10);
	assign mult_out_0 = {mult_step_0[71], mult_step_0[43:9]};
	
	assign mult_step_1 = $signed(e_speed) * $signed(KP);
	assign mult_out_1 = {mult_step_1[71], mult_step_1[43:9]};
	
	assign mult_step_2 = $signed(e_speed_sum) * $signed(KI);
	assign mult_out_2 = {mult_step_2[71], mult_step_2[43:9]};
	
	assign mult_step_3 = $signed(e_speed_de) * $signed(KD);
	assign mult_out_3 = {mult_step_3[71], mult_step_3[43:9]};
	
	///////DEBUG///////
	wire [26:0]sample_data_D;
	wire [26:0]mult_out_0_reg_D, mult_out_1_reg_D, mult_out_2_reg_D, mult_out_3_reg_D;
	wire [26:0]current_speed_D, desired_speed_D;
	wire [26:0]e_speed_D ,e_speed_pre_D, e_speed_sum_D, e_speed_de_D;
	wire [26:0]KP_D, KI_D, KD_D;
	assign sample_data_D = sample_data[35:9];
	
	assign mult_out_0_reg_D = mult_out_0_reg[35:9];
	assign mult_out_1_reg_D = mult_out_1_reg[35:9];
	assign mult_out_2_reg_D = mult_out_2_reg[35:9];
	assign mult_out_3_reg_D = mult_out_3_reg[35:9];
	
	assign current_speed_D = current_speed[35:9];
	assign desired_speed_D = desired_speed[35:9];
	
	assign e_speed_D = e_speed[35:9];
	assign e_speed_pre_D = e_speed_pre[35:9];
	assign e_speed_sum_D = e_speed_sum[35:9];
	assign e_speed_de_D = e_speed_de[35:9];
	
	assign KP_D = KP[35:9];
	assign KI_D = KI[35:9];
	assign KD_D = KD[35:9];
	//////////////////////////////////////
endmodule