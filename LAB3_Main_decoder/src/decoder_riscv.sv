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
//find "//?" to check questionable solutions
  import riscv_pkg::*;
  
  logic [6:0]   opcode;
  // logic [4:0]   rd;
  logic [2:0]   funct3;
  // logic [4:0]   rs1;
  // logic [4:0]   rs2;
  logic [6:0]   funct7;

  always_comb begin
    opcode <= fetched_instr_i[6:0];
    // rd     <= fetched_instr_i[11:7];
    funct3 <= fetched_instr_i[14:12];
    // rs1    <= fetched_instr_i[19:15];
    // rs2    <= fetched_instr_i[24:20];
    funct7 <= fetched_instr_i[31:25];
    
    if(opcode[1:0] != 2'b11)
      illegal_instr_o <= 1'b1;
    else begin
      illegal_instr_o <= 1'b0;
      case(opcode[6:2])
      
        OP_OPCODE: begin
          gpr_we_o <= 1'b1;
          //alu_op_o <= ALU_ADD;
          
          case(funct3)
            3'b000: 
            case(funct7)
              7'b0000000: alu_op_o <= ALU_ADD;
              7'b0100000: alu_op_o <= ALU_SUB;
              default: begin
                gpr_we_o        <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;
              end
            endcase
            
            3'b100: 
            case(funct7)
              7'b0000000:  alu_op_o <= ALU_XOR;
              default: begin
                gpr_we_o        <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;
              end
            endcase
            
            3'b110: 
            case(funct7)
              7'b0000000:  alu_op_o <= ALU_OR;
              default: begin
                gpr_we_o        <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;                
              end
            endcase
            
            3'b111: 
            case(funct7)
              7'b0000000:  alu_op_o <= ALU_AND;
              default: begin
                gpr_we_o        <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;                
              end
            endcase
            
            3'b001:
            case(funct7)
              7'b0000000:  alu_op_o <= ALU_SLL;
              default: begin
                gpr_we_o        <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;                
              end
            endcase
            
            3'b101:
            case(funct7)
              7'b0000000:  alu_op_o <= ALU_SRL;
              7'b0100000:  alu_op_o <= ALU_SRA;
              default: begin
                gpr_we_o        <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;                
              end
            endcase
            
            3'b001:
            case(funct7)
              7'b0000000:  alu_op_o <= ALU_SLL;
              default: begin
                gpr_we_o        <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;                
              end
            endcase
            
            3'b001:
            case(funct7)
              7'b0000000:  alu_op_o <= ALU_SLL;
              default: begin
                gpr_we_o        <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;                
              end
            endcase
            
            3'b010:
            case(funct7)
              7'b0000000:  alu_op_o <= ALU_SLTS;
              default: begin
                gpr_we_o        <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;                
              end
            endcase
            
            3'b011:
            case(funct7)
              7'b0000000:  alu_op_o <= ALU_SLTU;
              default: begin
                gpr_we_o        <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;                
              end
            endcase
            
            default: begin
              gpr_we_o        <= 1'b0;
              mem_req_o       <= 1'b0;
              illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;              
            end
          endcase
        end //end of OP_OPCODE

        LOAD_OPCODE: begin 
          //logic [11:0] imm_U;
          //imm_U <= fetched_instr_i[31:20];
          gpr_we_o    <= 1'b1;      //RF_WE
          a_sel_o     <= OP_A_RS1   //2'b0; //RF_RD1
          b_sel_o     <= OP_B_IMM_I //2'b1;    //imm_I
          alu_op_o    <= ALU_ADD;
          mem_req_o   <= 1'b1;
          mem_we_o    <= 1'b0;
          wb_sel_o    <= WB_LSU_DATA // 2'd1; //from Load-Store Unit (data memory), not from ALU

          csr_we_o  <= 1'b0;
          jal_o     <= 1'b0;
          jalr_o    <= 1'b0;
          branch_o  <= 1'b0;

          case(funct3)
            LDST_B://load byte
              mem_size_o  <= 3'd0;

            LDST_H://load half
              mem_size_o  <= 3'd1;

            LDST_W://load word
              mem_size_o  <= 3'd2;

            LDST_BU://load byte unsigned
              mem_size_o  <= 3'd4;

            LDST_HU://load half unsigned
              mem_size_o  <= 3'd5;
            default:  begin
              gpr_we_o        <= 1'b0;
              mem_req_o       <= 1'b0;
              illegal_instr_o <= 1'b1;
              jal_o           <= 1'b0;
              jalr_o          <= 1'b0;
              branch_o        <= 1'b0;              
            end

          endcase  
        end //end of LOAD_OPCODE:

        MISC_MEM_OPCODE: begin
          case(funct3)
            3'b000:
              //NOP
            default: begin
              gpr_we_o        <= 1'b0;
              mem_req_o       <= 1'b0;
              illegal_instr_o <= 1'b1;
              jal_o           <= 1'b0;
              jalr_o          <= 1'b0;
              branch_o        <= 1'b0;              
            end
          endcase
        end
        
        OP_IMM_OPCODE: begin
          logic [11:0] imm_I;
          imm_I <= fetched_instr_i[31:20];
          gpr_we_o <= 1'b1;
          b_sel_o <= 1'b1;
          case(funct3)
            3'b000://ADDI
              alu_op_o <= ALU_ADD;
            3'b110://XORI
              alu_op_o <= ALU_XOR
            3'b110://ORI
              alu_op_o <= ALU_OR
            3'b111://ANDI
              alu_op_o <= ALU_AND
            3'b001://SLLI (Shift Left Logical Immediate)
            case(funct7)
              7'b0000000:
                alu_op_o <= ALU_SLL;
              default: begin 
                gpr_we_o        <= 1'b0;
                b_sel_o         <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;
              end
            endcase

            3'b101:
            case(funct7)
              7'b0000000://SRLI (Shift Right Logic Immediate)
                alu_op_o <= ALU_SRL;
              7'b0100000://SRAI (Shift Right Arithmethic immediate)
                alu_op_o <= ALU_SRA;
              default: begin
                gpr_we_o        <= 1'b0;
                b_sel_o         <= 1'b0;
                mem_req_o       <= 1'b0;
                illegal_instr_o <= 1'b1;
                jal_o           <= 1'b0;
                jalr_o          <= 1'b0;
                branch_o        <= 1'b0;                
              end
            endcase

            3'b010://SLTI (Set if Less Than Immediate)
              alu_op_o <= ALU_SLTS;
            3'b011://SLTIU (Set if Less Than Immediate Unsigned)
              alu_op_o <= ALU_SLTU;
            default: begin
              b_sel_o         <= 1'b0;
              gpr_we_o        <= 1'b0;
              mem_req_o       <= 1'b0;
              illegal_instr_o <= 1'b1;
              jal_o           <= 1'b0;
              jalr_o          <= 1'b0;
              branch_o        <= 1'b0;  
            end 
          endcase //end of OP_IMM:
        end //end of IMM_OPCODE

        AUIPC_OPCODE: begin
          gpr_we_o    <= 1'b1;
          a_sel_o     <= OP_A_RS1;
          b_sel_o     <= OP_B_IMM_U;
          alu_op_i    <= ALU_ADD;
          wb_sel_o    <= WB_EX_RESULT; //from ALU

          mem_req_o   <= 1'b0;
          branch_o    <= 1'b0;
          jal_o       <= 1'b0;
          jalr_o      <= 1'b0;
        end //end of AUIPC
        
        STORE_OPCODE: begin
          gpr_we_o  <= 1'b0;
          a_sel_o   <= OP_A_RS1;
          b_sel_o   <= OP_B_IMM_S;
          alu_op_o  <= ALU_ADD;
          mem_req_o <= 1'b1;
          mem_we_o  <= 1'b1;
          csr_we_o  <= 1'b0;

          jal_o     <= 1'b0;
          jalr_o    <= 1'b0;
          branch_o  <= 1'b0;
          
          case(funct3)
            LDST_B: 
              mem_size_o <= 3'd0;
            
            LDST_H:
              mem_size_o <= 3'd1;

            LDST_W:
              mem_size_o <= 3'd2;

            default: begin
              gpr_we_o        <= 1'b0;
              mem_req_o       <= 1'b0;
              illegal_instr_o <= 1'b1;
              jal_o           <= 1'b0;
              jalr_o          <= 1'b0;
              branch_o        <= 1'b0;                
            end
          endcase
        end //end of STORE
        
        LUI_OPCODE: begin
          gpr_we_o  <= 1'b1;        //RF_WE
          a_sel_o   <= OP_A_ZERO;   //2'b10    zero (const)
          b_sel_o   <= OP_B_IMM_S;  //3'b011; signed  //instr[31:12]
          alu_op_o  <= ALU_ADD;
        end //end of LUI
        
        BRANCH_OPCODE: begin
          gpr_we_o  <= 1'b0;
          branch_o  <= 1'b1;
          a_sel_o   <= OP_A_RS1;
          b_sel_o   <= OP_B_RS2;

          jal_o     <= 1'b0; //?
          jalr_o    <= 1'b0; //?
          case(funct3)
            3'b000://beq
              alu_op_o  <= ALU_EQ;
            3'b001://bne
              alu_op_o  <= ALU_NE;
            3'b100://blt
              alu_op_o  <= ALU_LTS;
            3'b101://bge
              alu_op_o  <= ALU_GES
            3'b110://bltu
              alu_op_o  <= ALU_LTU
            3'b111://bgeu
              alu_op_o  <= ALU_GEU;
            default: begin
              branch_o        <= 1'b0;
              gpr_we_o        <= 1'b0;
              mem_req_o       <= 1'b0;
              illegal_instr_o <= 1'b1;
              jal_o           <= 1'b0;
              jalr_o          <= 1'b0;
              branch_o        <= 1'b0;                
            end
          endcase
        end //end of BRANCH_OPCODE:
        
        JALR_OPCODE: begin
          gpr_we_o    <= 1'b1;
          a_sel_o     <= OP_A_CURR_PC;
          b_sel_o     <= OP_B_INCR;
          alu_op_i    <= ALU_ADD;
          mem_req_o   <= 1'b0;
          wb_sel_o    <= WB_EX_RESULT; //from ALU

          jal_o       <= 1'b0;
          branch_o    <= 1'b0;
          
          case(funct3)
            3'b000:
              jalr_o  <= 1'b1;
            default: begin
              jalr_o          <= 1'b0;
              gpr_we_o        <= 1'b0;
              mem_req_o       <= 1'b0;
              illegal_instr_o <= 1'b1;
              jal_o           <= 1'b0;
              jalr_o          <= 1'b0;
              branch_o        <= 1'b0;  
            end
          endcase
        end //end of JALR
        
        JAL_OPCODE: begin
          gpr_we_o    <= 1'b1;
          a_sel_o     <= OP_A_CURR_PC;
          b_sel_o     <= OP_B_INCR;
          alu_op_i    <= ALU_ADD;
          mem_req_o   <= 1'b0;
          wb_sel_o    <= WB_EX_RESULT; //from ALU
          
          jal_o       <= 1'b1;
          branch_o    <= 1'b0;
          jalr_o      <= 1'b0;
        end //end of JAL
        
        SYSTEM_OPCODE: begin //TODO
          
          gpr_we_o  <= 1'b1;
          csr_we_o  <= 1'b1;
          case(funct3)
            3'b000: begin   //mret (machine return)
              mret_o    <= 1'b1;
              gpr_we_o  <= 1'b0; //?
              csr_we_o  <= 1'b0; //?
              case(funct7)
                7'h00: //environment call
                  illegal_instr_o <= 1'b1;
                7'h01: //environment break
                  illegal_instr_o <= 1'b1;
                default: begin
                  gpr_we_o        <= 1'b0;
                  mem_req_o       <= 1'b0;
                  illegal_instr_o <= 1'b1;
                  jal_o           <= 1'b0;
                  jalr_o          <= 1'b0;
                  branch_o        <= 1'b0;                  
                end
              endcase
            end

            CSR_RW: begin          //= 3'b001;
              csr_op_o  <= funct3;
            end
            CSR_RS: begin          //= 3'b010;
              csr_op_o  <= funct3;
            end
            CSR_RC: begin          //= 3'b011;
              csr_op_o  <= funct3;
            end
            CSR_RWI: begin         //= 3'b101;
              csr_op_o  <= funct3;
            end
            CSR_RSI: begin         //= 3'b110;
              csr_op_o  <= funct3;
            end
            CSR_RCI: begin         //= 3'b111;
              csr_op_o  <= funct3;
            end

            default: begin
              gpr_we_o        <= 1'b0;
              mem_req_o       <= 1'b0;
              illegal_instr_o <= 1'b1;
              csr_we_o        <= 1'b0;
              jal_o           <= 1'b0;
              jalr_o          <= 1'b0;
              branch_o        <= 1'b0;  
            end
          endcase
        end //end of SYSTEM
        
        default: begin
          gpr_we_o        <= 1'b0;
          mem_req_o       <= 1'b0;
          illegal_instr_o <= 1'b1;
          csr_we_o        <= 1'b0;
          jal_o           <= 1'b0;
          jalr_o          <= 1'b0;
          branch_o        <= 1'b0;  
        end
      endcase //end of main case (opcode[6:2])
    end
  end
endmodule