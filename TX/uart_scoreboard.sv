`ifndef UART_SCOREBOARD_SV
`define  UART_SCOREBOARD_SV
`include "uart_transaction.sv"

class uart_scoreboard  #(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = (CLK_FREQ/BAUD_RATE));
   
	mailbox mon2scb;
	mailbox drv2scb;
	int pass, fail;
	
	function new(mailbox mon2scb,mailbox drv2scb);
		this.mon2scb = mon2scb;
		this.drv2scb = drv2scb;
		pass = 0;
		fail = 0;
	endfunction
	
	task run;	
		uart_transaction act_data, exp_data;
			forever begin
				drv2scb.get(exp_data);
				mon2scb.get(act_data);
				if(act_data.data == exp_data.data) begin
					pass++;
					$display("[Scoreboard] PASS: Expected = %b, Actual = %b at T = %0t", exp_data.data, act_data.data, $time);
				end else begin
					fail++;
					$display("[Scoreboard] FAIL: Expected = %b, Actual = %b at T = %0t", exp_data.data, act_data.data, $time);
				end
			end
	endtask
	
	task report;
		$display("[Scoreboard] Test Complete: Passes = %0d, Fails = %0d", pass, fail);
	endtask
endclass
`endif