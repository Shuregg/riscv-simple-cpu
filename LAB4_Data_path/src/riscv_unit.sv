module riscv_unit(
  input  logic        clk_i,
  input  logic        rst_i
);

  logic [31:0]  instr;
  
  logic [31:0]  instr_addr;
  logic         mem_req;
  logic         mem_we;
  logic [31:0]  mem_wd;
  logic [31:0]  mem_addr;
  
  logic [31:0]  rd;  
  
  logic         stall;
  logic         nstall_and_mem_req;
  
  assign nstall_and_mem_req = !stall && mem_req;
  
  
  always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)
      stall <= 1'b0;
    else
      stall <= nstall_and_mem_req;
  end
  
  riscv_core core
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .stall_i(nstall_and_mem_req),
    .instr_i(instr),
    .mem_rd_i(rd), 
    
    .instr_addr_o(instr_addr),
    .mem_addr_o(mem_addr),
    .mem_size_o(),//NC
    .mem_req_o(mem_req),
    .mem_we_o(mem_we),
    .mem_wd_o(mem_wd)
  );
  
  instr_mem instr_mem_inst
  (
    .addr_i(instr_addr),
    .read_data_o(instr)
  );
  
  data_mem data_mem_inst
  (
    .clk_i(clk_i),
    .mem_req_i(mem_req),
    .write_enable_i(mem_we),
    .addr_i(mem_addr),
    .write_data_i(mem_wd),

    .read_data_o(rd)
  );
endmodule