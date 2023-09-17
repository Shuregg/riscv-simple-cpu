`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  MIET
// Engineer: Innikov Alexander
// 
// Create Date: 17.09.2023 10:29:24
// Design Name: 
// Module Name: tb_alu_riscv
// Project Name: RISC-V ALU
// Target Devices: Nexys A7-100T
// Tool Versions: 
// Description: tb for alu_riscv.sv
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_alu_riscv();
  
  
  import alu_opcodes_pkg::*;
  
  parameter BIT_DEPTH     = 32;
  parameter OPERATION_VAL = 5;
  parameter TESTING_VALUE = 18;
  parameter BIT_INTERV    = 100; //ns
  
  integer i             = 0;
  integer error_counter = 0;
  
  logic [8*9:1] operation_type;
  
  logic [31:0]  operand1_i;
  logic [31:0]  operand2_i;
  logic [4:0]   operation_i;
  
  logic [31:0]  expected_res;
  logic         expected_flag;
  
  logic         flag_o;
  logic [31:0]  result_o;
  
  logic [31:0] oper1_curr;
  logic [31:0] oper2_curr;
  logic [4:0]  alu_oper_curr;
  logic        flag_curr;
  logic [31:0] res_curr;
  
  assign operand1_i    = oper1_curr;    //oper1_arr[0];
  assign operand2_i    = oper2_curr;    //oper2_arr[0];
  assign operation_i   = alu_oper_curr; //alu_oper_arr[0];
  assign expected_res  = res_curr;      //res_arr[0];
  assign expected_flag = flag_curr;     //flag_arr[0];
  
  alu_riscv ALU_under_test(
    .a_i(operand1_i),
    .b_i(operand2_i),
    .alu_op_i(operation_i),
    .flag_o(flag_o),
    .result_o(result_o)
   );
//    32  32    5       1       32       = 102
  //    A   B   Oper    flag    result
  logic [31:0] oper1_arr [0:TESTING_VALUE-1] = {
    32'b01000110000010011000101011001111,
    32'b01000111010111110101101111100110,
    32'b01100011000110110100101100010001,
    32'b01011100001100110100001111000001,
    
    32'b11101010110111110001001001111010,
    32'b11101000110110001101000001100010,
    32'b01111110011010100010101001111110,
    32'b10000110010000101011001010010001,
    
    32'b11111111111111111110011001110001, //-6543
    32'b01111111111111110110001110010001, //2147443601
    32'b11111111111111111111111111100000, //-32
    32'b00000000000000000000100000000001, //2049
    
    32'b10110100000101111011001110010110, //EQ #1
    32'b00000000000000000000001000011100, //EQ #2 : 540
    32'b00110100000011111111010101100110, //NE #1
    32'b00000000000000000000001000011100, //NE #2 : 540
    32'b11111111111111111111111111110100, //-12
    32'b01110001100100001001001100111011
  };
  
  logic [31:0] oper2_arr [0:TESTING_VALUE-1] = {
    32'b00100011110011111110110110000011,
    32'b00101111000011110011011010001010,
    32'b01010100011101001110011010001110,
    32'b00110100011100101101110111000100,
    
    32'b00011000100110001100100111101100,
    32'b00100111101001110010010001001010,
    32'b00100011101110011101101000111100,
    32'b11100010101011100000110101110100,
    
    32'b11111111111111111111110100001111, //-753
    32'b01111111111111111111111111010000, //2147483600
    32'b00000000000000000000000001111101, //125
    32'b00000000000000000000011110111110, //1982
    
    32'b11010001001101101100101000111000, //EQ #1
    32'b00000000000000000000001000011100, //EQ #2 : 540 
    32'b11000110101001111111111000001100, //NE #1
    32'b00000000000000000000001000011100, //NE #2 : 540
    32'b11111111111111111111111111011101, //-35
    32'b00111001111111111001100000101001
  };
  
  logic [4:0] alu_oper_arr [0:TESTING_VALUE-1] = {
    ALU_ADD,
    ALU_SUB,
    ALU_XOR,
    ALU_OR,
    
    ALU_AND,
    ALU_SRA,
    ALU_SRL,
    ALU_SLL,
    
    ALU_LTS,
    ALU_LTU,
    ALU_GES,
    ALU_GEU,
    
    ALU_EQ,
    ALU_EQ,
    ALU_NE,
    ALU_NE,
    ALU_SLTS,
    ALU_SLTU
  };
  
  logic       flag_arr [0:TESTING_VALUE-1] = {
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    
    1'b1,
    1'b1,
    1'b0,
    1'b1,
    
    1'b0,
    1'b1,
    1'b1,
    1'b0,
    1'b0,
    1'b0
  };
  
  logic [31:0] res_arr [0:TESTING_VALUE-1] = {
   32'b1101001110110010111100001010010,
   32'b0011000010100000010010101011100,
   32'b0011_0111_0110_1111_1010_1101_1001_1111,
   32'b0111_1100_0111_0011_1101_1111_1100_0101,
   
   32'b1000_1001_1000_0000_0000_0110_1000,
   32'b1111_1111_1111_1010_0011_0110_0011_0100,
   32'b111,
   32'b0010_1001_0001_0000_0000_0000_0000_0000,
   
   32'b0, //ALU_LTS,
   32'b0, //ALU_LTU,
   32'b0, //ALU_GES,
   32'b0, //ALU_GEU,
   
   32'b0,
   32'b0,
   32'b0,
   32'b0,
   32'b0,
   32'b0};
   
  initial begin
    $display( "\nStart test: \n\n==========================\nCLICK THE BUTTON 'Run All'\n==========================\n"); $stop();
    for(i = 0; i < TESTING_VALUE; i = i + 1) begin
      oper1_curr    <= oper1_arr[i];
      oper2_curr    <= oper2_arr[i];
      alu_oper_curr <= alu_oper_arr[i];
      res_curr      <= res_arr[i];
      flag_curr     <= flag_arr[i];
      
      #BIT_INTERV;
      
      if((expected_res !== result_o)) begin
        error_counter = error_counter + 1;
        display_res();
      end
      if((expected_flag !== flag_o)) begin
        error_counter = error_counter + 1;
        display_flag();
      end
    end
    $display("Number of errors: %d", error_counter);
    if(error_counter == 0)
      $display("\nALU is working correctly!!!\n");
    $finish();
  end
  
  always @(*) begin
    case(operation_i)
      ALU_ADD  : operation_type = "ALU_ADD  ";
      ALU_SUB  : operation_type = "ALU_SUB  ";
      ALU_XOR  : operation_type = "ALU_XOR  ";
      ALU_OR   : operation_type = "ALU_OR   ";
      ALU_AND  : operation_type = "ALU_AND  ";
      ALU_SRA  : operation_type = "ALU_SRA  ";
      ALU_SRL  : operation_type = "ALU_SRL  ";
      ALU_SLL  : operation_type = "ALU_SLL  ";
      ALU_LTS  : operation_type = "ALU_LTS  ";
      ALU_LTU  : operation_type = "ALU_LTU  ";
      ALU_GES  : operation_type = "ALU_GES  ";
      ALU_GEU  : operation_type = "ALU_GEU  ";
      ALU_EQ   : operation_type = "ALU_EQ   ";
      ALU_NE   : operation_type = "ALU_NE   ";
      ALU_SLTS : operation_type = "ALU_SLTS ";
      ALU_SLTU : operation_type = "ALU_SLTU ";
      default  : operation_type = "NOP      ";
    endcase
  end
  
  function void display_res;
    $display("\n-------------------------\n");
    $display(" ERROR     #%d\n", error_counter);
    $display(" Operand1:  %b\n", operand1_i);
    $display(" Operand2:  %b\n", operand2_i);
    $display(" Operation: %s\n", operation_type);
    
    $display(" RESULT:    %b\n", result_o);
    $display(" expected:  %b\n", expected_res);
    $display("\n-------------------------\n");
  endfunction
  function void display_flag;
    $display("\n-------------------------\n");
    $display(" ERROR     #%d\n", error_counter);
    $display(" Operand1:  %b\n", operand1_i);
    $display(" Operand2:  %b\n", operand2_i);
    $display(" Operation: %s\n", operation_type);
    
    $display(" FLAG:      %b\n", flag_o);
    $display(" expected:  %b\n", expected_flag);
    $display("\n-------------------------\n");
  endfunction
 
//  function void display;
//    $display("\n-------------------------\n");
//    $display("ERROR #%d\n", error_counter);
//    $display(" Operand1       = %b\n", operand1_i);
//    $display(" Operand2       = %b\n", operand2_i);
//    $display(" Operation      = %s\n\n", operation_type);
    
//    $display(" FLAG           = %b\n", flag_o);
//    $display(" expected_FLAG  = %b\n", expected_flag);
//    $display(" RESULT         = %b\n", result_o);
//    $display(" expected_RES   = %b\n", expected_res);
//    $display("\n-------------------------\n");
//  endfunction
  
  
endmodule
