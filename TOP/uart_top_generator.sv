`include "uart_top_transaction.sv"
`ifndef UART_TOP_GENERATOR_SV
`define  UART_TOP_GENERATOR_SV	


class uart_top_generator
	#(  parameter SIZE = 8);
	mailbox gen2drv;
	int num_transactions;
	event drv_done;

	function new(mailbox gen2drv, int num_transactions, event drv_done);
		this.gen2drv = gen2drv;
		this.num_transactions = num_transactions;
		this.drv_done = drv_done;
	endfunction

	task run();
			repeat(num_transactions) begin
				uart_top_transaction uart = new();
				uart.randomize_data();
				uart.display("Generator");
				gen2drv.put(uart);
				@(drv_done);
			end
	endtask
	
endclass
`endif
		
	