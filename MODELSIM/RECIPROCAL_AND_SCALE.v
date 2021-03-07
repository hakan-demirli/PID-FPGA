// -------------------------------------------------------------
// 
// File Name: hdl_prj\hdlsrc\untitled\RECIPROCAL_AND_SCALE.v
// Created: 2021-03-05 04:02:09
// 
// Generated by MATLAB 9.9 and HDL Coder 3.17
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: RECIPROCAL_AND_SCALE
// Source Path: untitled/CONVERT_AND_SCALE/RECIPROCAL_AND_SCALE
// Hierarchy Level: 1
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module RECIPROCAL_AND_SCALE
          (clk,
           reset_x,
           enb,
           enb_const_rate,
           In1,
           Out1);


  input   clk;
  input   reset_x;
  input   enb;
  input   enb_const_rate;
  input   [63:0] In1;  // ufix64
  output  signed [35:0] Out1;  // sfix36_En14


  wire signed [35:0] kconst;  // sfix36_En18
  reg signed [35:0] kconst_1;  // sfix36_En18
  wire signed [63:0] Constant1_out1;  // sfix64
  wire signed [64:0] Relational_Operator_1_1;  // sfix65
  wire signed [64:0] Relational_Operator_1_2;  // sfix65
  wire Relational_Operator_relop1;
  wire signed [63:0] In1_dtc;  // sfix64
  wire signed [63:0] Constant4_out1;  // sfix64
  wire signed [63:0] Switch_out1;  // sfix64
  reg signed [35:0] Reciprocal_out1;  // sfix36_En30
  reg signed [35:0] Reciprocal_out1_1;  // sfix36_En30
  wire signed [71:0] Multiply1_mul_temp;  // sfix72_En48
  wire signed [35:0] Multiply1_out1;  // sfix36_En14
  reg signed [35:0] Multiply1_out1_1;  // sfix36_En14
  reg signed [63:0] Reciprocal_c;  // sfix64_En30
  reg signed [63:0] Reciprocal_div_temp;  // sfix64_En30


  assign kconst = 36'sh61A800000;



  always @(posedge clk or posedge reset_x)
    begin : HwModeRegister_process
      if (reset_x == 1'b1) begin
        kconst_1 <= 36'sh000000000;
      end
      else begin
        if (enb) begin
          kconst_1 <= kconst;
        end
      end
    end



  assign Constant1_out1 = 64'sh00000000000186A0;



  assign Relational_Operator_1_1 = {1'b0, In1};
  assign Relational_Operator_1_2 = {Constant1_out1[63], Constant1_out1};
  assign Relational_Operator_relop1 = Relational_Operator_1_1 > Relational_Operator_1_2;



  assign In1_dtc = In1;



  assign Constant4_out1 = 64'sh0DE0B6B3A7640000;



  assign Switch_out1 = (Relational_Operator_relop1 == 1'b0 ? In1_dtc :
              Constant4_out1);



  always @(Switch_out1) begin
    Reciprocal_div_temp = 64'sh0000000000000000;
    if (Switch_out1 == 64'sh0000000000000000) begin
      Reciprocal_c = 64'sh7FFFFFFFFFFFFFFF;
    end
    else begin
      Reciprocal_div_temp = 32'sb01000000000000000000000000000000 / Switch_out1;
      Reciprocal_c = Reciprocal_div_temp;
    end
    if (Switch_out1 == 64'sh0000000000000000) begin
      Reciprocal_out1 = 36'sh7FFFFFFFF;
    end
    else if ((Reciprocal_c[63] == 1'b0) && (Reciprocal_c[62:35] != 28'b0000000000000000000000000000)) begin
      Reciprocal_out1 = 36'sh7FFFFFFFF;
    end
    else if ((Reciprocal_c[63] == 1'b1) && (Reciprocal_c[62:35] != 28'b1111111111111111111111111111)) begin
      Reciprocal_out1 = 36'sh800000000;
    end
    else begin
      Reciprocal_out1 = Reciprocal_c[35:0];
    end
  end



  always @(posedge clk or posedge reset_x)
    begin : HwModeRegister1_process
      if (reset_x == 1'b1) begin
        Reciprocal_out1_1 <= 36'sh000000000;
      end
      else begin
        if (enb_const_rate) begin
          Reciprocal_out1_1 <= Reciprocal_out1;
        end
      end
    end



  assign Multiply1_mul_temp = kconst_1 * Reciprocal_out1_1;
  assign Multiply1_out1 = Multiply1_mul_temp[69:34];



  always @(posedge clk or posedge reset_x)
    begin : PipelineRegister_process
      if (reset_x == 1'b1) begin
        Multiply1_out1_1 <= 36'sh000000000;
      end
      else begin
        if (enb) begin
          Multiply1_out1_1 <= Multiply1_out1;
        end
      end
    end



  assign Out1 = Multiply1_out1_1;

endmodule  // RECIPROCAL_AND_SCALE

