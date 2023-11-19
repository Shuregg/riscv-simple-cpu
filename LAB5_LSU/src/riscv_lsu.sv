module riscv_lsu(
  input logic clk_i,
  input logic rst_i,

  // Core interface
  input  logic        core_req_i,
  input  logic        core_we_i,
  input  logic [ 2:0] core_size_i,
  input  logic [31:0] core_addr_i,
  input  logic [31:0] core_wd_i,
  output logic [31:0] core_rd_o,
  output logic        core_stall_o,

  // Memory interface
  output logic        mem_req_o,
  output logic        mem_we_o,
  output logic [ 3:0] mem_be_o,
  output logic [31:0] mem_addr_o,
  output logic [31:0] mem_wd_o,
  input  logic [31:0] mem_rd_i,
  input  logic        mem_ready_i
  );
  
//  import riscv_pkg::LDST_B;
//  import riscv_pkg::LDST_H;
//  import riscv_pkg::LDST_W;
//  import riscv_pkg::LDST_BU;
//  import riscv_pkg::LDST_HU;
  import riscv_pkg::*;
  
  logic stall_reg;

  assign mem_req_o    = core_req_i;
  assign mem_we_o     = core_we_i;
  assign mem_addr_o   = core_addr_i;
  assign core_stall_o = ( !(stall_reg && mem_ready_i) && core_req_i); //???

  //STORE BYTE/HALF/WORD
  always_comb begin
    if(core_req_i && core_we_i) begin
      case(core_size_i)
        LDST_B: begin   
          mem_be_o  <=  4'b0001 << core_addr_i[1:0]; 
          mem_wd_o  <=  {4{core_wd_i[7:0]}};
        end
        LDST_H: begin
          mem_be_o  <=  core_addr_i[1] ? 4'b1100 : 4'b0011;
          mem_wd_o  <=  {2{core_wd_i[15:0]}};
        end
        LDST_W: begin
          mem_be_o  <=  4'b1111;
          mem_wd_o  <=  core_wd_i;
        end
      endcase
    end else begin
    
    end    
  end

  //LOAD BYTE/HALF/WORD/Unsigned BYTE/Unsigned HALF
  always_comb begin
    if(core_addr_i && !core_we_i) begin
      case(core_size_i)
        LDST_B  : begin
          case(core_addr_i[1:0])
            2'b00:  core_rd_o <= { {24{mem_rd_i[7]}} , mem_rd_i[ 7: 0]};
            2'b01:  core_rd_o <= { {24{mem_rd_i[15]}}, mem_rd_i[15: 8]};
            2'b10:  core_rd_o <= { {24{mem_rd_i[23]}}, mem_rd_i[23:16]};
            2'b11:  core_rd_o <= { {24{mem_rd_i[31]}}, mem_rd_i[31:24]};
          endcase
        end 
        LDST_H  : core_rd_o <= core_addr_i[1] ? { {16{mem_rd_i[31]}}, mem_rd_i[31:16]} : { {16{mem_rd_i[15]}}, mem_rd_i[15:0]};
        
        LDST_W  : core_rd_o <= mem_rd_i;

        LDST_BU : begin
          case(core_addr_i[1:0])
            2'b00:  core_rd_o <= { 24'b0, mem_rd_i[ 7: 0]};
            2'b01:  core_rd_o <= { 24'b0, mem_rd_i[15: 8]};
            2'b10:  core_rd_o <= { 24'b0, mem_rd_i[23:16]};
            2'b11:  core_rd_o <= { 24'b0, mem_rd_i[31:24]};
          endcase
        end
        
        LDST_HU : core_rd_o <= core_addr_i[1] ? { 16'b0, mem_rd_i[31:16]} : { 16'b0, mem_rd_i[15:0]};
      endcase
    end
  end

  always_ff @(clk_i or posedge rst_i) begin
    if(rst_i) begin
      stall_reg     <= 1'b0;
//      core_stall_o  <= 1'b0;
    end else begin
      stall_reg     <= ( !(stall_reg && mem_ready_i) && core_req_i);
//      core_stall_o  <= stall_reg;
    end
  end

endmodule
