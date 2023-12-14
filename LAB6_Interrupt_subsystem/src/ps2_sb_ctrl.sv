module ps2_sb_ctrl(
/*
    System bus interface side
*/
  input  logic         clk_i,
  input  logic         rst_i,
  input  logic [31:0]  addr_i,
  input  logic         req_i,
  input  logic [31:0]  write_data_i,
  input  logic         write_enable_i,
  output logic [31:0]  read_data_o,

/*
    Core Interrupt interface side
*/

  output logic        interrupt_request_o,
  input  logic        interrupt_return_i,

/*
   receive from keyboard
*/
  input  logic kclk_i,
  input  logic kdata_i
);

  logic [7:0] scan_code;
  logic       scan_code_is_unread;

  logic [7:0] keycode;
  logic       keycode_is_valid;

  logic       read_req;
  logic       write_req;

  logic       is_scancode_addr;
  logic       is_unreaded_scancode_addr;
  logic       is_rst_addr;

  logic       rst_valid;


  logic       rst;

  assign      read_req                  = (req_i && !write_enable_i);
  assign      write_req                 = (req_i && write_enable_i);

  assign      is_scancode_addr          = (addr_i == 32'h00_0000_00);
  assign      is_unreaded_scancode_addr = (addr_i == 32'h00_0000_04);
  assign      is_rst_addr               = (addr_i == 32'h00_0000_24);

  assign      rst_valid                 = (write_data_i < 2'd2);

  PS2Receiver PS2Receiver_isnt (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .kclk_i(kclk_i),
    .kdata_i(kdata_i),
    .keycodeout_o(keycode),
    .keycode_valid_o(keycode_is_valid)
  );

  always_ff @(posedge clk_i) begin
    if(rst_i) begin
      scan_code             <= 8'b0;
      scan_code_is_unread   <= 1'b0;
    end
    else begin
      case(keycode_is_valid)
        1'b0: begin
          scan_code             <= scan_code;           //???
          scan_code_is_unread   <= scan_code_is_unread; //???
        end       
        1'b1: begin 
          scan_code             <= keycode;   
          scan_code_is_unread   <= 1'b1;
        end
      endcase
    end
  end

  always_ff @(posedge clk_i) begin                   //FF!!!
    if(write_req && is_scancode_addr) begin
      read_data_o <= {24'b0, scan_code};
      if(!keycode_is_valid)
        scan_code_is_unread <= 1'b0;
    end
  end
endmodule