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

  logic         exc_h_reset;
  logic         exc_h_set;
  logic         exc_h_D;
  logic         exc_h_Q;

  logic         irq_h_reset;
  logic         irq_h_set;
  logic         irq_h_D;
  logic         irq_h_Q;

  logic         exc_set_OR_exc_h_Q;           //exceptpion_i || exc_reg_data_o
  logic         irq_req_i_AND_mie_i;
  logic         exc_set_NOR_irq_Q;
  // logic         mret_and_not_exc_or_excreg;   //mret_i && ~()

  assign exc_set_OR_exc_h_Q   = (exc_h_set) | (exc_h_Q);
  assign irq_req_i_AND_mie_i  = (irq_req_i & mie_i);

  assign exc_h_reset  = mret_i;
  assign exc_h_set    = exception_i;
  assign exc_h_D      = ~(exc_h_reset) & (exc_set_OR_exc_h_Q);

  assign irq_h_reset  = (exc_h_reset & (~exc_set_OR_exc_h_Q));
  assign irq_h_set    = irq_o;
  assign irq_h_D      = ~(irq_h_reset) & (irq_h_Q | irq_h_set);
  
  assign exc_set_NOR_irq_Q =  ~(irq_h_Q | exc_set_OR_exc_h_Q);

  assign irq_o          = (irq_req_i_AND_mie_i) & (exc_set_NOR_irq_Q);
  assign irq_cause_o    = 32'h1000_0010; 
  assign irq_ret_o      =  irq_h_reset;
  
  // assign  irq_reg_data_i =  !mret_and_not_exc_or_excreg &&  ;

  
  always_ff @ (posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
      exc_h_Q <=  1'b0;
      irq_h_Q <=  1'b0;    
    end else begin
      exc_h_Q <=  exc_h_D;
      irq_h_Q <=  irq_h_D;
    end
  end

  // logic [31:0]  exc_reg_data_i;
  // logic [31:0]  exc_reg_data_o;
  // logic [31:0]  irq_reg_data_i;
  // logic [31:0]  irq_reg_data_o;

  // assign exc_reg_data_i = (~mret_i &  (exception_i | exc_reg_data_o));
  // assign irq_reg_data_i = ( ~( mret_i & ~(exception_i | exc_reg_data_o)) & (irq_reg_data_o | irq_o));
  // assign irq_cause_o = 32'h1000_0010;    
  // assign irq_o =(~((exception_i | exc_reg_data_o) | irq_reg_data_o) & (irq_req_i & mie_i)); //???  
  // assign irq_ret_o = ( mret_i & ~(exception_i | exc_reg_data_o) );


  // register32 exc_h    (.clk_i(clk_i), .rst_i(rst_i), .en_i(1'b1),  .data_i(exc_reg_data_i), .data_o(exc_reg_data_o));
  // register32 irq_h    (.clk_i(clk_i), .rst_i(rst_i), .en_i(1'b1),  .data_i(irq_reg_data_i), .data_o(irq_reg_data_o));

endmodule