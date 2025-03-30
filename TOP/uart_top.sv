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
	output tx_busy,
	output reg [SIZE-1:0] data_out,
    output reg rx_done);
	
	wire tx_serial;
	
	transmission #(SIZE ,BAUD_RATE, CLK_FREQ ,BAUD_COUNT) tx_dut (
																	.clk(clk),
																	.rst(rst),
																	.tx_en(tx_en),
																	.data_in(data_in),
																	.tx(tx_serial),
																	.tx_busy(tx_busy));
																	
	receiver #(SIZE ,BAUD_RATE, CLK_FREQ ,BAUD_COUNT) rx_dut (
																	.clk(clk),
																	.rst(rst),
																	.data_out(data_out),
																	.rx_done(rx_done),
																	.rx(tx_serial));
																	
																	
	endmodule