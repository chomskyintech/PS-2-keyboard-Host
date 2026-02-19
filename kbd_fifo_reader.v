`timescale 1ns/1ps
module kbd_fifo_reader (
    input  wire       clk,
    input  wire       rst,
    input  wire       data_present,
    input  wire [7:0] rd_data,
    output reg        rd_kbrd,      // 1-cycle pulse to pop FIFO
    output reg        byte_valid,   // 1-cycle strobe
    output reg [7:0]  byte_out
);
// Used at the top level to abstract FIFO control logic.
    // Converts FIFO status/data into a clean synchronous byte stream
    // so downstream modules do not need to manage rd_kbrd timing.

    // Stores previous FIFO status to detect transition
    // from empty to non-empty
    reg prev_present;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_kbrd      <= 1'b0;
            byte_valid   <= 1'b0;
            byte_out     <= 8'h00;
            prev_present <= 1'b0;
        end else begin
            rd_kbrd    <= 1'b0;
            byte_valid <= 1'b0;

            // Pop one byte when FIFO becomes non-empty
            if (!prev_present && data_present) begin
                byte_out   <= rd_data;
                byte_valid <= 1'b1;
                rd_kbrd    <= 1'b1;
            end

            prev_present <= data_present;
        end
    end
endmodule