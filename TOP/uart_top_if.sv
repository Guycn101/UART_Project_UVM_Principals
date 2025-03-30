interface rx_if #(parameter SIZE = 8)(input bit clk);
	bit rst, rx_done, tx_en, tx_busy, rx ,tx;
	logic [SIZE-1:0] data_out, data_in;
	
	
	//Define inputs and outputs for driver and monitor
	
	clocking cb_drv @(posedge clk);
	output rst,tx_en,data_in;
	endclocking
	
	clocking cb_mon @(posedge clk);
	input data_out,rx_done, rst, tx_busy, data_in, tx_en, tx, rx;
	endclocking
	
	//Connects the signals to the components by the clocking blocks
	modport mp_dut(input clk, rst, tx_en, data_in, rx,  output rx_done, data_out, tx_busy, tx); 
	modport mp_drv(clocking cb_drv);
	modport mp_mon(clocking cb_mon);

endinterface