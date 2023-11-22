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
  logic [2:0]   funct3;
  logic [6:0]   funct7;

  always_comb begin
    opcode      <= fetched_instr_i[6:0];
    funct3      <= fetched_instr_i[14:12];
    funct7      <= fetched_instr_i[31:25];
    
    mem_we_o    <= 1'b0;
    jal_o       <= 1'b0;
    jalr_o      <= 1'b0;
    gpr_we_o    <= 1'b0;
    a_sel_o     <= 2'b0;
    b_sel_o     <= 3'b0;
    wb_sel_o    <= 2'b0;
    mret_o      <= 1'b0;
    branch_o    <= 1'b0;
    if(opcode[1:0] != 2'b11)
      illegal_instr_o <= 1'b1;
    else begin
      illegal_instr_o <= 1'b0;
      case(opcode[6:2])
      
        OP_OPCODE: begin
          gpr_we_o <= 1'b1;
          
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
          gpr_we_o    <= 1'b1;
          a_sel_o     <= OP_A_RS1;
          b_sel_o     <= OP_B_IMM_I;
          alu_op_o    <= ALU_ADD;
          mem_req_o   <= 1'b1;
          mem_we_o    <= 1'b0;
          wb_sel_o    <= WB_LSU_DATA; // 2'd1; //from Load-Store Unit (data memory), not from ALU
          csr_we_o  <= 1'b0;
          jal_o     <= 1'b0;
          jalr_o    <= 1'b0;
          branch_o  <= 1'b0;

          case(funct3)
            LDST_B:     mem_size_o  <= 3'd0;//load byte
            LDST_H:     mem_size_o  <= 3'd1;//load half
            LDST_W:     mem_size_o  <= 3'd2;//load word
            LDST_BU:    mem_size_o  <= 3'd4;//load byte unsigned
            LDST_HU:    mem_size_o  <= 3'd5;//load half unsigned
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
            3'b000: begin//NOP
            end
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
          gpr_we_o <= 1'b1;
          b_sel_o <= 1'b1;
          case(funct3)
            3'b000: alu_op_o <= ALU_ADD;//ADDI
            3'b100: alu_op_o <= ALU_XOR;//XORI
            3'b110: alu_op_o <= ALU_OR;//ORI
            3'b111: alu_op_o <= ALU_AND;//ANDI
            3'b001://SLLI (Shift Left Logical Immediate)
            case(funct7)
              7'b0000000:   alu_op_o <= ALU_SLL;
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
              7'b0000000:   alu_op_o <= ALU_SRL;//SRLI (Shift Right Logic Immediate)
              7'b0100000:   alu_op_o <= ALU_SRA;//SRAI (Shift Right Arithmethic immediate)
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

            3'b010: alu_op_o <= ALU_SLTS;//SLTI (Set if Less Than Immediate)
            3'b011: alu_op_o <= ALU_SLTU;//SLTIU (Set if Less Than Immediate Unsigned)
            default: begin
              b_sel_o         <= 1'b0;
              gpr_we_o        <= 1'b0;
              mem_req_o       <= 1'b0;
              illegal_instr_o <= 1'b1;
              jal_o           <= 1'b0;
              jalr_o          <= 1'b0;
              branch_o        <= 1'b0;  
            end 
          endcase
        end //end of IMM_OPCODE

        AUIPC_OPCODE: begin
          gpr_we_o    <= 1'b1;
          a_sel_o     <= OP_A_CURR_PC;
          b_sel_o     <= OP_A_ZERO;
          alu_op_o    <= ALU_ADD;
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
            LDST_B: mem_size_o <= 3'd0;
            LDST_H: mem_size_o <= 3'd1;
            LDST_W: mem_size_o <= 3'd2;
            default: begin
              gpr_we_o        <= 1'b0;
              mem_req_o       <= 1'b0;
              illegal_instr_o <= 1'b1;
              jal_o           <= 1'b0;
              jalr_o          <= 1'b0;
              branch_o        <= 1'b0;   
              mem_we_o        <= 1'b0;            
            end
          endcase
        end //end of STORE
        
        LUI_OPCODE: begin
          gpr_we_o  <= 1'b1;
          a_sel_o   <= OP_A_ZERO;
          b_sel_o   <= OP_A_ZERO;
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
            3'b000: alu_op_o  <= ALU_EQ;//beq
            3'b001: alu_op_o  <= ALU_NE;//bne
            3'b100: alu_op_o  <= ALU_LTS;//blt
            3'b101: alu_op_o  <= ALU_GES;//bge
            3'b110: alu_op_o  <= ALU_LTU;//bltu
            3'b111: alu_op_o  <= ALU_GEU;//bgeu
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
          alu_op_o    <= ALU_ADD;
          mem_req_o   <= 1'b0;
          wb_sel_o    <= WB_EX_RESULT; //from ALU
          jal_o       <= 1'b0;
          branch_o    <= 1'b0;
          
          case(funct3)
            3'b000: jalr_o  <= 1'b1;
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
          alu_op_o    <= ALU_ADD;
          mem_req_o   <= 1'b0;
          wb_sel_o    <= WB_EX_RESULT; //from ALU
          jal_o       <= 1'b1;
          branch_o    <= 1'b0;
          jalr_o      <= 1'b0;
        end //end of JAL
        
        SYSTEM_OPCODE: begin 
          gpr_we_o  <= 1'b1;
          csr_we_o  <= 1'b1;
          wb_sel_o  <= WB_CSR_DATA;
          case(funct3)
            3'b000: begin   //mret (machine return)
              illegal_instr_o <= 1'b1;
              gpr_we_o        <= 1'b0; //?
              csr_we_o        <= 1'b0; //?
              case(funct7)
                7'h00:  illegal_instr_o <= 1'b1;//environment call (ecall)
                7'h01:  illegal_instr_o <= 1'b1;//environment break (ebreak)
                7'h18: begin
                  mret_o          <= 1'b1;
                  illegal_instr_o <= 1'b0;
                end
                default: begin
                  gpr_we_o        <= 1'b0;
                  mem_req_o       <= 1'b0;
                  illegal_instr_o <= 1'b1;
                  jal_o           <= 1'b0;
                  jalr_o          <= 1'b0;
                  branch_o        <= 1'b0;            
                  mret_o          <= 1'b0;      
                end
              endcase
            end       //end of mret
            CSR_RW:     csr_op_o  <= funct3;        //= 3'b001;
            CSR_RS:     csr_op_o  <= funct3;        //= 3'b010;
            CSR_RC:     csr_op_o  <= funct3;        //= 3'b011;
            CSR_RWI:    csr_op_o  <= funct3;        //= 3'b101;
            CSR_RSI:    csr_op_o  <= funct3;        //= 3'b110; 
            CSR_RCI:    csr_op_o  <= funct3;        //= 3'b111;
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