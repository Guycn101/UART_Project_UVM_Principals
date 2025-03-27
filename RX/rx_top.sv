`ifndef RX_TOP_SV
`define RX_TOP_SV

`include "rx_test.sv"
`include "rx_if.sv"
`include "reciever.sv"

module rx_top #(parameter SIZE = 8);
	bit clk;
	always #500 clk = ~clk;
	
	rx_if rx_if_inst(clk);

	reciever dut(
			.clk(clk),
			.rst(rx_if_inst.rst),
			.rx(rx_if_inst.rx),
			.rx_done(rx_if_inst.rx_done),
			.data_out(rx_if_inst.data_out)
	);
		
	rx_test #(SIZE) test;
	
	initial begin
		$display("[TOP] Simulation started at %t" , $time);
		rx_if_inst.rst = 1;
		#10000;
		rx_if_inst.rst = 0;
		#10;
		test = new(rx_if_inst.mp_mon, rx_if_inst.mp_drv);
		test.run();
	end
	
endmodule
`endif