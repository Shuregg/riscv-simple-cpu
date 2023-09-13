module instr_mem(
 input logic  [31:0] addr_i
,output logic [31:0] read_data_o
);
  parameter cellsValue = 32'd1024;
  reg [7:0] RAM [0:cellsValue-1]; //1024 cells * 8 bit
  initial $readmemh("iram.txt", RAM);

  always @(*) begin
    if(addr_i <= cellsValue-4)
      read_data_o <= {RAM[addr_i+3], RAM[addr_i+2], RAM[addr_i+1], RAM[addr_i+0]}; 
    else
      read_data_o <= 32'b0;
  end
endmodule