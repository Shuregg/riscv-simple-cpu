module decoder_riscv (

  input  logic [31:0]  fetched_instr_i, //instruction
  
  output logic [1:0]   a_sel_o,         //select 1st ALU operand
  output logic [2:0]   b_sel_o,         //select 2nd ALU operand
  output logic [4:0]   alu_op_o,        
  output logic [2:0]   csr_op_o,        //
  output logic         csr_we_o,        //write enable for csr (control status register)
  output logic         mem_req_o,       //req mem
  output logic         mem_we_o,        
  output logic [2:0]   mem_size_o,      
  output logic         gpr_we_o,        //register file write enable
  output logic [1:0]   wb_sel_o,        //write back selector (RF write source)
  output logic         illegal_instr_o,
  output logic         branch_o,        
  output logic         jal_o,
  output logic         jalr_o,
  output logic         mret_o           //signal return from interruption/exceptions mret (Machine mode RETurn)
);
  import riscv_pkg::*;
  
  logic [6:0]   opcode;
  logic [4:0]   rd;
  logic [2:0]   funct3;
  logic [4:0]   rs1;
  logic [4:0]   rs2;
  logic [6:0]   funct7;

  

  
  always_comb begin
    opcode <= fetched_instr_i[6:0];
    rd     <= fetched_instr_i[11:7];
    funct3 <= fetched_instr_i[14:12];
    rs1    <= fetched_instr_i[19:15];
    rs2    <= fetched_instr_i[24:20];
    funct7 <= fetched_instr_i[31:25];
    
    if(opcode[1:0] != 2'b11)
      illegal_instr_o <= 1'b1;
    else begin
      illegal_instr_o <= 1'b0;
      case(opcode[6:2])
        OP_OPCODE: begin
          gpr_we_o <= 1'b1;
          alu_op_o <= ALU_ADD;
          if(funct3 == 3'b000 && funct7 == 7'b0000000) begin            //ADD
            alu_op_o <= ALU_ADD;
          end else
          if(funct3 == 3'b000 && funct7 == 7'b0100000) begin            //SUB
            alu_op_o <= ALU_SUB;
          end else
          if(funct3 == 3'b100 && funct7 == 7'b0000000) begin            //XOR
            alu_op_o <= ALU_XOR;
          end else
          if(funct3 == 3'b110 && funct7 == 7'b0000000) begin            //OR
            alu_op_o <= ALU_OR;
          end else
          if(funct3 == 3'b111 && funct7 == 7'b0000000) begin            //AND
            alu_op_o <= ALU_AND;
          end else
          if(funct3 == 3'b001 && funct7 == 7'b0000000) begin            //SLL
            alu_op_o <= ALU_SLL;
          end else
          if(funct3 == 3'b101 && funct7 == 7'b0000000) begin            //SRL
            alu_op_o <= ALU_SRL;
          end else
          if(funct3 == 3'b101 && funct7 == 7'b0100000) begin            //SRA
            alu_op_o <= ALU_SRA;
          end else
          if(funct3 == 3'b010 && funct7 == 7'b0000000) begin            //SLT
            alu_op_o <= ALU_SLTS;
          end else
          if(funct3 == 3'b011 && funct7 == 7'b0000000) begin            //SLTU
            alu_op_o <= ALU_SLTU;
          end else begin
            gpr_we_o <= 1'b0;
            illegal_instr_o <= 1'b1;
          end
        end //end of OP_OPCODE:
        
        LOAD_OPCODE: begin
          logic [11:0] imm_load;
          imm_load <= fetched_instr_i[31:20];
          
          if(funct3 == LDST_B) begin                                    //load bit
            
          end else
          if(funct3 == LDST_H) begin                                    //load half
            
          end else
          if(funct3 == LDST_W) begin                                    //load word
            
          end else
          if(funct3 == LDST_BU) begin                                   //load byte unsigned
            
          end else
          if(funct3 == LDST_HU) begin                                   //load half unsigned
            
          end else begin
            //alu_op_o
            illegal_instr_o <= 1'b1;
          end
        end //end of LOAD_OPCODE:
        
        MISC_MEM_OPCODE: begin
        
        end
        
        OP_IMM_OPCODE: begin
          logic [11:0] imm_op_imm;
          imm_op_imm <= fetched_instr_i[31:20];
          b_sel_o <= 1'b1;
          if(funct3 == 3'b000) begin                                    //ADDI

          end else
          if(funct3 == 3'b110) begin                                    //XORI

          end else
          if(funct3 == 3'b110) begin                                    //ORI

          end else
          if(funct3 == 3'b111) begin                                    //ANDI

          end else
          if(funct3 == 3'b001 && funct7 == 7'b0000000) begin            //SLLI (Shift Left Logical Immediate)
          

          end else
          if(funct3 == 3'b101 && funct7 == 7'b0000000) begin            //SRLI (Shift Right Logic Immediate)
          

          end else
          if(funct3 == 3'b101 && funct7 == 7'b0100000) begin            //SRAI (Shift Right Arithmethic immediate)
          

          end else
          if(funct3 == 3'b010) begin                                    //SLTI (Set if Less Than Immediate)
          

          end else
          if(funct3 == 3'b011) begin                                    //SLTIU (Set if Less Than Immediate Unsigned)
          

          end else begin
          
            b_sel_o <= 1'b0;
          end
        end //end of OP_IMM:
        
        AUIPC_OPCODE: begin
        
        end
        
        STORE_OPCODE: begin
        
        end
        
        LUI_OPCODE: begin
          
        end
        
        BRANCH_OPCODE: begin
        
        end
        
        JALR_OPCODE: begin
        
        end
        
        JAL_OPCODE: begin
        
        end
        
        SYSTEM_OPCODE: begin
        
        end
      endcase
    end
    
  end
  
endmodule