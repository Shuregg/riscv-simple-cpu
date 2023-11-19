//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.09.2023 21:24:01
// Design Name: CYBERcobra 3000 Pro 2.1
// Module Name: CYBERcobra
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CYBERcobra(
 input  logic        clk_i
,input  logic        rst_i
,input  logic [15:0] sw_i
,output logic [31:0] out_o
);

  parameter pc_trans_const = 32'd4;
  
  
//Program counter pins
  logic [31:0] PC_in;
  logic [31:0] PC_out;

//Instruction memory out pin
  logic [31:0] instruction;
  
//REGISTER FILE PINS
  logic        RF_WE_in;
  logic [4:0]  RF_RA1_in;
  logic [4:0]  RF_RA2_in;
  logic [4:0]  RF_WA_in;
  logic [31:0] RF_WD_in;
  logic [31:0] RF_RD1_out;
  logic [31:0] RF_RD2_out;
  
//ALU PINS
  logic        ALU_flag_out;
  logic [31:0] ALU_res_out;
  
  logic [31:0] ALU_A_input;
  logic [31:0] ALU_B_input;
  
  
//Optional wires
  logic        jump;
  logic        branch;
  logic [31:0] pc_trans_value;
  logic [31:0] pc_adder_in;
  
  program_counter program_counter_inst
  (.clk_i(clk_i), 
   .rst_i(rst_i), 
   .pc_i(PC_in) , 
   .pc_o(PC_out)
   );
  
  assign jump   = instruction[31];
  assign branch     = instruction[30] & ALU_flag_out;
  
  assign pc_trans_value[9:0]   = {instruction[12:5], 2'b00};
  assign pc_trans_value[31:10] = {22{instruction[12]}};
  
  assign out_o                 = RF_RD1_out; //!!!!!!!!!!!!!
  
  //assign pc_adder_in = (jump | branch) ? pc_trans_value : pc_trans_const;
  always_comb begin
    if(jump || branch)
      pc_adder_in <= pc_trans_value;
    else
      pc_adder_in <= pc_trans_const;
  end
  //assign PC_in = pc_adder_in;
  fulladder32 PC_adder
  (.a_i(PC_out)     ,
   .b_i(pc_adder_in),
   .carry_i(1'b0)   ,
   .sum_o(PC_in)    ,
   .carry_o()
  );
  
  instr_mem instruction_memory_inst
  (.addr_i(PC_out),
   .read_data_o(instruction)
  ); 

  alu_riscv ALU_inst
  (.a_i(RF_RD1_out)             ,
   .b_i(RF_RD2_out)             ,
   .alu_op_i(instruction[27:23]),
   .flag_o(ALU_flag_out)        ,
   .result_o(ALU_res_out)
   );
  
  rf_riscv register_file_inst
  (.clk_i(clk_i)            ,
   .write_enable_i(RF_WE_in),
   .read_addr1_i(RF_RA1_in) ,
   .read_addr2_i(RF_RA2_in) ,
   .write_addr_i(RF_WA_in)  ,
   .write_data_i(RF_WD_in)  ,
   .read_data1_o(RF_RD1_out),
   .read_data2_o(RF_RD2_out)
   );
  
 
  
  assign RF_WE_in  = ~(instruction[30] | instruction[31]);
  assign RF_RA1_in = instruction[22:18];
  assign RF_RA2_in = instruction[17:13];
  assign RF_WA_in  = instruction[4:0];
  
  //RF Write Data MUX 
  always_comb begin
    case(instruction[29:28])
      2'b00: begin
        RF_WD_in[22:0]  <= instruction[27:5];
        RF_WD_in[31:23] <= {9{instruction[27]}};
      end
      
      2'b01: begin
        RF_WD_in        <= ALU_res_out; //ALU
      end
      
      2'b10: begin
        RF_WD_in[15:0]  <= sw_i;
        RF_WD_in[31:16] <= {16{sw_i[15]}};
      end
      
      2'b11:
        RF_WD_in        <= 32'd0;
    endcase
  end

endmodule
