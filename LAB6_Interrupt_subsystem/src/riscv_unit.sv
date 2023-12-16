module riscv_unit(
  //Main singals
    input logic          clk_i
  //  ,input logic          rst_i
   ,input logic          resetn_i      //now it's reset with active '0'

  //Peripheral Input/Output signlas
  ,input  logic [15:0]  sw_i          //switches

  ,output logic [15:0]  led_o         //Light Emmiting Diodes (LEDs)

  ,input  logic         kclk_i        //Keyboard clock signal
  ,input  logic         kdata_i         //Keyboard data singal

  ,output logic [ 6:0]  hex_led_o     //7-segment indicator output
  ,output logic [ 7:0]  hex_sel_o     //Selector of indicators

  ,input  logic         rx_i          //UART receive line
  ,output logic         tx_o          //UART transceive line

  ,output logic [ 3:0]  vga_r_o       //VGA Red channel
  ,output logic [ 3:0]  vga_g_o       //VGA Green channel
  ,output logic [ 3:0]  vga_b_o       //VGA Blue channel
  ,output logic         vga_hs_o      //VGA Horizontal syncrhonization
  ,output logic         vga_vs_o      //VGA Vertical syncrhonization
);
//===================================WIRES===================================
//Core and Instr mem wires
  logic [31:0]  instr;
  logic [31:0]  instr_addr;
  logic         mem_req;
  logic         mem_we;
  logic [31:0]  mem_wd;
  logic [31:0]  mem_addr;
  logic [31:0]  rd;  
  logic         stall;
  logic [2:0]   mem_size;
  
  logic         irq_req;
  logic         irq_ret;
//Data mem wires
  logic [31:0]  data_mem_rd_o;
  logic         data_mem_ready_o;
//LSU wires
  // logic         lsu_we_o;
  logic         lsu_mem_req_o;
  logic [31:0]  lsu_mem_wd_o;
  logic [31:0]  lsu_mem_addr_o;
  logic         lsu_mem_we_o;
  logic [3:0]   lsu_mem_be_o;
  logic [31:0]  lsu_mem_rd_i; 

  logic [31:0]  lsu_data_i;
//Peripheral wires
  logic         sysclk;             //New clock signal 10 MHz
  logic         rst;                //Reset for new Clock (Active '1')
//One Hot Encoder 
  logic [255:0] one_hot_encoder_o;
  logic [31:0]  peripheral_addr;
//Peripheral devices require signals;
  logic         data_mem_sb_req;

  logic         sw_sb_ctrl_req;
  logic         sw_irq;
  logic [31:0]  sw_data_o;


  logic         led_sb_ctrl_req;
  logic [31:0]  led_data_o;

  logic         ps2_sb_ctrl_req;
  logic         hex_sb_ctrl_req;
  logic         uart_rx_sb_ctrl_req;
  logic         uart_tx_sb_ctrl_req;
  logic         vga_sb_ctrl_req;
