module TIMER(
	input clk,
	input reset_timer,
	output [63:0]counter_timer,
	output overflow
);
	reg [63:0]counter_timer_0;
	reg overflow_0;
	assign counter_timer = counter_timer_0;
	assign overflow = overflow_0;
	always@(posedge clk)
	begin
		if(reset_timer)
		begin
			counter_timer_0 <= 64'b0;
			overflow_0 <= 1'b0;
		end
		else if(counter_timer_0 == 64'hFFFF_FFFF_FFFF_FFFF)
			overflow_0 <= 1'b1;
		else
		begin
			counter_timer_0 <= counter_timer_0 + 64'b1;
			overflow_0 <= 1'b0;
		end
	end
endmodule