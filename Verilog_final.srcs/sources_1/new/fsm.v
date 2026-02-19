`timescale 1ns / 1ps
//FSM uses two states IDLE and SHIFT. I added
// one CHECK state to make sure the write is 
// asserted high at the right time
//This FSM was first built using a state 
//diagram and then wrote the HDL code

module fsm (
    output reg  shift,
    output reg  write,
    input  wire expired,
    input  wire okay,
    input  wire ps2_edge,
    input  wire clk,
    input  wire rst
);

    localparam [1:0] S_IDLE  = 2'd0;
    localparam [1:0] S_SHIFT = 2'd1;
    localparam [1:0] S_CHECK = 2'd2;

    reg [1:0] state, next_state;

    // Counts bits shifted in the current frame: 0..11
    reg [3:0] bit_cnt, next_bit_cnt;

    // Next-state / output logic (combinational)
    always @(*) begin
        // defaults
        next_state   = state;
        next_bit_cnt = bit_cnt;

        shift = 1'b0;
        write = 1'b0;

        case (state)
            // Wait for first ps2_edge to start shifting a frame
            S_IDLE: begin
                next_bit_cnt = 4'd0;
                if (ps2_edge) begin
                    shift        = 1'b1;   // shift start bit
                    next_bit_cnt = 4'd1;
                    next_state   = S_SHIFT;
                end
            end

            // Shift bits on each detected falling edge of ps2_clk (ps2_edge pulse)
            S_SHIFT: begin
                if (expired) begin
                    // Abort reception if keyboard clock stops mid-frame
                    next_state   = S_IDLE;
                    next_bit_cnt = 4'd0;
                end
                else if (ps2_edge) begin
                    shift = 1'b1;

                    if (bit_cnt == 4'd10) begin
                        // This shift completes the 11th bit
                        next_bit_cnt = 4'd11;
                        next_state   = S_CHECK;
                    end
                    else begin
                        next_bit_cnt = bit_cnt + 4'd1;
                        next_state   = S_SHIFT;
                    end
                end
            end

            // After 11 bits are in the shifter, check validity and write once if good
            S_CHECK: begin
               
                if (okay) write = 1'b1;   // 1-cycle pulse to FIFO
                next_state   = S_IDLE;
                next_bit_cnt = 4'd0;
            end

            default: begin
                next_state   = S_IDLE;
                next_bit_cnt = 4'd0;
                shift        = 1'b0;
                write        = 1'b0;
            end
        endcase
    end

    // State / counter registers (sequential)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= S_IDLE;
            bit_cnt <= 4'd0;
        end else begin
            state   <= next_state;
            bit_cnt <= next_bit_cnt;
        end
    end

endmodule