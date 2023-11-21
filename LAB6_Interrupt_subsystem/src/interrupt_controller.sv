module interrupt_controller (
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        exception_i,
  input  logic        irq_req_i,
  input  logic        mie_i,
  input  logic        mret_i,

  output logic        irq_ret_o,
  output logic [31:0] irq_cause_o,
  output logic        irq_o
  );

  logic [31:0] exc_reg_data_i;
  logic [31:0] exc_reg_data_o;
  logic [31:0] irq_reg_data_i;
  logic [31:0] irq_reg_data_o;
    
  assign exc_reg_data_i = (~mret_i &  (exception_i | exc_reg_data_o));
  assign irq_reg_data_i = ( ~( mret_i & ~(exception_i | exc_reg_data_o)) & (irq_reg_data_o | irq_o));
  assign irq_cause_o = 32'h1000_0010;    
  assign irq_o =(~((exception_i | exc_reg_data_o) | irq_reg_data_o) & (irq_req_i & mie_i)); //???  
  assign irq_ret_o = ( mret_i & ~(exception_i | exc_reg_data_o) );
  
  register32 exc_h    (.clk_i(clk_i), .rst_i(rst_i), .en_i(1'b1),  .data_i(exc_reg_data_i), .data_o(exc_reg_data_o));
  register32 irq_h    (.clk_i(clk_i), .rst_i(rst_i), .en_i(1'b1),  .data_i(irq_reg_data_i), .data_o(irq_reg_data_o));

endmodule