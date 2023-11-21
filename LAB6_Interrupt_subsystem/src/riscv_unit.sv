module riscv_unit(
  input  logic        clk_i,
  input  logic        rst_i
);
//Core and Instr mem wires
  logic [31:0]  instr;
  logic [31:0]  instr_addr;
  logic         mem_req;
  logic         mem_we;
  logic [31:0]  mem_wd;
  logic [31:0]  mem_addr;
  logic [31:0]  rd;  
  logic         stall;
  logic [2:0]   mem_size;
//Data mem wires
  logic [31:0]  data_mem_rd_o;
  logic         data_mem_ready_o;
//  LSU wires
  logic         lsu_mem_req_o;
  logic         lsu_we_o;
  logic [31:0]  lsu_mem_wd_o;
  logic [31:0]  lsu_mem_addr_o;
  logic         lsu_mem_we_o;
  logic [3:0]   lsu_mem_be_o;
  logic [31:0]  lsu_mem_rd_i; 

  riscv_core core
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .stall_i(stall),         //!!! !!! !!! !!!
    .instr_i(instr),
    .mem_rd_i(rd), 
    
    .instr_addr_o(instr_addr),
    .mem_addr_o(mem_addr),
    .mem_size_o(mem_size),
    .mem_req_o(mem_req),
    .mem_we_o(mem_we),
    .mem_wd_o(mem_wd)
  );
  
  instr_mem instr_mem_inst
  (
    .addr_i(instr_addr),
    .read_data_o(instr)
  );
  
  riscv_lsu LSU_inst
  (  //Core interface
    .clk_i(clk_i),
    .rst_i(rst_i),
    .core_req_i(mem_req),
    .core_we_i(mem_we),
    .core_size_i(mem_size),
    .core_addr_i(mem_addr),
    .core_wd_i(mem_wd),
    .core_rd_o(rd),
    .core_stall_o(stall),
  // Data Memory interface
    .mem_req_o(lsu_mem_req_o),
    .mem_we_o(lsu_we_o),
    .mem_be_o(lsu_mem_be_o),
    .mem_addr_o(lsu_mem_addr_o),
    .mem_wd_o(lsu_mem_wd_o),
    .mem_rd_i(data_mem_rd_o),
    .mem_ready_i(data_mem_ready_o)
  );
//NEW DATA MEMORY
  ext_mem ext_mem_inst
  (
    .clk_i(clk_i),
    .mem_req_i(lsu_mem_req_o),
    .write_enable_i(lsu_we_o),
    .byte_enable_i(lsu_mem_be_o),           //!!! !!! !!!
    .addr_i(lsu_mem_addr_o),
    .write_data_i(lsu_mem_wd_o),
    
    .read_data_o(data_mem_rd_o),
    .ready_o(data_mem_ready_o)
  );

//assign nstall_and_mem_req = !stall && mem_req;
  
//STALL logic
//  always_ff @(posedge clk_i or posedge rst_i) begin
//    if(rst_i)
//      stall <= 1'b0;
//    else
//      stall <= nstall_and_mem_req;
//  end
  
//OLD DATA MEMORY  
//  data_mem data_mem_inst
//  (
//    .clk_i(clk_i),
//    .mem_req_i(mem_req),
//    .write_enable_i(mem_we),
//    .addr_i(mem_addr),
//    .write_data_i(mem_wd),
//    .read_data_o(rd)
//  );
endmodule