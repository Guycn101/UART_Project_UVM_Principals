`ifndef RX_TEST_SV
`define RX_TEST_SV

`include "rx_env.sv"

class rx_test #(parameter SIZE = 8);
	rx_env env;
	virtual rx_if.mp_mon rx_if_mon;
	virtual rx_if.mp_drv rx_if_drv;
		
	function new(virtual rx_if.mp_mon rx_if_mon, virtual rx_if.mp_drv rx_if_drv);
	this.rx_if_mon = rx_if_mon;
	this.rx_if_drv = rx_if_drv;
	env = new(rx_if_mon, rx_if_drv);
	endfunction
		
	task run();
		$display("[Test] Starting UART test at %0t", $time);
		env.run();
	endtask
endclass
`endif