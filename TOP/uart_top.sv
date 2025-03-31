module uart_top
#(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = (CLK_FREQ/BAUD_RATE))
 (   
    input clk,    
    input rst,
    input [SIZE-1:0] data_in,
    input tx_en,
	input rx,
	output wire tx,
	output wire tx_busy,
	output reg [SIZE-1:0] data_out,
    output reg rx_done);
	
	
	transmission #(SIZE ,BAUD_RATE, CLK_FREQ ,BAUD_COUNT) tx_dut (
																	.clk(clk),
																	.rst(rst),
																	.tx_en(tx_en),
																	.data_in(data_in),
																	.tx(tx),
																	.tx_busy(tx_busy));
																	
	reciever #(SIZE ,BAUD_RATE, CLK_FREQ ,BAUD_COUNT) rx_dut (
																	.clk(clk),
																	.rst(rst),
																	.data_out(data_out),
																	.rx_done(rx_done),
																	.rx(rx));
																	
																	
	endmodule