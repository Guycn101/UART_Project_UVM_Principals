`include "rx_generator.sv"
`include "rx_driver.sv"
`include "rx_monitor.sv"
`include "rx_scoreboard.sv"

`ifndef RX_ENVIRONMENT_SV
`define RX_ENVIRONMENT_SV

class rx_env #(parameter SIZE = 8,
				NUM_OF_TRANS = 10);
	rx_generator gen;
	rx_driver drv;
	rx_monitor mon;
	rx_scoreboard scb;
	mailbox gen2drv;
	mailbox mon2scb;
	mailbox drv2scb;
	event drv_done;
	virtual rx_if.mp_mon rx_if_mon;
	virtual rx_if.mp_drv rx_if_drv;
	
	function new (virtual rx_if.mp_mon rx_if_mon, virtual rx_if.mp_drv rx_if_drv);
		this.rx_if_mon = rx_if_mon;
		this.rx_if_drv = rx_if_drv;
		gen2drv = new();
		drv2scb = new();
		mon2scb = new();
		gen = new(gen2drv, NUM_OF_TRANS, drv_done);
		drv = new(rx_if_drv, gen2drv,drv2scb, drv_done);
		mon = new(rx_if_mon, mon2scb);
		scb = new(mon2scb, drv2scb);
	endfunction
		
		
	task run;
		$display("[Environment] Starting test at %0t", $time);
		
		fork
			begin
				$display("[Environment] Starting generator at %0t", $time);
				gen.run();
			end
			begin
				$display("[Environment] Starting driver at %0t", $time);
				drv.run();
			end
			begin
				$display("[Environment] Starting monitor at %0t", $time);
				mon.run();
			end
			begin
				$display("[Environment] Starting scoreboard at %0t", $time);
				scb.run();
			end
		join_none
		
		repeat(NUM_OF_TRANS)@(drv_done);
		scb.report();
		$finish;
	endtask
endclass
`endif
		