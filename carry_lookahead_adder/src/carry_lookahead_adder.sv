`timescale 1ns / 1ps

module carry_lookahead_adder
    (
        input logic     [32-1:0]     oper1_i,
        input logic     [32-1:0]     oper2_i,
        
        output logic    [32-1:0]     sum_o
    );
    
  parameter WIDTH = 32;
  logic [WIDTH:0] C; //Carry
  logic [WIDTH-1:0] G, P, SUM;  //G[i] = A[i] & B[i] //P[i] = A[i] | B[i]
  
  assign C[0] = 1'b0;
  assign sum_o = SUM;
  
  genvar i;
  generate
    for(i = 0; i < WIDTH; i = i + 1) begin
      fulladder full_adder_inst
        (
            .a_i(oper1_i[i]),
            .b_i(oper2_i[i]),
            .carry_i(C[i])  ,
            .carry_o()      ,
            .sum_o(SUM[i])
        );
        assign G[i]     = oper1_i[i] & oper2_i[i];
        assign P[i]     = oper1_i[i] | oper2_i[i];
        assign C[i+1]   = G[i] | (P[i] & C[i]);
    end
  endgenerate
endmodule
