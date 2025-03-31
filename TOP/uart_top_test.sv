`ifndef UART_TOP_TEST_SV
`define UART_TOP_TEST_SV

`include "uart_top_env.sv"

class uart_top_test #(parameter SIZE = 8,
                      parameter BAUD_RATE = 115200,
                      parameter CLK_FREQ = 1000000,
                      parameter BAUD_COUNT = 9,
                      parameter NUM_OF_TRANS = 100);
    uart_top_env #(SIZE, BAUD_RATE, CLK_FREQ, BAUD_COUNT, NUM_OF_TRANS) env;
	virtual uart_top_if.mp_mon uart_top_if_mon;
	virtual uart_top_if.mp_drv uart_top_if_drv;
		
	function new(virtual uart_top_if.mp_mon uart_top_if_mon, virtual uart_top_if.mp_drv uart_top_if_drv);
	this.uart_top_if_mon = uart_top_if_mon;
	this.uart_top_if_drv = uart_top_if_drv;
	env = new(uart_top_if_mon, uart_top_if_drv);
	endfunction
		
	task run();
		$display("[Test] Starting UART test at %0t", $time);
		env.run();
	endtask
endclass
`endif