//===================================Frequency(Clock) Divider===================================
sys_clk_rst_gen divider(.ex_clk_i(clk_i),.ex_areset_n_i(resetn_i),.div_i('d10),.sys_clk_o(sysclk), .sys_reset_o(rst));

//===================================One Hot Encoder and LSU signals===================================    
  assign one_hot_encoder_o    = 256'd1 << lsu_mem_addr_o[31:24];
  assign peripheral_addr      = {8'd0, lsu_mem_addr_o[23:0]};
// Devices ebable signals  
  assign data_mem_sb_req      = lsu_mem_req_o && one_hot_encoder_o[0];
  assign sw_sb_ctrl_req       = lsu_mem_req_o && one_hot_encoder_o[1];
  assign led_sb_ctrl_req      = lsu_mem_req_o && one_hot_encoder_o[2];
  assign ps2_sb_ctrl_req      = lsu_mem_req_o && one_hot_encoder_o[3];
  assign hex_sb_ctrl_req      = lsu_mem_req_o && one_hot_encoder_o[4];
  assign uart_rx_sb_ctrl_req  = lsu_mem_req_o && one_hot_encoder_o[5];
  assign uart_tx_sb_ctrl_req  = lsu_mem_req_o && one_hot_encoder_o[6];
  assign vga_sb_ctrl_req      = lsu_mem_req_o && one_hot_encoder_o[7];


  assign irq_req              = sw_irq;

  always_comb begin
//    lsu_data_i = 8'b0;
    case(lsu_mem_addr_o[31:24])
      8'd0:     lsu_data_i = data_mem_rd_o;
      8'd1:     lsu_data_i = sw_data_o;
      8'd2:     lsu_data_i = led_data_o;
      
      default:  lsu_data_i = 8'b0;
      // 8'd255: // Max index
    endcase
  end
//===================================INSTRUCTION MEMORY===================================
  instr_mem instr_mem_inst
  (
    .addr_i(instr_addr),
    .read_data_o(instr)
  );
//===================================RISC-V CORE===================================
  riscv_core core
  (
    .clk_i(sysclk),               //clk_i -> sysclk
    .rst_i(rst),                  //rst_i replaced by rst
    .stall_i(stall),         
    .instr_i(instr),
    .mem_rd_i(rd), 
    
    .irq_req_i(irq_req),
    
    .instr_addr_o(instr_addr),
    .mem_addr_o(mem_addr),
    .mem_size_o(mem_size),
    .mem_req_o(mem_req),
    .mem_we_o(mem_we),
    .mem_wd_o(mem_wd),
    
    .irq_ret_o(irq_ret)
  );
//===================================LOAD STORE UNIT (LSU)===================================
  riscv_lsu LSU_inst
  (  //Core interface
    .clk_i(sysclk),               //clk_i -> sysclk
    .rst_i(rst),                  //rst_i replaced by rst
    .core_req_i(mem_req),
    .core_we_i(mem_we),
    .core_size_i(mem_size),
    .core_addr_i(mem_addr),
    .core_wd_i(mem_wd),
    .core_rd_o(rd),
    .core_stall_o(stall),
  // Data Memory interface
    .mem_req_o(lsu_mem_req_o),
    .mem_we_o(lsu_mem_we_o),        //lsu_dev_we_o
    .mem_be_o(lsu_mem_be_o),
    .mem_addr_o(lsu_mem_addr_o),    //TODO
    .mem_wd_o(lsu_mem_wd_o),
    .mem_rd_i(lsu_data_i),          //TODO
    .mem_ready_i(data_mem_ready_o)  //
  );
//===================================EXTERNAL MEMORY (New data memory)===================================
  ext_mem ext_mem_inst
  (
    .clk_i(sysclk),                     //clk_i -> sysclk
    .mem_req_i(data_mem_sb_req),        //lsu_mem_req_o -> data_mem_sb_req
    .write_enable_i(lsu_mem_we_o),    
    .byte_enable_i(lsu_mem_be_o),               
    .addr_i(peripheral_addr),           //lsu_mem_addr_o -> peripheral_addr
    .write_data_i(lsu_mem_wd_o),
    
    .read_data_o(data_mem_rd_o),
    .ready_o(data_mem_ready_o)
  );
//===================================SWITCH CONTROLLER===================================
  sw_sb_ctrl switch_controller (    
    .clk_i(sysclk),
    .rst_i(rst),
    .req_i(sw_sb_ctrl_req),
    .write_enable_i(lsu_mem_we_o),
    .addr_i(peripheral_addr),
    .write_data_i(),                 //NO Connection
    .read_data_o(sw_data_o),
  //core interruption IF
    .interrupt_request_o(sw_irq),
    .interrupt_return_i(irq_ret),
  //peripheral connection
    .sw_i(sw_i)
  );
  //===================================LED CONTROLLER===================================
  led_sb_ctrl led_controller (
    .clk_i(sysclk),
    .rst_i(rst),
    .req_i(led_sb_ctrl_req),
    .write_enable_i(lsu_mem_we_o),
    .addr_i(peripheral_addr),
    .write_data_i(sw_data_o),
    .read_data_o(led_data_o),
    .led_o(led_o)
  );
endmodule