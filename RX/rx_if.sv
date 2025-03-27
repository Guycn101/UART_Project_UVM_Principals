interface rx_if #(parameter SIZE = 8)(input bit clk);
	bit rst, rx, rx_done;
	logic [SIZE-1:0] data_out;
	
	
	//Define inputs and outputs for driver and monitor
	
	clocking cb_drv @(posedge clk);
	output rst,rx;
	input data_out,rx_done;
	endclocking
	
	clocking cb_mon @(posedge clk);
	input data_out,rx_done,rst,rx;
	endclocking
	
	//Connects the signals to the components by the clocking blocks
	modport mp_dut(input clk, rst, rx, output rx_done, data_out); 
	modport mp_drv(clocking cb_drv);
	modport mp_mon(clocking cb_mon);

endinterface