
# Timing Specification Constraints

create_clock -name i_Clk -period 20.000000ns -waveform {0.0ns 10.000000ns} [get_ports {i_Clk}]
derive_pll_clocks
derive_clock_uncertainty
