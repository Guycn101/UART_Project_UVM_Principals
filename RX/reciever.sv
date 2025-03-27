module reciever
 #(parameter SIZE = 8, // size of data
   parameter BAUD_RATE = 115200, 
   parameter CLK_FREQ = 1000000,
   parameter BAUD_COUNT = (CLK_FREQ/BAUD_RATE)) // time for 1 bit to move
 (   
    input clk,    
    input rst,
    input rx,
    output reg [SIZE-1:0] data_out,
    output reg rx_done
);

parameter IDLE = 2'b00, RX_START = 2'b01, RX_DATA = 2'b10, RX_STOP = 2'b11; // FSM states

reg rx_r, rx_sync; //FF to stabilize input
reg [2:0] state; // reg to save state 
reg [3:0] bit_counter = 0;
reg [SIZE -1:0] clk_cycle = 0; // saving clk_cycles to sync
reg [SIZE-1:0] data_reg = 0; // reg to store data

// double flip flop to stabalize the input (rx)
always @(posedge clk) begin
    rx_r <= rx;
    rx_sync <= rx_r;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin // reset handling
        data_out <= 0;
        state <= IDLE;
        rx_done <= 0;
        bit_counter <= 0;
        clk_cycle <= 0;
        $display("[DUT] Reset: state = IDLE, data_out = %0h, rx_done = %b", data_out, rx_done);
    end else begin
        case (state)
            IDLE: begin
                rx_done <= 0;
                clk_cycle <= 0;
                bit_counter <= 0;
                $display("[RX] Time %t: In IDLE, rx_sync = %b, rx_done = %b", $time, rx_sync, rx_done);
                if (rx_sync == 0) // next state
                    state <= RX_START;
            end
            
            RX_START: begin
                if (clk_cycle == BAUD_COUNT/2) begin // mid bit time
                    $display("[RX] Time %t: RX_START, rx_sync = %b, clk_cycle = %d", $time, rx_sync, clk_cycle);
                    if (rx_sync == 0) begin // next state
                        state <= RX_DATA;
                        clk_cycle <= 0;
                    end else begin // same state
                        state <= IDLE;
                    end
                end else begin
                    clk_cycle <= clk_cycle + 1; // count clk to sync
                end
            end
            
            RX_DATA: begin
                if (clk_cycle == BAUD_COUNT-1) begin // end of bit to make sure it stable
                    $display("[RX] Time %t: RX_DATA, bit %d, rx_sync = %b, data_reg = %h", $time, bit_counter, rx_sync, data_reg);
                    data_reg[bit_counter] <= rx_sync;
                    clk_cycle <= 0;
                    if (bit_counter == SIZE-1) begin // end of data in by of its size (8 bits)
                        state <= RX_STOP; // next state
                        bit_counter <= 0;
                    end else begin
                        bit_counter <= bit_counter + 1; //bit counter til it gets to SIZE
                    end
                end else begin
                    clk_cycle <= clk_cycle + 1; // count clk to sync
                end
            end
            
            RX_STOP: begin
                if (clk_cycle == BAUD_COUNT-1) begin // sample ta end of bit
                    $display("[RX] Time %t: RX_STOP, rx_sync = %b, data_reg = %h", $time, rx_sync, data_reg);
                    if (rx_sync == 1) begin // check for stop bit
                        data_out <= data_reg; //output data collected
                        rx_done <= 1; // flag that rx is done receiving
                        $display("[RX] Time %t: RX_STOP, data_out updated to %h, rx_done = %b", $time, data_out, rx_done);
                    end
                    clk_cycle <= 0; //rst clk before going back to idle
                    state <= IDLE; // next state
                end else begin
                    clk_cycle <= clk_cycle + 1; // count clk cycle to sync
                end
            end
        endcase
    end
end
endmodule