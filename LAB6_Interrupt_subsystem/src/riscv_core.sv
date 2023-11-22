module riscv_core (
  input  logic        clk_i,
  input  logic        rst_i,

  input  logic        stall_i,
  input  logic [31:0] instr_i,
  input  logic [31:0] mem_rd_i,

  input  logic        irq_req_i,

  output logic [31:0] instr_addr_o,
  output logic [31:0] mem_addr_o,
  output logic [ 2:0] mem_size_o,
  output logic        mem_req_o,
  output logic        mem_we_o,
  output logic [31:0] mem_wd_o,

  output logic        irq_ret_o
);

  import riscv_pkg::*;

  localparam PC_INCR              = 32'd4;
  localparam ILL_INSTR_CAUSE_CODE = 32'h0000_0002;
  
/*===========================WIRES===========================*/
//MAIN DECODER WIRES (ALL THIS SIGNALS ARE OUTPUT)
  logic [1:0]   MDEC_A_SEL;         //select 1st ALU operand
  logic [2:0]   MDEC_B_SEL;         //select 2nd ALU operand
  logic [4:0]   MDEC_ALU_OP;        //
  logic [2:0]   MDEC_CSR_OP;        //
  logic         MDEC_CSR_WE;        //.   write enable for csr (control status register)
  logic         MDEC_MEM_REQ;       //req mem
  logic         MDEC_MEM_WE;        //
  logic [2:0]   MDEC_MEM_SIZE;      //
  logic         MDEC_GRP_WE;        //register file write enable
  logic [1:0]   MDEC_WB_SEL;        //write back selector (RF write source)
  logic         MDEC_ILLEGAL_INSTR; //.
  logic         MDEC_B;        
  logic         MDEC_JAL;
  logic         MDEC_JALR;
  logic         MDEC_MRET;          //.    signal return from interruption/exceptions mret (Machine mode R)

//REGISTER FILE WIRES
  logic        RF_WE_IN;
  logic [4:0]  RF_RA1_IN;
  logic [4:0]  RF_RA2_IN;
  logic [4:0]  RF_WA_IN;
  logic [31:0] RF_WD_IN;
  logic [31:0] RF_RD1_OUT;
  logic [31:0] RF_RD2_OUT;

//ALU WIRES
  logic        ALU_FLAG_OUT;
  logic [31:0] ALU_RES_OUT;
  logic [31:0] ALU_A_IN;
  logic [31:0] ALU_B_IN;
  
//CONSTANT WIRES (IMMEDIATE)
  logic [31:0] imm_I;
  logic [31:0] imm_U;
  logic [31:0] imm_S;
  logic [31:0] imm_B;
  logic [31:0] imm_J;
  logic [31:0] imm_Z;
  
//PROGRAMM COUNTER WIRES
  logic [31:0] PC_IN;
  logic [31:0] PC_OUT;
  
  logic [31:0]  JALR_PC_IN;             //next PC value if MDEC_JALR == 1
  logic [31:0]  INCR_PC_IN;             //next PC value if MDEC_JALR == 0
  
  logic         BAF;                    //Branch & Flag(from ALU) wire
  logic         JAL_OR_BAF;             //JAL | BAF
  logic [31:0]  BRANCH_MUX_OUT;         //the mux controlled by MDEC_B (branch signal)
  logic [31:0]  JAL_OR_BAF_MUX_OUT;     //the mux controlled by (MDEC_JAL | (MDEC_B & ALU_FLAG_OUT)) signal (branch or jump signal)
  logic [31:0]  RD1_PLUS_imm_I;
  //////////////////////////////
//  logic [31:0]  



    
//IRQ CONTROLLER WIRES
  logic         IRQ_CONTR_IRQ_RET_OUT;
  logic [31:0]  IRQ_CONTR_IRQ_CAUSE_OUT;
  logic         IRQ_CONTR_IRQ_OUT;

//CSR CONTROLLER WIRES
  logic [31:0]  CSR_CONTR_MCAUSE_IN;

  logic [31:0]  CSR_CONTR_MIE_OUT;
  logic [31:0]  CSR_CONTR_MTVEC_OUT;
  logic [31:0]  CSR_CONTR_MEPC_OUT;
  logic [31:0]  CSR_CONTR_READ_DATA_OUT;

