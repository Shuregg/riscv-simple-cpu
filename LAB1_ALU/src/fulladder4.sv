module fulladder4(
        input [3:0]     a_i
       ,input [3:0]     b_i
       ,input           carry_i
       ,output [3:0]    sum_o
       ,output          carry_o
    );
    logic carry0, carry1, carry2, carry3;
    
    fulladder adder0 (
     .a_i(a_i[0])
    ,.b_i(b_i[0])
    ,.carry_i(carry_i)
    ,.sum_o(sum_o[0])
    ,.carry_o(carry0) );
    
    fulladder adder1 (
     .a_i(a_i[1])
    ,.b_i(b_i[1])
    ,.carry_i(carry0)
    ,.sum_o(sum_o[1])
    ,.carry_o(carry1) );
    
    fulladder adder2 (
     .a_i(a_i[2])
    ,.b_i(b_i[2])
    ,.carry_i(carry1)
    ,.sum_o(sum_o[2])
    ,.carry_o(carry2) );
    
    fulladder adder3 (
     .a_i(a_i[3])
    ,.b_i(b_i[3])
    ,.carry_i(carry2)
    ,.sum_o(sum_o[3])
    ,.carry_o(carry_o) );

endmodule
