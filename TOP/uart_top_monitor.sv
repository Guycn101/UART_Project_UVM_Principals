`include "uart_top_transaction.sv"

`ifndef UART_TOP_MONITOR_SV
`define UART_TOP_MONITOR_SV

class uart_top_monitor #(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = 9);
   
   virtual uart_top_if.mp_mon uart_top_if_mon;
   mailbox mon2scb;
   
   function new(virtual uart_top_if.mp_mon uart_top_if_mon, mailbox mon2scb);
		this.uart_top_if_mon = uart_top_if_mon;
		this.mon2scb = mon2scb;
	endfunction
	
	task run;
		uart_top_transaction uart;
		forever begin
			@(posedge uart_top_if_mon.cb_mon.rx_done);
				uart = new();
				uart.data_in = uart_top_if_mon.cb_mon.data_out;
				$display("[Monitor] Captured data_out = %b at T = %0t", uart.data_in, $time);
				mon2scb.put(uart);
				end
	endtask
	
endclass
`endif