`ifndef UART_TRANSACTION_SV
`define UART_TRANSACTION_SV
class uart_transaction #(parameter SIZE = 8);
	bit [SIZE-1:0] data;
	
	function new();
		data = 0;
	endfunction
	
	function void randomize_data();
		data = $urandom_range(0,(1<<SIZE) -1);
	endfunction
	
	function void display(string tag = "");
		$display("[T=%0t] %s: data = %b",$time, tag, data);
	endfunction
		
endclass
`endif