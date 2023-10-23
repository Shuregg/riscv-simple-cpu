module data_mem(
 input logic            clk_i
,input logic            mem_req_i
,input logic            write_enable_i
,input logic    [31:0]  addr_i
,input logic    [31:0]  write_data_i

,output logic   [31:0]  read_data_o
);

  parameter cells_value = 4096;
  
  parameter all_is_ok = 2'b00;
  parameter fall_leaf = 2'b01;
  parameter dead_beef = 2'b10;
  
  logic [31:0] RAM          [0:cells_value-1];
  logic [31:0] byte_addr;
  logic address_is_valid;
  
//  logic [31:0] mem_out;
//  logic [31:0] RD_reg;
//  logic [1:0]  out_flag;
  
  
  assign byte_addr        = addr_i >> 2;
  assign address_is_valid = (addr_i < 4 * cells_value);
  
  
  always_ff @(posedge clk_i) begin
    if(mem_req_i == 0 || write_enable_i == 1)
      read_data_o <= 32'hfa11_1eaf;
    else begin
      if (mem_req_i && address_is_valid)
        read_data_o <= RAM[byte_addr];
      else
        read_data_o <= 32'hdead_beef;
    end
  end
  
  //Write
  always_ff @(posedge clk_i) begin
    if(mem_req_i && write_enable_i)
      RAM[byte_addr] <= write_data_i;
  end
  
//  always_ff @(posedge clk_i) begin
//    if(mem_req_i) begin
//      if(!address_is_valid && !write_enable_i)
//        read_data_o <= 32'hdead_beef;
////        out_flag <= 2'b10;
//      else begin
//        if(write_enable_i) begin
//          //{RAM[addr_i+3], RAM[addr_i+2], RAM[addr_i+1], RAM[addr_i]} <= write_data_i;
//          {RAM[byte_addr+3], RAM[byte_addr+2], RAM[byte_addr+1], RAM[byte_addr+0]} <= write_data_i;
//          read_data_o   <= 32'hfa11_1eaf;
//          //out_flag <= 2'b01;
//        end else
//          //read_data_o <= {RAM[addr_i+3], RAM[addr_i+2], RAM[addr_i+1], RAM[addr_i]};
//          //read_data_o <= RAM[addr_i[31:2]];
          
//          read_data_o <= {RAM[byte_addr+3], RAM[byte_addr+2], RAM[byte_addr+1], RAM[byte_addr+0]};
//          //mem_out <= {RAM[byte_addr+3], RAM[byte_addr+2], RAM[byte_addr+1], RAM[byte_addr+0]};
//          //out_flag <= 2'b00;
//      end
//    end else begin
//      read_data_o <= 32'hfa11_1eaf;
      
////      out_flag <= 2'b01;
//    end
//  end
  
//  always_ff @(posedge clk_i) begin
//    if(write_enable_i)
//      RD_reg <= mem_out;
//    else
//      RD_reg <= RD_reg;
//  end
  
//  always_comb begin
//    case(out_flag)
//      all_is_ok:
//        read_data_o <= RD_reg;
//      fall_leaf:
//        read_data_o <= 32'hfa11_1eaf;
//      dead_beef:
//        read_data_o <= 32'hdead_beef;
//      default:
//        read_data_o <= 32'hdead_dead;
//    endcase
//  end
  
endmodule
//data is being written to the cell incorrectly. RAM [0:7] must be 0x0123456789abcdef, time: 829895.00 ns
//reading from data memory must be synchronous, time: 829900.00 ns
//synchronous data memory read error, time: 829910.00 ns