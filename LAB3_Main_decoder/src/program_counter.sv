`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.09.2023 21:29:57
// Design Name: 
// Module Name: program_counter
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


module program_counter(
 input  logic        clk_i
,input  logic        rst_i
,input  logic [31:0] pc_i
,output logic [31:0] pc_o
);

//  logic [31:0] buff;
//  initial buff = 32'b0;
//  initial pc_o = buff;
  //initial pc_o = 32'b0;
  
  
  always_ff @(posedge clk_i) begin
    if(rst_i)
      pc_o <= 32'b0;
    else
      pc_o <=  pc_i;
  end
  
  
endmodule
