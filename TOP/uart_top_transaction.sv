`ifndef UART_TOP_TRANSACTION_SV
`define	UART_TOP_TRANSACTION_SV

class uart_top_transaction #(parameter SIZE = 8);
	bit [SIZE-1:0] data_in; //data sent to the DUT
	
	function new();
		this.data_in = 0;
	endfunction
	
	function void randomize_data();
		data_in = $urandom_range(0,(1<<SIZE)-1);
	endfunction
	
	function void display(string tag = "");
		$display("[T=%0t] %s: data = %b",$time, tag, data_in);
	endfunction
	
	
	endclass
`endif