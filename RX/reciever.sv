module receiver #(	parameter SIZE = 8,
					parameter BAUD_RATE = 115200, 
					parameter CLK_FREQ = 1000000,
					parameter BAUD_COUNT = 9)
(   
    input clk, rst, rx,
    output reg [SIZE-1:0] data_out,
    output reg rx_done
);
    parameter IDLE = 2'b00, RX_START = 2'b01, RX_DATA = 2'b10, RX_STOP = 2'b11;
    reg [1:0] state;
    reg [3:0] bit_counter;
    reg [3:0] clk_cycle;
    reg [SIZE-1:0] data_reg;
    reg rx_sync, rx_sync_prev;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_sync <= 1;
			rx_sync_prev <= 1;
			state <= IDLE;
			data_out <= 0;
			rx_done <= 0;
            bit_counter <= 0;
			clk_cycle <= 0;
			data_reg <= 0;
            $display("[RX] Reset: state = IDLE, data_out = %b, rx_done = %b at %0t", data_out, rx_done, $time);
        end else begin
            rx_sync_prev <= rx_sync;
            rx_sync <= rx;
            case (state)
                IDLE: begin
                    rx_done <= 0;
					bit_counter <= 0;
					clk_cycle <= 0;
                    if (rx_sync_prev == 1 && rx_sync == 0) begin
                        state <= RX_START;
                        $display("[RX] Time %0t: RX_START, rx_sync = %b, clk_cycle = %0d", $time, rx_sync, clk_cycle);
                    end
                end
                RX_START: begin
                    if (clk_cycle == BAUD_COUNT/2) begin
                        if (rx_sync == 0) begin
                            state <= RX_DATA;
                            $display("[RX] Time %0t: RX_DATA started, rx_sync = %b", $time, rx_sync);
                        end else begin
                            state <= IDLE;
                        end
                        clk_cycle <= 0;
                    end else begin
                        clk_cycle <= clk_cycle + 1;
                    end
                end
                RX_DATA: begin
                    if (clk_cycle == BAUD_COUNT - 1) begin
                        data_reg <= {rx_sync, data_reg[SIZE-1:1]};
                        $display("[RX] Time %0t: RX_DATA, bit %0d, rx_sync = %b, data_reg = %h", 
                                 $time, bit_counter, rx_sync, {rx_sync, data_reg[SIZE-1:1]});
                        clk_cycle <= 0;
                        if (bit_counter == SIZE - 1) begin
                            state <= RX_STOP;
                        end
                        bit_counter <= bit_counter + 1;
                    end else begin
                        clk_cycle <= clk_cycle + 1;
                    end
                end
                RX_STOP: begin
                    if (clk_cycle == BAUD_COUNT - 1) begin
                        if (rx_sync == 1) begin
                            data_out <= data_reg;
                            rx_done <= 1;
                            $display("[RX] Time %0t: RX_STOP, data_out updated to %b, rx_done = %b", 
                                     $time, data_reg, rx_done);
                        end
                        state <= IDLE;
                        clk_cycle <= 0;
                    end else begin
                        clk_cycle <= clk_cycle + 1;
                    end
                end
            endcase
        end
    end
endmodule