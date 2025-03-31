`include "rx_transaction.sv"

`ifndef RX_MOINTOR_SV
`define RX_MOINTOR_SV

class rx_monitor #(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = (CLK_FREQ/BAUD_RATE));
   
   virtual rx_if.mp_mon rx_if_mon;
   mailbox mon2scb;
   
   function new(virtual rx_if.mp_mon rx_if_mon, mailbox mon2scb);
		this.rx_if_mon = rx_if_mon;
		this.mon2scb = mon2scb;
	endfunction
	
	task run;
		forever begin
			@(rx_if_mon.cb_mon)if(rx_if_mon.cb_mon.rx_done)begin
				rx_transaction rx = new();
				rx.data = rx_if_mon.cb_mon.data_out;
				$display("[Monitor] Captured data_out = %b at T = %0t", rx.data, $time);
				mon2scb.put(rx);
				end
		end
	endtask
			
endclass
`endif