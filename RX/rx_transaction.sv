`ifndef RX_TRANSACTION_SV
`define	RX_TRANSACTION_SV

class rx_transaction #(parameter SIZE = 8);
	bit [SIZE-1:0] data; //data sent to the DUT
	
	function new();
		this.data = 0;
	endfunction
	
	function void randomize_data();
		data = $urandom_range(0,(1<<SIZE)-1);
	endfunction
	
	function void display(string tag = "");
		$display("[T=%0t] %s: data = %b",$time, tag, data);
	endfunction
	
	
	endclass
`endif