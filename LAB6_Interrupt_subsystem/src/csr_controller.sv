module csr_controller(

  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        trap_i,

  input  logic [ 2:0] opcode_i,

  input  logic [11:0] addr_i,
  input  logic [31:0] pc_i,
  input  logic [31:0] mcause_i,
  input  logic [31:0] rs1_data_i,
  input  logic [31:0] imm_data_i,
  input  logic        write_enable_i,

  output logic [31:0] read_data_o,
  output logic [31:0] mie_o,
  output logic [31:0] mepc_o,
  output logic [31:0] mtvec_o
);

  import csr_pkg::*;

  //Result after operation (MUX)
  logic [31:0] CSR_DATA_I; 
  //Write enable signals after DEMUX
  logic MIE_WE; 
  logic MTVEC_WE;
  logic MSCRATCH_WE;
  logic MEPC_WE;
  logic MCAUSE_WE;
  //CS-Registers input data;
  logic [31:0]  MIE_DATA_I;
  logic [31:0]  MTVEC_DATA_I;
  logic [31:0]  MSCRATCH_DATA_I;
  logic [31:0]  MEPC_DATA_I;
  logic [31:0]  MCAUSE_DATA_I;
  //CS-Registers output data;
  logic [31:0]  MIE_DATA_O;
  logic [31:0]  MTVEC_DATA_O;
  logic [31:0]  MSCRATCH_DATA_O;
  logic [31:0]  MEPC_DATA_O;
  logic [31:0]  MCAUSE_DATA_O;
  //Init input data for CS-Registers
  assign MIE_DATA_I       = CSR_DATA_I;
  assign MTVEC_DATA_I     = CSR_DATA_I;
  assign MSCRATCH_DATA_I  = CSR_DATA_I;
  assign MEPC_DATA_I      = trap_i ? pc_i     : CSR_DATA_I;
  assign MCAUSE_DATA_I    = trap_i ? mcause_i : CSR_DATA_I;
  //CSR_controller outputs init
  assign mie_o    = MIE_DATA_O;
  assign mtvec_o  = MTVEC_DATA_O;
  assign mepc_o   = MEPC_DATA_O;

  //WRITE CSR DATA
  always_comb begin
    CSR_DATA_I <=  read_data_o; //???
    case(opcode_i)
      CSR_RW :  CSR_DATA_I <=  rs1_data_i;                     //= 3'b001;
      CSR_RS :  CSR_DATA_I <=  rs1_data_i | read_data_o;       //= 3'b010;
      CSR_RC :  CSR_DATA_I <= ~rs1_data_i & read_data_o;       //= 3'b011;
      CSR_RWI:  CSR_DATA_I <=  imm_data_i;                     //= 3'b101;
      CSR_RSI:  CSR_DATA_I <=  imm_data_i | read_data_o;       //= 3'b110;
      CSR_RCI:  CSR_DATA_I <= ~imm_data_i & read_data_o;       //= 3'b111;
    endcase
  end

  //CSR ENABLE SINGALS LOGIC (DEMUX)
  always_comb begin
     MIE_WE      <= 1'b0;
     MTVEC_WE    <= 1'b0;
     MSCRATCH_WE <= 1'b0;
     MEPC_WE     <= 1'b0;
     MCAUSE_WE   <= 1'b0;
    case(addr_i)
      MIE_ADDR     :  MIE_WE      <= write_enable_i;               //= 12'h304;
      MTVEC_ADDR   :  MTVEC_WE    <= write_enable_i;               //= 12'h305;
      MSCRATCH_ADDR:  MSCRATCH_WE <= write_enable_i;               //= 12'h340;
      MEPC_ADDR    :  MEPC_WE     <= write_enable_i;     //= 12'h341;
      MCAUSE_ADDR  :  MCAUSE_WE   <= write_enable_i;     //= 12'h342;
    endcase    
  end

//  CSR Registers init
  register32 MIE_REG        (.clk_i(clk_i), .rst_i(rst_i), .en_i(MIE_WE)      ,  .data_i(MIE_DATA_I)      ,  .data_o(MIE_DATA_O)      );
  register32 MTVEC_REG      (.clk_i(clk_i), .rst_i(rst_i), .en_i(MTVEC_WE)    ,  .data_i(MTVEC_DATA_I)    ,  .data_o(MTVEC_DATA_O)    );
  register32 MSCRATCH_REG   (.clk_i(clk_i), .rst_i(rst_i), .en_i(MSCRATCH_WE) ,  .data_i(MSCRATCH_DATA_I) ,  .data_o(MSCRATCH_DATA_O) );
  register32 MEPC_REG       (.clk_i(clk_i), .rst_i(rst_i), .en_i(MEPC_WE || trap_i)     ,  .data_i(MEPC_DATA_I)     ,  .data_o(MEPC_DATA_O)     );
  register32 MCAUSE_REG     (.clk_i(clk_i), .rst_i(rst_i), .en_i(MCAUSE_WE || trap_i)   ,  .data_i(MCAUSE_DATA_I)   ,  .data_o(MCAUSE_DATA_O)   );

  //READ CSR DATA
  always_comb begin
    read_data_o   <=  32'b0; 
    case(addr_i)
      MIE_ADDR     :  read_data_o <=  MIE_DATA_O;            //= 12'h304;
      MTVEC_ADDR   :  read_data_o <=  MTVEC_DATA_O;          //= 12'h305;
      MSCRATCH_ADDR:  read_data_o <=  MSCRATCH_DATA_O;       //= 12'h340;
      MEPC_ADDR    :  read_data_o <=  MEPC_DATA_O;           //= 12'h341;
      MCAUSE_ADDR  :  read_data_o <=  MCAUSE_DATA_O;         //= 12'h342;
    endcase
  end
endmodule