`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2023 04:10:34 PM
// Design Name: 
// Module Name: register32
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


module register32(
    input  logic            clk_i,
    input  logic            rst_i,
    input  logic            en_i,
    input  logic [31:0]     data_i,
    output logic [31:0]     data_o
    );

    always_ff @(posedge clk_i or posedge rst_i) begin
        if(rst_i)       data_o <= 32'b0;
        else begin
            if(en_i)    data_o <= data_i;
            else        data_o <= data_o;
        end 
    end
endmodule
