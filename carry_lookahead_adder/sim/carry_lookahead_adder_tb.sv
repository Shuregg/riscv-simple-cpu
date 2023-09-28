`timescale 1ns / 1ps
module carry_lookahead_adder_tb();

  logic [31:0] A;
  logic [31:0] B;
  logic [31:0] RES;

  carry_lookahead_adder fast_carry_adder_inst
    (
      .oper1_i(A),
      .oper2_i(B),
      .sum_o(RES)
    );
    
    initial begin
      A = 32'd1;
      B = 32'd1;
      #20
      A = 32'd6;
      B = 32'd4;
      #20
      A = 32'd15;
      B = 32'd1;
      #20
      A = 32'd31;
      B = 32'd5;
      #20
      A = 32'd9;
      B = 32'd2;
      #20
      A = 32'd4;
      B = 32'd4;
      #20
      A = 32'd6;
      B = 32'd4;
    end
endmodule
