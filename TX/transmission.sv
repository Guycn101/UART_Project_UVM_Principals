module transmission
#(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = (CLK_FREQ/BAUD_RATE))
 (   
    input clk,    
    input rst,
    input [SIZE-1:0] data_in,
    input tx_en,
    output reg tx,
    output reg tx_busy
);

parameter IDLE = 2'b00, TX_START = 2'b01, TX_DATA = 2'b10, TX_STOP = 2'b11; //FSM States

reg [1:0] state; //reg to save current state
reg [3:0] bit_counter = 0; // counting bits till it reaches SIZE-1
reg [SIZE-1:0] clk_cycle = 0; // Count clk_cycle till it reaches BAUD_COUNT
reg [SIZE-1:0] data_reg = 0; // Store data
  

always @(posedge clk or posedge rst) begin
    if(rst) begin
        tx <= 1;
        state <= IDLE;
        tx_busy <= 0;
        bit_counter <= 0;
        clk_cycle <= 0;
		$display("[DUT] Reset: state = %s, tx = %b, tx_busy = %b", state, tx, tx_busy);
    end else begin

        case(state)
            IDLE: begin
				tx <= 1;
				tx_busy <= 0;
                bit_counter <= 0;
                clk_cycle <= 0;
                if(tx_en) begin
					$display("[DUT] tx_en detected, to TX_START at %0t", $time);
                    state <= TX_START;
					data_reg <= data_in;
                end
            end

            TX_START: begin    
				tx <= 0;
                tx_busy <= 1;
                if(clk_cycle == BAUD_COUNT - 1) begin
                    state <= TX_DATA;
                    clk_cycle <= 0;
                end else begin    
                    clk_cycle <= clk_cycle + 1;
                end 
            end

            TX_DATA: begin
				tx <= data_reg[bit_counter];
                tx_busy <= 1;
                if(clk_cycle == BAUD_COUNT - 1) begin
                    clk_cycle <= 0;
                    if(bit_counter == SIZE - 1)
                        state <= TX_STOP;
                    else
                        state <= TX_DATA;
                    bit_counter <= bit_counter + 1;
                end else begin    
                    clk_cycle <= clk_cycle + 1;
                end
            end 

            TX_STOP: begin 
				tx <= 1;
                tx_busy <= 1;
                if(clk_cycle == BAUD_COUNT - 1) begin
                    state <= IDLE;
					bit_counter <= 0;
					tx_busy <= 0;
                    clk_cycle <= 0;
					$display("[DUT] state = %d, bit_counter = %0d, clk_cycle = %0d, tx = %b, tx_busy = %b", state, bit_counter, clk_cycle, tx, tx_busy);
                end else begin
                    clk_cycle <= clk_cycle + 1;
                end
            end
        endcase          
    end
end

endmodule