//ADDITIONAL WIRES
  logic         TRAP;
  
/*===========================ASSIGNING===========================*/ 
//ASSIGNING (IMMEDIATE)
  assign imm_I = {{20{instr_i[31]}}, instr_i[31:20]}; //20+12=32
  assign imm_U = {instr_i[31:12], 12'h000}; //20+12=32
  assign imm_S = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]}; //20+12
  assign imm_B = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0}; //19+1+12=32
  assign imm_J = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0}; //12+1+19
  assign imm_Z = {27'b0, instr_i[19:15]};

//ASSIGNING (REGISTER FILE)
  assign RF_WE_IN   = !(stall_i && TRAP) && MDEC_GRP_WE;
  assign RF_RA1_IN  = instr_i[19:15];
  assign RF_RA2_IN  = instr_i[24:20];
  assign RF_WA_IN   = instr_i[11: 7];
  assign RF_WD_IN   = MDEC_WB_SEL ? mem_rd_i : ALU_RES_OUT;

//ASSIGNING (ALU)
  always_comb begin
    case(MDEC_A_SEL)  //choosing operand A (mux)
      OP_A_RS1:       ALU_A_IN <= RF_RD1_OUT;
      OP_A_CURR_PC:   ALU_A_IN <= PC_OUT;
      OP_A_ZERO:      ALU_A_IN <= 32'b0;
      default: begin end
    endcase
    
    case(MDEC_B_SEL) //choosing operand B (mux)
      OP_B_RS2:       ALU_B_IN <= RF_RD2_OUT;
      OP_B_IMM_I:     ALU_B_IN <= imm_I;
      OP_B_IMM_U:     ALU_B_IN <= imm_U;
      OP_B_IMM_S:     ALU_B_IN <= imm_S;
      OP_B_INCR:      ALU_B_IN <= PC_INCR;
      default: begin end
    endcase
  end

//ASSIGNING (PROGRAM COUNTER)
  assign BAF                = MDEC_B & ALU_FLAG_OUT;                    //Branch And Flag
  assign JAL_OR_BAF         = MDEC_JAL | BAF;                           //JAL OR BAF
  
  assign BRANCH_MUX_OUT     = MDEC_B ? imm_B : imm_J;                   //
  assign JAL_OR_BAF_MUX_OUT = JAL_OR_BAF ? BRANCH_MUX_OUT : PC_INCR;    //

  assign INCR_PC_IN         = PC_OUT + JAL_OR_BAF_MUX_OUT;              //next PC value if MDEC_JALR == 0
  assign RD1_PLUS_imm_I = RF_RD1_OUT + imm_I;
  assign JALR_PC_IN = {RD1_PLUS_imm_I[31:1], 1'b0};                     //next PC value if MDEC_JALR == 1
  
  
  assign MTVEC_PC_IN  = TRAP ? CSR_CONTR_MTVEC_OUT : JALR_PC_IN;
  assign PC_IN   = MDEC_MRET ? CSR_CONTR_MEPC_OUT : MTVEC_PC_IN;
  // assign PC_IN              = MDEC_JALR ? JALR_PC_IN : INCR_PC_IN;      //next PC value

//ASSIGNING (RISCV CORE)
  assign instr_addr_o = PC_OUT; 
  assign mem_addr_o   = ALU_RES_OUT;
    /*3'd0 (load byte); 3'd1 (load half); 3'd2 (load word); 3'd4 (load byte unsigned); 3'd5 (load half unsigned).*/
  assign mem_size_o   = MDEC_MEM_SIZE; 
  assign mem_req_o    = MDEC_MEM_REQ;
  assign mem_we_o     = MDEC_MEM_WE;
  assign mem_wd_o     = RF_RD2_OUT;
  
//ASSIGNING (ADDITIONAL WIRES)
  assign TRAP = MDEC_ILLEGAL_INSTR || IRQ_CONTR_IRQ_OUT;

//ASSIGNING (CSR CONTROLLER WIRES)
  assign CSR_CONTR_MCAUSE_IN = MDEC_ILLEGAL_INSTR ? ILL_INSTR_CAUSE_CODE : IRQ_CONTR_IRQ_CAUSE_OUT;

//ASSIGNING (IRQ CONTROLLER WIRES)
  assign irq_ret_o = IRQ_CONTR_IRQ_RET_OUT;

/*===========================INSTANCES===========================*/ 
//MAIN DECODER INSTANCE
  decoder_riscv main_decoder_inst 
  (
    .fetched_instr_i(instr_i),
    .a_sel_o(MDEC_A_SEL),
    .b_sel_o(MDEC_B_SEL),
    .alu_op_o(MDEC_ALU_OP),        
    .csr_op_o(MDEC_CSR_OP),
    .csr_we_o(MDEC_CSR_WE),                 //.
    .mem_req_o(MDEC_MEM_REQ),
    .mem_we_o(MDEC_MEM_WE),        
    .mem_size_o(MDEC_MEM_SIZE),      
    .gpr_we_o(MDEC_GRP_WE),
    .wb_sel_o(MDEC_WB_SEL),
    .illegal_instr_o(MDEC_ILLEGAL_INSTR),   //.
    .branch_o(MDEC_B),        
    .jal_o(MDEC_JAL),
    .jalr_o(MDEC_JALR),
    .mret_o(MDEC_MRET)                      //.
  );
  
//REGISTER FILE INSTANCE
  rf_riscv register_file_inst
  (
   .clk_i(clk_i)            ,
   .write_enable_i(RF_WE_IN),
   .read_addr1_i(RF_RA1_IN) ,
   .read_addr2_i(RF_RA2_IN) ,
   .write_addr_i(RF_WA_IN)  ,
   .write_data_i(RF_WD_IN)  ,
   .read_data1_o(RF_RD1_OUT),
   .read_data2_o(RF_RD2_OUT)
  );
  
//ALU INSTANCE
 alu_riscv alu_inst
 (
   .a_i(ALU_A_IN),
   .b_i(ALU_B_IN),
   .alu_op_i(MDEC_ALU_OP),
   .flag_o(ALU_FLAG_OUT),
   .result_o(ALU_RES_OUT)
 );
 
//PC INSTANCE
  program_counter program_counter_inst
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(!stall_i),
    .pc_i(PC_IN),
    .pc_o(PC_OUT)
  );

//IRQ CONTROLLER INSTANCE
  interrupt_controller  irq_controller_inst
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .exception_i(MDEC_ILLEGAL_INSTR),
    .irq_req_i(irq_req_i),
    .mie_i(CSR_CONTR_MIE_OUT[0]),
    .mret_i(MDEC_MRET),

    .irq_ret_o(IRQ_CONTR_IRQ_RET_OUT),
    .irq_cause_o(IRQ_CONTR_IRQ_CAUSE_OUT),  //[31:0]
    .irq_o(IRQ_CONTR_IRQ_OUT)
  );

//CSR CONTROLLER INTANCE
  csr_controller csr_controller_inst
  (
  .clk_i(clk_i),
  .rst_i(rst_i),
  .trap_i(TRAP),

  .opcode_i(MDEC_CSR_OP),        //[ 2:0]

  .addr_i(instr_i[31:20]),          //[11:0]
  .pc_i(PC_OUT),            //[31:0]
  .mcause_i(CSR_CONTR_MCAUSE_IN),        //[31:0]
  .rs1_data_i(RF_RD1_OUT),      //[31:0]
  .imm_data_i(imm_Z),      //[31:0]
  .write_enable_i(MDEC_CSR_WE),  //[31:0]

  .read_data_o(CSR_CONTR_READ_DATA_OUT),     //[31:0]
  .mie_o(CSR_CONTR_MIE_OUT),           //[31:0]
  .mepc_o(CSR_CONTR_MEPC_OUT),          //[31:0]
  .mtvec_o(CSR_CONTR_MTVEC_OUT)          //[31:0]
  );  
endmodule