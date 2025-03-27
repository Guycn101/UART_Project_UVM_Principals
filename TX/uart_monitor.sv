`ifndef UART_MONITOR_SV
`define  UART_MONITOR_SV
`include "uart_transaction.sv"

class uart_monitor #(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = (CLK_FREQ/BAUD_RATE));
   
	virtual uart_if.mp_mon tx_if_mon;
	mailbox mon2scb;
	
	
	function new(virtual uart_if.mp_mon tx_if_mon, mailbox mon2scb);
		this.tx_if_mon = tx_if_mon;
		this.mon2scb = mon2scb;
	endfunction
	
	task run;
			uart_transaction tx ;
		forever begin
			tx = new();
			
			// Wait for START bit (tx goes low)
			@(negedge tx_if_mon.cb_mon.tx);
			$display("[Monitor] Detected START bit (tx = 0) at %0t", $time);
			
			repeat(BAUD_COUNT/2)@(tx_if_mon.cb_mon);
			
			repeat(BAUD_COUNT)@(tx_if_mon.cb_mon);
			
			// Capture data bits
			for (int i = 0; i <SIZE; i++) begin
				tx.data[i] = tx_if_mon.cb_mon.tx;
				$display("[Monitor] Bit %0d = %b at %0t", i, tx.data[i], $time);
				repeat(BAUD_COUNT)@(tx_if_mon.cb_mon); // Wait for next bit
				//$display("[Monitor] Captured data bit %0d = %b at %0t", i, tx.data[i], $time);
				
			end
			
			
			repeat(BAUD_COUNT)@(tx_if_mon.cb_mon); // Stop bit
			
			$display("[Monitor] Captured data = %b at %0t", tx.data, $time);
			
			// Send transaction to scoreboard
			mon2scb.put(tx);
			
		end
	endtask
endclass
`endif