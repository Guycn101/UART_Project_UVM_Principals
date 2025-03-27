`ifndef UART_DRIVER_SV
`define UART_DRIVER_SV
`include "uart_transaction.sv"

class uart_driver #(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = (CLK_FREQ/BAUD_RATE));
	virtual uart_if.mp_drv tx_if_drv;
	mailbox gen2drv;
	mailbox drv2scb;
	event drv_done;
	
	function new(virtual uart_if.mp_drv tx_if_drv, mailbox gen2drv, mailbox drv2scb, event drv_done);
		this.tx_if_drv= tx_if_drv;
		this.gen2drv = gen2drv;
		this.drv2scb = drv2scb;
		this.drv_done = drv_done;
	endfunction
	
	task run;
		forever begin
			uart_transaction tx;
			gen2drv.get(tx);
			$display("[Driver] Fetched transaction data = %b at T =%0t",tx.data, $time);
			//Wait for DUT to be idle
			wait(tx_if_drv.cb_drv.tx_busy == 0);
			
			tx_if_drv.cb_drv.data_in <= tx.data; // Drive data
			tx_if_drv.cb_drv.tx_en <= 1; //Drive tx_en bit
			repeat(2)@(tx_if_drv.cb_drv); 
			$display("[Driver] Driven data_in = %b, tx_en = %b at T = %0t", tx.data, tx_if_drv.cb_drv.tx_en, $time);// after fetching start bit
			
			tx_if_drv.cb_drv.tx_en <= 0; //Drive tx_en bit low
			//Wait for transmission to complete
			wait(tx_if_drv.cb_drv.tx_busy == 1);//DUT start
			wait(tx_if_drv.cb_drv.tx_busy == 0);//DUT finish
			$display("[Driver] Transmission complete, tx_busy = %b at T = %0t", tx_if_drv.cb_drv.tx_busy, $time);
			
			
			drv2scb.put(tx);
			->drv_done;
			$display("[Driver] Transaction complete, data = %b at T = %0t", tx.data, $time);
			repeat(BAUD_COUNT*2)@(tx_if_drv.cb_drv);
			
		end
	endtask
endclass
`endif