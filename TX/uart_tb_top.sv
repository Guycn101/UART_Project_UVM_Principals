`ifndef UART_TB_TOP_SV
`define UART_TB_TOP_SV

`include "uart_test.sv"
`include "uart_if.sv"
`include "transmission.sv"

module uart_tb_top #(  parameter SIZE = 8);
	bit clk = 0;
	always # 500 clk = ~clk;
	
	uart_if tx_if_inst(clk);
	
	// instances
	transmission dut (
					.clk(clk),
					.rst(tx_if_inst.rst),
					.data_in(tx_if_inst.data_in),
					.tx_en(tx_if_inst.tx_en),
					.tx(tx_if_inst.tx),
					.tx_busy(tx_if_inst.tx_busy)
		);

		
		uart_test #(SIZE) test;
	
	initial begin
		$display("[TB] Starting simulation at %0t", $time);
		tx_if_inst.rst = 1;       
		#1000;
		tx_if_inst.rst = 0;
		#10;
		test = new(tx_if_inst.mp_mon, tx_if_inst.mp_drv);
		test.run();
	end
endmodule
`endif