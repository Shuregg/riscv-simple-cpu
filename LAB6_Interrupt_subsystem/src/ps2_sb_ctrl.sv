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
//============Parameters============
// PS2-Controller register adresses
  localparam SCANCODE_REG_ADDR = 32'h0;
  localparam UNREADED_REG_ADDR = 32'h4;
  localparam RESET_REG_ADDR    = 32'h24;
//============Main Wires/Registers============
// PS2-Controller side
  logic [7:0] scan_code;
  logic       scan_code_is_unread;
// PS2-Receiver side
  logic [7:0] keycode;
  logic       keycode_is_valid;
//============Additional Signals============
// R/W request signals
  logic       read_req;
  logic       write_req;
// Address check signals
  logic       is_scancode_addr;
  logic       is_unreaded_scancode_addr;
  logic       is_rst_addr;
// Reset value validity signal
  logic       rst_valid;

//============Signal Assigning============
  assign      read_req                  = (req_i && !write_enable_i);
  assign      write_req                 = (req_i && write_enable_i);

  assign      is_scancode_addr          = (addr_i == 32'h0);
  assign      is_unreaded_scancode_addr = (addr_i == 32'h4);
  assign      is_rst_addr               = (addr_i == 32'h24);

  assign      rst_valid                 = (write_data_i < 2'd2);
//============Module Instances============
  PS2Receiver PS2_Receiver_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .kclk_i(kclk_i),
    .kdata_i(kdata_i),
    .keycodeout_o(keycode),
    .keycode_valid_o(keycode_is_valid)
  );

//============Controller Logic============

  assign interrupt_request_o = scan_code_is_unread;

  always_ff @(posedge clk_i) begin
    if(rst_i) begin
      scan_code           <= 8'b0;
      scan_code_is_unread <= 1'b0;
    end else begin
      case(keycode_is_valid)
        1'b1: begin
          scan_code           <= keycode;
          scan_code_is_unread <= 1'b1;
        end
        1'b0: begin

          if(interrupt_return_i)
            scan_code_is_unread <= 1'b0;

          if(read_req) begin
            case(addr_i)
              SCANCODE_REG_ADDR : begin
                scan_code_is_unread <= 1'b0;
              end
              UNREADED_REG_ADDR : begin
                scan_code_is_unread <= scan_code_is_unread;
              end
              default           : begin
                scan_code_is_unread <= scan_code_is_unread;
              end
            endcase
          end 
          else if(write_req) begin
            case(addr_i)
              RESET_REG_ADDR    : begin
                if(rst_valid && write_data_i == 32'd1) begin
                  scan_code           <= 8'b0;
                  scan_code_is_unread <= 1'b0;
                end else begin
                  scan_code           <= scan_code
                  scan_code_is_unread <= scan_code_is_unread;
                end
              end
              default           : begin
                scan_code           <= scan_code
                scan_code_is_unread <= scan_code_is_unread;
              end
            endcase
          end
        end 
      endcase
    end
  end

//============Read/Write output============
  always_comb begin
    if(rst_i) begin
      read_data_o = 32'b0;
    end else begin
      if(read_req) begin
        case(addr_i)
          SCANCODE_REG_ADDR : begin
            read_data_o = {24'b0, scan_code};
          end
          UNREADED_REG_ADDR : begin
            read_data_o = {31'b0, scan_code_is_unread};
          end
          default           : begin
            read_data_o = read_data_o;
          end
        endcase
      end 
    end
  end


  // always_ff @(posedge clk_i) begin
  //   if(rst_i) begin
  //     scan_code             <= 8'b0;
  //     scan_code_is_unread   <= 1'b0;
  //   end
  //   else begin
  //     case(keycode_is_valid)
  //       1'b0: begin
  //         if(read_req && is_scancode_addr) begin
  //           read_data_o         <= {24'b0, scan_code};
  //           scan_code_is_unread <= 1'b0;
  //         end
  //         else if(read_req && is_unreaded_scancode_addr) begin
  //           read_data_o         <= {31'b0, scan_code_is_unread};
  //         end
  //         else if(interrupt_return_i) begin
  //           scan_code_is_unread <= 1'b0;
  //         end
  //       end       
  //       1'b1: begin 
  //         scan_code             <= keycode;   
  //         scan_code_is_unread   <= 1'b1;
  //       end
  //     endcase
  //   end
  // end
endmodule