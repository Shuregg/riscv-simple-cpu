module led_sb_ctrl(
/*
    SYSTEM BUS INTERFACE SIDE
*/
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        req_i,
  input  logic        write_enable_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,
  output logic [31:0] read_data_o,

/*
    PERIPHERAL CONNECTION INTERFACE SIDE
*/
  output logic [15:0]  led_o
);
//  parameter frequency = 32'd10_000_000;     // Hz
  logic [31:0]  frequency; 
  logic [15:0]  led_val;                    // Value register
  logic         led_mode;                   // Mode register
//   logic         led_rst                     //Reset register

  logic         write_req;      
  logic         read_req;       
// Checking the signal type      
  logic         is_val_addr;        
  logic         is_mode_addr;       
  logic         is_rst_addr;        
// Validity signals      
  logic         val_valid;      
  logic         mode_valid;     
  logic         rst_valid;      
// Local signals     
  logic         rst;        
  logic         val_en;                     // Value register enable signal
  logic         mode_en;                    // Mode register enable signal
  
  logic [31:0]  cntr;                       // Clock Counter (reset to zero  every second at a frequency of 10 MHz)
  logic         cntr_rst;
// Output register
  logic [31:0]  rd_reg_Q;                     // Read data register (Output data)
  logic         rd_reg_en;                    // Read data register (Enable)
  logic [31:0]  rd_reg_D;                     // Read data register (Input data)
  
  assign frequency = 32'd10_000_000;
  
  assign write_req = req_i && write_enable_i;
  assign read_req  = req_i && !write_enable_i;

  assign is_val_addr    = (addr_i == 32'h0 );
  assign is_mode_addr   = (addr_i == 32'h4 );
  assign is_rst_addr    = (addr_i == 32'h24);

  assign val_valid      = (write_data_i <= 32'hffff);
  assign mode_valid     = (write_data_i < 32'd2);
  assign rst_valid      = (write_data_i == 32'd1);

  assign rst            = (write_req && is_rst_addr && rst_valid  ) || (rst_i);
  assign val_en         = (write_req && is_val_addr  && val_valid );
  assign mode_en        = (write_req && is_mode_addr && mode_valid);
//  assign mode_en        = (write_req && is_mode_addr              );

  assign cntr_rst       = ((rst) || (cntr >= 2 * frequency) || (!led_mode));

  assign rd_reg_D       = is_val_addr ? ({16'd0, led_val}) : ({31'd0, led_mode});
  assign rd_reg_en      = read_req && ((is_val_addr) || (is_mode_addr));

  assign read_data_o    = rd_reg_Q;
  
//// To create short strobe of clk
//  logic [1:0] tmp_sync; 
//  logic       mode_opcode;
//  assign      mode_opcode = (write_data_i[15:0] == 16'hAAAA);
  
//  always_ff @(posedge clk_i) begin
//    if (rst) tmp_sync <= 1'd0;
//    else     tmp_sync <= {mode_opcode, tmp_sync[1]};
//  end


//  always_ff @(posedge clk_i) begin
//    if(rst)                     led_mode <=  1'b0;
//    else if(tmp_sync == 2'b10)  led_mode <= ~led_mode;
//    else                        led_mode <=  led_mode;  
//  end
  
//===============Value register implementation===============
  always_ff @(posedge clk_i) begin
    if(rst)             led_val <= 16'b0;
    else if(val_en)     led_val <= write_data_i[15:0];
    else                led_val <= led_val;
  end
//===============Mode register implementation===============
  always_ff @(posedge clk_i) begin
    if(rst)             led_mode <= 1'b0;
    else if(mode_en)    led_mode <= write_data_i[0];
    else                led_mode <= led_mode;
  end
//===============Clock counter==============================
  always_ff @(posedge clk_i) begin
    if(cntr_rst)                    cntr <= 32'b0;
//    if(rst)                         cntr <= 32'b0;
//    else if(cntr >= 2 * frequency)  cntr <= 32'b0;
//    else if(!led_mode)              cntr <= 32'b0;
    else                            cntr <= cntr + 32'b1;
  end
//===============LED OUT MUX LOGIC==============================
  always_comb begin
    case(cntr < frequency)
      1'b0: led_o <= 16'd0;
      1'b1: led_o <= led_val;
    endcase
  end
//===============READ DATA OUT REGISTER LOGIC========================
  always_ff @ (posedge clk_i) begin
    if(rst)             rd_reg_Q    <= 32'b0;
    else if(rd_reg_en)  rd_reg_Q    <= rd_reg_D;
    else                rd_reg_Q    <= rd_reg_Q;
  end
endmodule