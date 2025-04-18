`include "uart_top_transaction.sv"

`ifndef UART_TOP_SCOREBOARD_SV
`define UART_TOP_SCOREBOARD_SV

class uart_top_scoreboard #(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = 9);
   
   mailbox mon2scb;
   mailbox drv2scb;
   int pass,fail;
   
   function new(mailbox mon2scb, mailbox drv2scb);
		this.mon2scb = mon2scb;
		this.drv2scb = drv2scb;
		pass = 0;
		fail = 0;
	endfunction
	
	
	task run;
		uart_top_transaction act_data , exp_data;
			forever begin
				drv2scb.get(exp_data);
				mon2scb.get(act_data);
				if(act_data.data_in == exp_data.data_in) begin
					pass++;
					$display("[Scoreboard] PASS: Expected = %b, Actual = %b at T = %0t", exp_data.data_in, act_data.data_in, $time);
				end else begin
					fail++;
					$display("[Scoreboard] FAIL: Expected = %b, Actual = %b at T = %0t", exp_data.data_in, act_data.data_in, $time);
				end
			end
	endtask
	
	task report;
		$display("[Scoreboard] Test Complete: Passes = %0d, Fails = %0d", pass, fail);
	endtask
	
endclass
`endif