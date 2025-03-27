`ifndef UART_TEST_SV
`define UART_TEST_SV

`include "uart_env.sv"

class uart_test #(parameter SIZE = 8);
	uart_env env;
	virtual uart_if.mp_mon tx_if_mon;
	virtual uart_if.mp_drv tx_if_drv;
		
	function new(virtual uart_if.mp_mon tx_if_mon, virtual uart_if.mp_drv tx_if_drv);
	this.tx_if_mon= tx_if_mon;
	this.tx_if_drv= tx_if_drv;
	env = new(tx_if_mon,tx_if_drv);
	endfunction
		
	task run();
		$display("[Test] Starting UART test at %0t", $time);
		env.run();
	endtask
endclass
`endif