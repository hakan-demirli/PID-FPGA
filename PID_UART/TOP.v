module TOP(
	input 			i_Clk,
	input 			i_UART_RX,
	output			o_UART_TX,
	output [7:0]	LEDG,
	input  [1:0]	GPIO_AB, // GPIO_AB[0] = A, GPIO_AB[1] = B
	output 			GPIO_PWM,
	input [14:0]	SW
	///////DEBUG///////
	//output [2:0]state_pid
	//output state_TX_0,
	//output signal_dc
);

	///////////////////////////////////
	////////////// DEBUG //////////////
	///////////////////////////////////
	//wire i_UART_RX;
	
	///////////////////////////////////
	////////////// UART ///////////////
	///////////////////////////////////
	reg [7:0]led;
	assign LEDG = led;
	
	wire 		done;
	wire 		w_RX_DV;
	wire 		w_TX_DV;
	wire 		w_TX_DV_0;
	wire [7:0]	w_RX_Byte;
	wire [7:0]	w_TX_Byte;
	wire 		w_TX_Active, w_TX_Serial;
	
	assign w_TX_DV = w_TX_DV_0 && SW[14];
  // 50,000,000 / 115,200 = 434
  UART_RX #(.CLKS_PER_BIT(434)) UART_RX_Inst
  (.i_Clock(i_Clk),
   .i_RX_Serial(i_UART_RX),
   .o_RX_DV(w_RX_DV),
   .o_RX_Byte(w_RX_Byte));
    
  UART_TX #(.CLKS_PER_BIT(434)) UART_TX_Inst
  (.i_Clock(i_Clk),
   .i_TX_DV(w_TX_DV),			// Data Ready, Start the transfer by driving this high.
   .i_TX_Byte(w_TX_Byte),		// Data, To be send.
   .o_TX_Active(w_TX_Active),	// TX is in use when high.
   .o_TX_Serial(w_TX_Serial),	// Physical serial wire that transfer the data.
   .o_TX_Done(done));			// High for one cycle after the transfer.
   
	assign o_UART_TX = w_TX_Active ? w_TX_Serial : 1'b1; 
	// Drive UART line high when transmitter is not active
	
	reg [63:0]number_of_ticks;
	TX_DATA_COLLECTION_STATE_MACHINE TXDCSM_0(
		.i_Clk(i_Clk),
		.number_of_ticks(number_of_ticks),
		.w_TX_Active(w_TX_Active),
		.w_TX_DV(w_TX_DV_0),
		.w_TX_Byte_reg(w_TX_Byte)
	);
/*
	always@(posedge i_Clk)
	begin
		//w_TX_DV <= w_RX_DV;// for echo, connect the data too.
	end
	*/
	///////////////////////////////////

	///////////////////////////////////
	/////////////// PWM ///////////////
	///////////////////////////////////
	wire [13:0]signal_dc;
	PWM pwm_0(.clk(i_Clk),
				.PWM_signal(GPIO_PWM),
				.DC(signal_dc));
/*
	SIGNAL_GENERATOR sg_0(
	.signal_dc(signal_dc),
	.SW(SW[14]),
	.i_Clk(i_Clk)
	);
				*/
	reg reset;
	reg [7:0]FIFO[7:0];
	reg [35:0] KI, KP, KD;
	always@(posedge i_Clk)
	begin
		if(w_RX_DV) begin
			FIFO[7] <= FIFO[6];
			FIFO[6] <= FIFO[5];
			FIFO[5] <= FIFO[4];
			FIFO[4] <= FIFO[3];
			FIFO[3] <= FIFO[2];
			FIFO[2] <= FIFO[1];
			FIFO[1] <= FIFO[0];
			FIFO[0] <= w_RX_Byte;
		end
		else if((FIFO[7] == 8'hAA) && (FIFO[0] == 8'hBB)) begin
			led <= KD[7:0];
			if(FIFO[6] == 8'd0) begin
				reset <= 1'b1;
			end
			else if(FIFO[6] == 8'd1) begin
				KP <= {FIFO[5][3:0],FIFO[4],FIFO[3],FIFO[2],FIFO[1]};
			end
			else if(FIFO[6] == 8'd2) begin
				KD <= {FIFO[5][3:0],FIFO[4],FIFO[3],FIFO[2],FIFO[1]};
			end
			else if(FIFO[6] == 8'd3) begin
				KI <= {FIFO[5][3:0],FIFO[4],FIFO[3],FIFO[2],FIFO[1]};
			end
			else begin
				reset <= 1'b0;
			end
		end
	end
	///////////////////////////////////

	///////////////////////////////////
	///////////// TIMERS //////////////
	///////////////////////////////////
	reg reset_timer_0;
	wire [63:0]counter_timer_0;
	wire timer_0_overflow;
	
	TIMER timer_0(	.clk(i_Clk),
					.reset_timer(reset_timer_0),
					.counter_timer(counter_timer_0),
					.overflow(timer_0_overflow));

	reg reset_timer_1;
	wire [63:0]counter_timer_1;
	wire timer_1_overflow;
	TIMER timer_1(	.clk(i_Clk),
					.reset_timer(reset_timer_1),
					.counter_timer(counter_timer_1),
					.overflow(timer_1_overflow));
										
	///////////////////////////////////
	
	///////////////////////////////////
	//////// SPEED CALCULATIONS ///////
	///////////////////////////////////
	//integer i;
	reg [1:0]GPIO_AB_p;
	reg [1:0]GPIO_AB_c;
	reg [13:0]number_of_pulses;
	wire reset_nop_0;
	reg reset_nop_1;
	
	always@(posedge i_Clk) begin
		GPIO_AB_c <= GPIO_AB;
		GPIO_AB_p <= GPIO_AB_c;
		reset_nop_1 <= reset_nop_0;
		if(reset_nop_1) begin
			number_of_pulses <= 0;
		end
		else begin
			if(GPIO_AB_c[0] == 1'b1 && 1'b0 == GPIO_AB_p[0])
			begin
				number_of_pulses = number_of_pulses + 14'b1;
				number_of_ticks <= counter_timer_0;
				reset_timer_0 <= 1'b1;
			end
			else begin
				reset_timer_0 <= 1'b0;
			end
		end
	end
	///////////////////////////////////
		
	///////////////////////////////////
	////////// PID CONTROL ////////////
	///////////////////////////////////
	reg PID_timer;
	PID PID_0(
		.i_Clk(i_Clk),
		.number_of_pulses(number_of_pulses),
		.SW(SW[4:0]),
		.PID_timer(PID_timer),
		.reset_nop_0(reset_nop_0),
		.reset(reset),
		.signal_dc(signal_dc),
		.KP(KP),
		.KI(KI),
		.KD(KD)
		/////DEBUG//////
		//.state_pid(state_pid)
	);
	
	parameter HUNDERED_MILISECONDS = 64'd5_000_000;
	always@(posedge i_Clk)begin
		if(reset) begin
			reset_timer_1 <= 1'b1;
		end
		else if(counter_timer_1 == HUNDERED_MILISECONDS) begin
			PID_timer <= 1'b1;
			reset_timer_1 <= 1'b1;
		end
		else begin
			PID_timer <= 1'b0;
			reset_timer_1 <= 1'b0;
		end
	end
	
endmodule

////////////////////////////////////////
///////////COPY PASTE TRASH/////////////
//////////////DONT CARE/////////////////
////////////////////////////////////////
/*

*/