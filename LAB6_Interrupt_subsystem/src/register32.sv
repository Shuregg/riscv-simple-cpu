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

    always_ff @(posedge clk_i) begin
        if(rst_i) begin
            data_o <= 32'b0;
        end else if(en_i) begin
            data_o <= data_i;
        end else begin
            data_o <= data_o;
        end 
    end
endmodule
