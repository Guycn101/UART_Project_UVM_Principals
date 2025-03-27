interface uart_if #(parameter SIZE = 8)(input bit clk);
	logic rst, tx_en, tx, tx_busy;
	logic [SIZE-1:0] data_in;

	//Define inputs and outputs for driver and monitor
	
	clocking cb_drv @(posedge clk);
	output rst,tx_en, data_in;
	input tx,tx_busy;
	endclocking
	
	clocking cb_mon @(posedge clk);
	input rst, tx_en, data_in, tx, tx_busy;
	endclocking
	
	//Connects the signals to the components by the clocking blocks
	modport mp_dut(input clk, rst, tx_en,data_in, output tx_busy, tx); 
	modport mp_drv(clocking cb_drv);
	modport mp_mon(clocking cb_mon);

endinterface