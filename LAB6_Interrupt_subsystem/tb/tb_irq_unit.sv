//////////////////////////////////////////////////////////////////////////////////
// Company: MIET
// Engineer: Andrei Solodovnikov

// Module Name:    tb_riscv_unit
// Project Name:   RISCV_practicum
// Target Devices: Nexys A7-100T
// Description: tb for riscv unit with irq support

//////////////////////////////////////////////////////////////////////////////////

module tb_irq_unit();
    reg clk;
    reg rst;
    logic [15:0]  LED;
    logic [15:0]  SW;
    
    riscv_unit unit(
    .clk_i(clk),
    .resetn_i(!rst),

    .sw_i(SW),          
    .led_o(LED),         

    .kclk_i(),
    .kdata(),        

    .hex_led_o(),
    .hex_sel_o(),

    .rx_i(),         
    .tx_o(),         

    .vga_r_o(),      
    .vga_g_o(), 
    .vga_b_o(),
    .vga_hs_o(),    
    .vga_vs_o()
    );



    initial begin
      repeat(10000) begin
        @(posedge clk);
      end
      // $fatal(1, "Test has been interrupted by watchdog timer");
      $display("\n Test has been interrupted by watchdog timer \n");
      $finish;
    end

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $display( "\nStart test: \n\n==========================\nCLICK THE BUTTON 'Run All'\n==========================\n"); $stop();
        rst = 1;
        unit.irq_req = 0;
        repeat(200) @(posedge clk);
        #50;
        rst = 0;
        #200;
        SW = 16'h0001;
        #200;
        SW = 16'h0001;
        #200;
        SW = 16'h0001;
        #200;
        SW = 16'h0001;
        #200;
        SW = 16'h0002;
        #200;
        SW = 16'h0002;
        #200;
        SW = 16'h0002;
        #200;
        SW = 16'h0002;
        #200;
        SW = 16'h0003;
        #200;
        SW = 16'h0003;
        #200;
        SW = 16'h0003;
        #200;
        SW = 16'h0003;
        #200;
        SW = 16'h000f;
        #200;
        SW = 16'h000f;
        #200;
        SW = 16'h000f;
        #200;
        SW = 16'h000f;
        #200;
        SW = 16'h0001;
        #200;
        SW = 16'h0001;
        #200;
        SW = 16'h0001;
        #200;
        SW = 16'h0001;
        #200;
        SW = 16'h0002;
        #200;
        SW = 16'h0002;
        #200;
        SW = 16'h0002;
        #200;
        SW = 16'h0002;
        #200;
        SW = 16'h0003;
        #200;
        SW = 16'h0003;
        #200;
        SW = 16'h0003;
        #200;
        SW = 16'h0003;
        #200;
        SW = 16'h000f;
        #200;
        SW = 16'h000f;
        #200;
        SW = 16'h000f;
        #200;
        SW = 16'h000f;
        #200;
        
        repeat(2000)@(posedge clk);
        $display("\n The test is over \n See the internal signals of the module on the waveform \n");
        $finish;        
        
    end

endmodule