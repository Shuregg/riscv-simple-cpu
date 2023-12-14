module sw_sb_ctrl(
/*
    Ча�?ть интерфей�?а модул�?, отвечающа�? за подключение к �?и�?темной шине
*/
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        req_i,
  input  logic        write_enable_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,  // не и�?пользует�?�?, добавлен дл�?
                                     // �?овме�?тимо�?ти �? �?и�?темной шиной
  output logic [31:0] read_data_o,

/*
    Ча�?ть интерфей�?а модул�?, отвечающа�? за отправку запро�?ов на прерывание
    проце�?�?орного �?дра
*/

  output logic        interrupt_request_o,
  input  logic        interrupt_return_i,

/*
    Ча�?ть интерфей�?а модул�?, отвечающа�? за подключение к периферии
*/
  input logic [15:0]  sw_i
);

  logic     read_req;
  logic     write_req;

  logic [31:0]  rd_reg_Q;
  logic [31:0]  rd_reg_D;
  logic         rd_reg_en;

  logic         addr_is_valid;
  logic         sw_changed;

  assign    write_req           = req_i && write_enable_i;

  assign    addr_is_valid       = (addr_i == 32'b00_0000_00);
    
  assign    rd_reg_en           = read_req && addr_is_valid;
  assign    rd_reg_D            = {16'b0, sw_i};
    
  assign    sw_changed          = (rd_reg_D != rd_reg_Q);

  assign    interrupt_request_o = (sw_changed && !interrupt_return_i);
  assign    read_data_o         = rd_reg_Q;


  always_ff @(posedge clk_i) begin
    if(rst_i)
      rd_reg_Q <= 32'b0;
    else
      rd_reg_Q <= rd_reg_D;
  end
endmodule