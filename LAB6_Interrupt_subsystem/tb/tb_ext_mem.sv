module tb_ext_mem();

  logic         CLK;
  logic         WE;
  logic         MREQ;
  logic [ 3:0]  BE;
  logic [31:0]  ADDR;
  logic [31:0]  DATA_W;
  logic [31:0]  DATA_R;
  logic         RDY;

  logic         error_now;
  
    ext_mem ext_mem_UT(
        .clk_i(CLK),
        .write_enable_i(WE),
        .mem_req_i(MREQ),
        .byte_enable_i(BE),
        .addr_i(ADDR),
        .write_data_i(DATA_W),
        .read_data_o(DATA_R),
        .ready_o(RDY)
    );

    integer error_counter = 0;
   
   parameter PERIOD = 20;
    
    initial begin
//      RESET
        CLK     =   0;
        WE      =   0;
        MREQ    =   0;
        BE      =   4'b0000;
        ADDR    =   32'h0;
        DATA_W  =   32'hDF_17_DA_7A;     // 9E5E7_DA7 - RESET DATA === DF17_DA7A - default data
        
        #(PERIOD);
//      WRITE #1   
        MREQ    =   1;
        WE      =   1;
        BE      =   4'b1111;
        ADDR    =   32'h4;
        DATA_W  =   32'hAB_CD_EF_90;
        
        #(PERIOD);
//      READ #1 
        MREQ    =   1;
        WE      =   0;
        BE      =   4'b1111;
        ADDR    =   32'h4;
        
        #(PERIOD);
//        TEST #1
        if(DATA_R !== 32'hAB_CD_EF_90) begin
            error_counter = error_counter + 1;
            $display("\n======================\nERROR #%d:", error_counter);
            $display("Invalid data:        %h;\ncorrect data:        %h;\nTime = %t ps.", DATA_R, 32'hAB_CD_EF_90, $time);
    
        end
            
            
        #(PERIOD);
//      WRITE #2  
        MREQ    =   1;
        WE      =   1;
        BE      =   4'b1110;
        ADDR    =   32'h4;
        DATA_W  =   32'h12_34_56_78;
        
        #(PERIOD);
//      READ #2 
        MREQ    =   1;
        WE      =   0;
        ADDR    =   32'h4;
        
        #(PERIOD);
//        TEST #2
        if(DATA_R !== 32'h12_34_56_90) begin
            error_counter = error_counter + 1;
            $display("\n======================\nERROR #%d:", error_counter);
            $display("Invalid data:        %h;\ncorrect data:        %h;\nTime = %t ps.", DATA_R, 32'h12_34_56_90, $time);
        end
            
        #(PERIOD);
//      WRITE #3  
        MREQ    =   1;
        WE      =   1;
        BE      =   4'b1101;
        ADDR    =   32'h4;
        DATA_W  =   32'hBE_A7_FA_CE;
        
        #(PERIOD);
//      READ #3 
        MREQ    =   1;
        WE      =   0;
        ADDR    =   32'h4;
        
        #(PERIOD);
//        TEST #3
        if(DATA_R !== 32'hBE_A7_56_CE) begin
            error_counter = error_counter + 1;
            $display("\n======================\nERROR #%d:", error_counter);
            $display("Invalid data:        %h;\ncorrect data:        %h;\nTime = %t ps.", DATA_R, 32'hBE_A7_56_CE, $time);
        end
        
        #(PERIOD);
//      WRITE #4  
        MREQ    =   1;
        WE      =   1;
        BE      =   4'b1011;
        ADDR    =   32'h4;
        DATA_W  =   32'hDE_AD_1E_AF;
        
        #(PERIOD);
//      READ #4 
        MREQ    =   1;
        WE      =   0;
        ADDR    =   32'h4;
        
        #(PERIOD);
//        TEST #4
        if(DATA_R !== 32'hDE_A7_1E_AF) begin
            error_counter = error_counter + 1;
            $display("\n======================\nERROR #%d:", error_counter);
            $display("Invalid data:        %h;\ncorrect data:        %h;\nTime = %t ps.", DATA_R, 32'hDE_A7_1E_AF, $time);
        end
        
        #(PERIOD);
//      WRITE #5  
        MREQ    =   1;
        WE      =   1;
        BE      =   4'b0111;
        ADDR    =   32'h4;
        DATA_W  =   32'h51_CC_BE_A7;
        
        #(PERIOD);
//      READ #5 
        MREQ    =   1;
        WE      =   0;
        BE      =   4'b1101;
        ADDR    =   32'h4;
        
        #(PERIOD);
//        TEST #5
        if(DATA_R !== 32'hDE_CC_BE_A7) begin
            error_counter = error_counter + 1;
            $display("\n======================\nERROR #%d:", error_counter);
            $display("Invalid data:        %h;\ncorrect data:        %h;\nTime = %t ps.", DATA_R, 32'hDE_CC_BE_A7, $time);
        end
            
        $display("\nTest is over. Total number of errors: %d.", error_counter);
        $finish();
    end
    
    always begin
        CLK = 1'b0;
        #(PERIOD/2) CLK = 1'b1;
        #(PERIOD/2);
    end
endmodule

