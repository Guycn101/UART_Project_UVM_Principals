`ifndef UART_GENERATOR_SV
`define  UART_GENERATOR_SV
`include "uart_transaction.sv"

class uart_generator
#(  parameter SIZE = 8);
	mailbox gen2drv;
	int num_transactions;
	event drv_done;
	
	function new(mailbox gen2drv,int num_transactions, event drv_done);
		this.gen2drv = gen2drv;
		this.num_transactions = num_transactions;
		this.drv_done = drv_done;
	endfunction
	
	task run;
		repeat(num_transactions) begin
			uart_transaction tx = new();
			tx.randomize_data();
			tx.display("Generator");
			gen2drv.put(tx);
			@(drv_done);
		end
	endtask
	
endclass
`endif