`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2023 09:04:22 AM
// Design Name: 
// Module Name: ext_mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ext_mem(
    input logic             clk_i,
    input logic             mem_req_i,
    input logic             write_enable_i,
    input logic     [3:0]   byte_enable_i,
    input logic     [31:0]  addr_i,
    input logic     [31:0]  write_data_i,
    
    output logic    [31:0]  read_data_o,
    output logic            ready_o
    );

  parameter cells_value = 4096;

  logic [31:0] RAM          [0:cells_value-1];
  logic [31:0] byte_addr;
  logic address_is_valid;
  
  logic [7:0] byte_0;
  logic [7:0] byte_1;
  logic [7:0] byte_2;
  logic [7:0] byte_3;

  initial $readmemh("lab_12_ps2ascii_data.mem", RAM);

  //Bytes to write
  assign byte_0 = byte_enable_i[0] ? write_data_i[ 7: 0] : RAM[byte_addr][7:0];
  assign byte_1 = byte_enable_i[1] ? write_data_i[15: 8] : RAM[byte_addr][15:8];
  assign byte_2 = byte_enable_i[2] ? write_data_i[23:16] : RAM[byte_addr][23:16];
  assign byte_3 = byte_enable_i[3] ? write_data_i[31:24] : RAM[byte_addr][31:24];

  assign byte_addr        = addr_i >> 2;
  assign address_is_valid = (addr_i < 4 * cells_value);
  assign ready_o          = 1'b1;
  
  //READ
  always_ff @(posedge clk_i) begin
    if(mem_req_i == 0 || write_enable_i == 1)
      read_data_o <= read_data_o;
    else begin
      if (mem_req_i && address_is_valid)
        read_data_o <= RAM[byte_addr];
      else
        read_data_o <= read_data_o;
    end
  end

  //WRITE
  always_ff @(posedge clk_i) begin
    if(mem_req_i && write_enable_i && address_is_valid) begin
      RAM[byte_addr] <= {byte_3, byte_2, byte_1, byte_0};
    end
  end
endmodule
