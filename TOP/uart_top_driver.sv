`include "uart_top_transaction.sv"
`ifndef UART_TOP_DRIVER_SV
`define UART_TOP_DRIVER_SV

class uart_top_driver  #(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = 9);
	virtual uart_top_if.mp_drv uart_top_if_drv;
	mailbox gen2drv;
	mailbox drv2scb;
	event drv_done;
	
	function new(virtual uart_top_if.mp_drv uart_top_if_drv, mailbox gen2drv, mailbox drv2scb, event drv_done);
		this.uart_top_if_drv= uart_top_if_drv;
		this.gen2drv = gen2drv;
		this.drv2scb = drv2scb;
		this.drv_done = drv_done;
	endfunction
	
	task run;
    forever begin
        uart_top_transaction uart;
        gen2drv.get(uart);
        $display("[Driver] Fetched transaction data = %b at T =%0t", uart.data_in, $time);
        @(uart_top_if_drv.cb_drv);
        uart_top_if_drv.cb_drv.data_in <= uart.data_in;
        uart_top_if_drv.cb_drv.tx_en <= 1; 
        $display("[Driver] Set tx_en = 1, data_in = %b at T =%0t", uart.data_in, $time);
        @(uart_top_if_drv.cb_drv);
        uart_top_if_drv.cb_drv.tx_en <= 0;
        $display("[Driver] Set tx_en = 0 at T =%0t", $time);
        wait(uart_top_if_drv.cb_drv.tx_busy == 0);
        $display("[Driver] TX complete, data_in = %b at T=%0t", uart.data_in, $time);
        drv2scb.put(uart);
        ->drv_done;
        $display("[Driver] Transaction complete, data = %b at T= %t", uart.data_in, $time);
        #(BAUD_COUNT*10000);  // Wait 90 µs
    end
	endtask
				
endclass
`endif