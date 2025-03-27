`include "rx_transaction.sv"
`ifndef RX_GENERATOR_SV
`define RX_GENERATOR_SV	


class rx_generator
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
				rx_transaction rx = new();
				rx.randomize_data();
				rx.display("Generator");
				gen2drv.put(rx);
				@(drv_done);
			end
	endtask
	
endclass
`endif
		
	