`timescale 1ns/1ps
module ps2_make_decoder (
    input  wire       clk,
    input  wire       rst,
    input  wire       byte_valid,
    input  wire [7:0] byte_in,
    output reg        make_valid,   // 1-cycle: key press detected
    output reg [7:0]  make_code
);
 // Used at the top level to convert raw PS/2 scan-code bytes
    // into clean key-press events. This prevents key releases
    // (BREAK codes) from triggering audio or display updates.

    // Flag indicating that a break prefix (F0) has been received
   
   
    reg got_f0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            got_f0     <= 1'b0;
            make_valid <= 1'b0;
            make_code  <= 8'h00;
        end else begin
            make_valid <= 1'b0;

            if (byte_valid) begin
                if (byte_in == 8'hF0) begin
                    got_f0 <= 1'b1;          // next byte is break code
                end else begin
                    if (!got_f0) begin
                        make_code  <= byte_in;
                        make_valid <= 1'b1;  // MAKE event
                    end
                    got_f0 <= 1'b0;          // consume prefix
                end
            end
        end
    end
endmodule