`timescale 1ns/1ps
module top_ps2_pcm (
    input  wire clk,      // 100 MHz
    input  wire rst,      // async reset
    input  wire ps2_clk,
    input  wire ps2_dat,

    output wire aud,

    // 7-seg outputs
    output wire a,b,c,d,e,f,g,
    output wire dp,
    output wire an0,an1,an2,an3
);

    // -------------------------
    // PS/2 keyboard receiver
    // -------------------------
    wire [7:0] rd_data;
    wire data_present, data_half, data_full;
    wire rd_kbrd;

    keyboard u_kbd (
        .ps2_clk(ps2_clk),
        .ps2_dat(ps2_dat),
        .rd_kbrd(rd_kbrd),
        .rd_dbug(1'b0),
        .clk(clk),
        .rst(rst),
        .rd_data(rd_data),
        .data_present(data_present),
        .data_half(data_half),
        .data_full(data_full)
    );

    // -------------------------
    // FIFO -> bytes
    // -------------------------
    wire byte_valid;
    wire [7:0] byte_out;

    kbd_fifo_reader u_reader (
        .clk(clk),
        .rst(rst),
        .data_present(data_present),
        .rd_data(rd_data),
        .rd_kbrd(rd_kbrd),
        .byte_valid(byte_valid),
        .byte_out(byte_out)
    );

    // -------------------------
    // Bytes -> MAKE (key press)
    // -------------------------
    wire make_valid;
    wire [7:0] make_code;

    ps2_make_decoder u_make (
        .clk(clk),
        .rst(rst),
        .byte_valid(byte_valid),
        .byte_in(byte_out),
        .make_valid(make_valid),
        .make_code(make_code)
    );

    // -------------------------
    // PCM: restart playback on EVERY key press
    // -------------------------
    wire init_pcm = make_valid;

    pcm u_pcm (
        .clk(clk),     // 100 MHz (pcm/seq configured for 100 MHz)
        .rst(rst),
        .init(init_pcm),
        .aud(aud)
    );

    // -------------------------
    // 7-seg requirements:
    //  - first two digits: MAKE code in hex
    //  - third digit: FIFO status
    // -------------------------

    // store last MAKE scancode (flip-flops, not latches)
    reg [7:0] last_code;
    always @(posedge clk or posedge rst) begin
        if (rst)
            last_code <= 8'h00;
        else if (make_valid)
            last_code <= make_code;
    end

    // FIFO status nibble for 3rd digit:
    // 0 = empty, 1 = data_present, 2 = half, 3 = full
    reg [3:0] fifo_stat;
    always @(*) begin
        if (data_full)       fifo_stat = 4'h3;
        else if (data_half)  fifo_stat = 4'h2;
        else if (data_present) fifo_stat = 4'h1;
        else                 fifo_stat = 4'h0;
    end

    // Drive your existing display module:
    // val0 = digit 0 (rightmost), val1 = digit 1, val2 = digit 2 (third digit), val3 = digit 3 (leftmost)
    display u_disp (
        .clk (clk),
        .rs  (rst),

        // First two digits show MAKE code hex
        .val0(last_code[3:0]),   // digit 0 (rightmost)
        .val1(last_code[7:4]),   // digit 1

        // Third digit shows FIFO status
        .val2(fifo_stat),        // digit 2 (third digit)

        // Fourth digit: keep 0 (or change if you want)
        .val3(4'h0),

        .dot0(1'b0),
        .dot1(1'b0),
        .dot2(1'b0),
        .dot3(1'b0),

        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
        .dp(dp),
        .an0(an0), .an1(an1), .an2(an2), .an3(an3)
    );

endmodule