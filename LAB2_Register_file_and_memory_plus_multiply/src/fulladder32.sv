module fulladder32(
 input  logic [31:0]  a_i
,input  logic [31:0]  b_i
,input  logic         carry_i
,output logic [31:0]  sum_o
,output logic         carry_o
);
  parameter N = 32;
  logic [N-1:0] carry_tmp;
  genvar i;
  generate
    for(i = 0; i < N; i = i + 1) begin : generate_32_bit_Adder
      if(i == 0)
        fulladder adders (.a_i(a_i[i]), .b_i(b_i[i]), .carry_i(carry_i), .carry_o(carry_tmp[i]), .sum_o(sum_o[i]));
      else
        fulladder adders (.a_i(a_i[i]), .b_i(b_i[i]), .carry_i(carry_tmp[i-1]), .carry_o(carry_tmp[i]), .sum_o(sum_o[i]));
    end
  assign carry_o = carry_tmp[N-1];
  endgenerate
endmodule