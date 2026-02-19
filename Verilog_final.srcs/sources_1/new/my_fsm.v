`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2025 10:53:51 PM
// Design Name: 
// Module Name: my_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module my_fsm (
    input  wire clk,
    input  wire rst,        // async reset (match your style)
    input  wire ps2_edge,   // 1-cycle pulse when PS/2 bit should be sampled
    input  wire expired,    // 1 when timeout occurs
    input  wire okay,       // 1 when 11-bit frame passes start/stop/parity check
    output reg  shift,      // 1-cycle pulse to shift shifter
    output reg  write       // 1-cycle pulse to write data_in to FIFO/register
);

    // States
    localparam IDLE     = 2'd0;
    localparam SHIFTING = 2'd1;
    localparam WRITE    = 2'd2;

    reg [1:0] state, next_state;

    // Counts how many bits shifted in current frame (0..10) => 11 bits total
    reg [3:0] bit_cnt, next_bit_cnt;

    // Combinational next-state + outputs
    always @(*) begin
        next_state   = state;
        next_bit_cnt = bit_cnt;

        // default outputs (pulses)
        shift = 1'b0;
        write = 1'b0;

        case (state)
            IDLE: begin
                next_bit_cnt = 4'd0;
                if (expired) begin
                    next_state = IDLE; // already idle
                end else if (ps2_edge) begin
                    // first bit of a new frame
                    shift = 1'b1;
                    next_bit_cnt = 4'd1;
                    next_state = SHIFTING;
                end
            end

            SHIFTING: begin
                if (expired) begin
                    // abandon partial frame
                    next_state   = IDLE;
                    next_bit_cnt = 4'd0;
                end else if (ps2_edge) begin
                    shift = 1'b1;

                    if (bit_cnt == 4'd10) begin
                        // just captured the 11th bit (0..10 = 11 bits)
                        // Now decide whether to write (valid frame) or discard
                        if (okay) begin
                            next_state = WRITE;
                        end else begin
                            next_state = IDLE;
                        end
                        next_bit_cnt = 4'd0;
                    end else begin
                        next_bit_cnt = bit_cnt + 4'd1;
                    end
                end
            end

            WRITE: begin
                // 1-cycle write pulse
                write = 1'b1;
                next_state = IDLE;
            end

            default: begin
                next_state   = IDLE;
                next_bit_cnt = 4'd0;
            end
        endcase
    end

    // State + counter registers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            bit_cnt <= 4'd0;
        end else begin
            state   <= next_state;
            bit_cnt <= next_bit_cnt;
        end
    end

endmodule