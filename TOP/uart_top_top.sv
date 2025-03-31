`ifndef UART_TOP_TOP_SV
`define UART_TOP_TOP_SV

`include "uart_top_test.sv"
`include "uart_top_if.sv"
`include "uart_top.sv"

module uart_top_top #(	parameter SIZE = 8,
						parameter BAUD_RATE = 115200, 
						parameter CLK_FREQ = 1000000,
						parameter BAUD_COUNT = 9, 
						parameter NUM_OF_TRANS = 100);
    bit clk;
    always #500 clk = ~clk;
    uart_top_if #(SIZE) uart_top_if_inst(clk);
    uart_top #(SIZE, BAUD_RATE, CLK_FREQ, BAUD_COUNT) dut (
        .clk(clk), .rst(uart_top_if_inst.rst),
		.data_in(uart_top_if_inst.data_in),
        .tx_en(uart_top_if_inst.tx_en),
		.rx(uart_top_if_inst.rx),
		.tx(uart_top_if_inst.tx),
        .tx_busy(uart_top_if_inst.tx_busy),
		.data_out(uart_top_if_inst.data_out),
        .rx_done(uart_top_if_inst.rx_done)
    );
    assign uart_top_if_inst.rx = uart_top_if_inst.tx;
	
    reg tx_prev;  // Track previous tx value
	
    initial tx_prev = 1;  // Idle state
	
    always @(posedge clk) begin
	
        if (tx_prev !== uart_top_if_inst.tx) begin //Checks if TX toggle to disply logs
            $display("[TOP] tx = %b, rx = %b at %0t", uart_top_if_inst.tx, uart_top_if_inst.rx, $time);
            tx_prev <= uart_top_if_inst.tx;
        end
    end
    uart_top_test #(SIZE, BAUD_RATE, CLK_FREQ, BAUD_COUNT, NUM_OF_TRANS) test;
    initial begin
        $display("[TOP] Simulation started at %t", $time);
        uart_top_if_inst.rst = 1;
        #10000;
        uart_top_if_inst.rst = 0;
        #10;
        test = new(uart_top_if_inst.mp_mon, uart_top_if_inst.mp_drv);
        test.run();
    end
endmodule
`endif