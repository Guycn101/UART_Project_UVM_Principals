`include "rx_transaction.sv"
`ifndef RX_DRIVER_SV
`define RX_DRIVER_SV

class rx_driver  #(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = (CLK_FREQ/BAUD_RATE));
	virtual rx_if.mp_drv rx_if_drv;
	mailbox gen2drv;
	mailbox drv2scb;
	event drv_done;
	
	function new(virtual rx_if.mp_drv rx_if_drv, mailbox gen2drv, mailbox drv2scb, event drv_done);
		this.rx_if_drv= rx_if_drv;
		this.gen2drv = gen2drv;
		this.drv2scb = drv2scb;
		this.drv_done = drv_done;
	endfunction
	
	task run;

		forever begin
			rx_transaction rx;
			gen2drv.get(rx);
			$display("[Driver] Fetched transaction data = %b at T =%0t",rx.data, $time); // After fetching transaction
			rx_if_drv.cb_drv.rx <= 0; // Drive Start bit
			repeat(BAUD_COUNT)@(rx_if_drv.cb_drv); // wait BAUD_COUNT
			$display("[Driver] Start bit driven rx = %b at  T =%0t",rx_if_drv.cb_drv.rx, $time); // after fetching start bit
			for (int i = 0; i < SIZE; i++) begin // Drive data bits	
				rx_if_drv.cb_drv.rx <= rx.data[i];
				repeat(BAUD_COUNT)@(rx_if_drv.cb_drv); // wait BAUD_COUNT
				$display("[Driver] Data bits driven :data bit %d = %b ,rx = %b at  T =%0t",i, rx.data[i],rx_if_drv.cb_drv.rx, $time); // after each data bit
			end
			rx_if_drv.cb_drv.rx <= 1; // Drive Stop bit
			repeat(BAUD_COUNT)@(rx_if_drv.cb_drv); // wait BAUD_COUNT
			$display("[Driver] Stop bit driven rx = %b at  T =%0t",rx_if_drv.cb_drv.rx, $time); // after fetching stop bit
			drv2scb.put(rx);
			->drv_done;
			$display("[Driver] Transaction complete, data = %b at T= %t", rx.data, $time); // 5. After drv_done
 
		end
	endtask
				
endclass
`endif