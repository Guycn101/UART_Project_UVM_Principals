`include "uart_top_generator.sv"
`include "uart_top_driver.sv"
`include "uart_top_monitor.sv"
`include "uart_top_scoreboard.sv"

`ifndef UART_TOP_ENVIRONMENT_SV
`define UART_TOP_ENVIRONMENT_SV

class uart_top_env #(parameter SIZE = 8,
                     parameter BAUD_RATE = 115200,
                     parameter CLK_FREQ = 1000000,
                     parameter BAUD_COUNT = 9,
                     parameter NUM_OF_TRANS = 100);
	uart_top_generator #(SIZE) gen;
	uart_top_driver #(SIZE, BAUD_RATE, CLK_FREQ, BAUD_COUNT) drv;
	uart_top_monitor #(SIZE, BAUD_RATE, CLK_FREQ, BAUD_COUNT) mon;
	uart_top_scoreboard #(SIZE, BAUD_RATE, CLK_FREQ, BAUD_COUNT) scb;
	mailbox gen2drv;
	mailbox mon2scb;
	mailbox drv2scb;
	event drv_done;
	virtual uart_top_if.mp_mon uart_top_if_mon;
	virtual uart_top_if.mp_drv uart_top_if_drv;
	
	function new (virtual uart_top_if.mp_mon uart_top_if_mon, virtual uart_top_if.mp_drv uart_top_if_drv);
		this.uart_top_if_mon = uart_top_if_mon;
		this.uart_top_if_drv = uart_top_if_drv;
		gen2drv = new();
		drv2scb = new();
		mon2scb = new();
		gen = new(gen2drv, NUM_OF_TRANS, drv_done);
		drv = new(uart_top_if_drv, gen2drv,drv2scb, drv_done);
		mon = new(uart_top_if_mon, mon2scb);
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
		#10;
		scb.report();
		$finish;
	endtask
endclass
`endif
		