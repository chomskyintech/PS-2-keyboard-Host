`timescale 1ns/1ps

module display_tb;

  // DUT inputs
  reg        clk;
  reg        rs;
  reg  [3:0] val0, val1, val2, val3;
  reg        dot0, dot1, dot2, dot3;

  // DUT outputs
  wire a,b,c,d,e,f,g;
  wire dp;
  wire an0, an1, an2, an3;

  // Instantiate DUT
  display dut (
    .clk (clk),
    .rs  (rs),
    .val0(val0), .val1(val1), .val2(val2), .val3(val3),
    .dot0(dot0), .dot1(dot1), .dot2(dot2), .dot3(dot3),
    .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
    .dp(dp),
    .an0(an0), .an1(an1), .an2(an2), .an3(an3)
  );

  // 100 MHz clock (10 ns period)
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    // VCD dump (works with Icarus/GTKWave; harmless elsewhere)
    $dumpfile("display_tb.vcd");
    $dumpvars(0, display_tb);

    // Defaults
    rs   = 1'b1;          // hold reset initially
    val0 = 4'h0; val1 = 4'h1; val2 = 4'h2; val3 = 4'h3;
    dot0 = 1'b0; dot1 = 1'b0; dot2 = 1'b0; dot3 = 1'b0;

    // Release reset
    repeat (5) @(posedge clk);
    rs = 1'b0;

    // Let it scan through digits for a while
    repeat (3000) @(posedge clk);

    // Change values, toggle some dots (remember: dp output is active-low; dotX=1 means "show dot")
    val0 = 4'hA; val1 = 4'hB; val2 = 4'hC; val3 = 4'hD;
    dot0 = 1'b1; dot1 = 1'b0; dot2 = 1'b1; dot3 = 1'b0;

    repeat (3000) @(posedge clk);

    // Another pattern
    val0 = 4'h9; val1 = 4'h8; val2 = 4'h7; val3 = 4'h6;
    dot0 = 1'b0; dot1 = 1'b1; dot2 = 1'b0; dot3 = 1'b1;

    repeat (3000) @(posedge clk);

    // Mid-run reset pulse
    rs = 1'b1; repeat (3) @(posedge clk); rs = 1'b0;

    repeat (3000) @(posedge clk);

    $finish;
  end

  // Optional console monitor
  initial begin
    $display(" time   a b c d e f g  dp  an3 an2 an1 an0  |  val3 val2 val1 val0  dots");
    forever begin
      @(posedge clk);
      $display("%6t  %b %b %b %b %b %b %b   %b    %b   %b   %b   %b   |    %h    %h    %h    %h    %b%b%b%b",
               $time, a,b,c,d,e,f,g, dp, an3,an2,an1,an0,
               val3, val2, val1, val0, dot3, dot2, dot1, dot0);
    end
  end

endmodule
