module transmission #(	parameter SIZE = 8,
						parameter BAUD_RATE = 115200, 
						parameter CLK_FREQ = 1000000,
						parameter BAUD_COUNT = 9)
(   
    input clk, rst, [SIZE-1:0] data_in, tx_en,
    output reg tx, tx_busy
);
    parameter IDLE = 2'b00, TX_START = 2'b01, TX_DATA = 2'b10, TX_STOP = 2'b11;
    reg [1:0] state;
    reg [3:0] bit_counter;
    reg [3:0] clk_cycle;
    reg [SIZE-1:0] data_reg;
	
	
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1;
			state <= IDLE;
			tx_busy <= 0;
			bit_counter <= 0;
			clk_cycle <= 0; 
			data_reg <= 0;
            $display("[TX] Reset: state = IDLE, tx = %b, tx_busy = %b at %0t", tx, tx_busy, $time);
        end else begin
		
		
            case (state)
                IDLE: begin
                    tx <= 1;
					tx_busy <= 0;
					bit_counter <= 0;
					clk_cycle <= 0;
                    if (tx_en) begin
                        $display("[TX] tx_en detected, data_in = %b, to TX_START at %0t", data_in, $time);
                        state <= TX_START;
						data_reg <= data_in;
                    end
                end
                TX_START: begin    
                    tx <= 0;
					tx_busy <= 1;
                    if (clk_cycle == BAUD_COUNT - 1) begin
                        state <= TX_DATA;
						clk_cycle <= 0;
                    end else begin    
                        clk_cycle <= clk_cycle + 1;
                    end 
                end
                TX_DATA: begin
                    tx <= data_reg[bit_counter];
					tx_busy <= 1;
                    if (clk_cycle == BAUD_COUNT - 1) begin
                        clk_cycle <= 0;
                        if (bit_counter == SIZE - 1) state <= TX_STOP;
                        bit_counter <= bit_counter + 1;
                    end else begin    
                        clk_cycle <= clk_cycle + 1;
                    end
                end 
                TX_STOP: begin 
                    tx <= 1; tx_busy <= 1;
                    if (clk_cycle == BAUD_COUNT - 1) begin
                        state <= IDLE; bit_counter <= 0;
						tx_busy <= 0; 
						clk_cycle <= 0;
                        $display("[TX] Done: data = %b at %0t", data_reg, $time);
                    end else begin
                        clk_cycle <= clk_cycle + 1;
                    end
                end
            endcase          
        end
    end
endmodule