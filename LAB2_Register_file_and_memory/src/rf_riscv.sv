module rf_riscv(
 input  logic           clk_i
,input  logic           write_enable_i

,input  logic   [4:0]   write_addr_i
,input  logic   [4:0]   read_addr1_i
,input  logic   [4:0]   read_addr2_i

,input  logic   [31:0]  write_data_i
,output logic   [31:0]  read_data1_o
,output logic   [31:0]  read_data2_o
);

  logic [31:0] rf_mem [0:31];
  
//READ
  always@(*) begin
    case(read_addr1_i) //read data1
      5'b0: read_data1_o <= 32'b0;
      default: read_data1_o <= rf_mem[read_addr1_i];
    endcase
    case(read_addr2_i) //read data2
      5'b0: read_data2_o <= 32'b0;
      default: read_data2_o <= rf_mem[read_addr2_i];
    endcase
  end 
//WRITE
  always@(posedge clk_i) begin
    if(write_enable_i)
      case(write_addr_i)
        5'b0: rf_mem[5'b0] <= 32'b0;
        default: rf_mem[write_addr_i] <= write_data_i;
      endcase
  end
endmodule
