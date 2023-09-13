module data_mem(
 input logic            clk_i
,input logic            mem_req_i
,input logic            write_enable_i
,input logic    [31:0]  addr_i
,input logic    [31:0]  write_data_i

,output logic   [31:0]  read_data_o
);

  parameter cellsValue = 4096;
    
  logic [7:0] RAM [0:cellsValue-1];
  always_ff @(posedge clk_i) begin
    if(mem_req_i) begin
      if(addr_i >= cellsValue && !write_enable_i)
        read_data_o <= 32'hdead_beef;
      else begin
        if(write_enable_i) begin
          {RAM[addr_i+3], RAM[addr_i+2], RAM[addr_i+1], RAM[addr_i]} <= write_data_i;
          read_data_o   <= 32'hfa11_1eaf;
        end else
          read_data_o <= {RAM[addr_i+3], RAM[addr_i+2], RAM[addr_i+1], RAM[addr_i]};
      end
    end else begin
      read_data_o <= 32'hfa11_1eaf;
    end
  end
endmodule
//data is being written to the cell incorrectly. RAM [0:7] must be 0x0123456789abcdef, time: 829895.00 ns
//reading from data memory must be synchronous, time: 829900.00 ns
//synchronous data memory read error, time: 829910.00 ns