`timescale 1ns / 1ps

//============================================================
// top_ps2_pcm_tb.v
//
// Testbench for the integrated PS/2 keyboard + PCM audio +
// 7-segment display system.
//
// This testbench:
// - Generates a 100 MHz system clock
// - Models PS/2 open-collector clock/data lines using tri1
// - Sends a valid PS/2 MAKE scancode frame (Set-2)
// - Verifies that audio playback starts by counting DAC toggles
// - Allows observation of multiplexed 7-seg outputs
//
// Timing notes:
// - `timescale 1ns/1ps is assumed
// - PS/2 bit timing is artificially shortened for simulation
// - Delays (e.g. #500_000) represent simulated time, not frequency
//
// Intended use:
// - Functional simulation and waveform inspection in Vivado/XSim
// - Validation of system-level integration (keyboard ? FIFO ? decoder ? PCM/display)
//============================================================

module top_ps2_pcm_tb;

  // PS/2 lines (pulled up when released)
  tri1 ps2_clk;
  tri1 ps2_dat;

  reg tb_ps2_clk_drive;
  reg tb_ps2_dat_drive;

  // open-collector: drive low (0) or release (Z -> pulled up)
  assign ps2_clk = tb_ps2_clk_drive ? 1'bz : 1'b0;
  assign ps2_dat = tb_ps2_dat_drive ? 1'bz : 1'b0;

  // 100 MHz system clock
  reg clk;
  reg rst;

  // DUT outputs
  wire aud;


  wire a,b,c,d,e,f,g;
  wire dp;
  wire an0,an1,an2,an3;

  // DUT
  top_ps2_pcm dut (
    .clk(clk),
    .rst(rst),
    .ps2_clk(ps2_clk),
    .ps2_dat(ps2_dat),
    .aud(aud),
    .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
    .dp(dp),
    .an0(an0), .an1(an1), .an2(an2), .an3(an3)
  );

  // 100 MHz clock generator
  always begin
    clk = 1'b1; #5;
    clk = 1'b0; #5;
  end

  // reset
  initial begin
    rst = 1'b1;
    #110;
    rst = 1'b0;
  end

  // Send PS/2 frame: start(0), 8 data LSB-first, odd parity, stop(1)
  task SEND_SCANCODE;
    input [7:0] scancode;
    input force_bad_parity;
    input force_bad_start;
    input force_bad_stop;
    integer k;
  begin
    $display("Sending scancode 0x%02x at t=%0t", scancode, $time);
    if (force_bad_parity) $display("  ** with bad parity");
    if (force_bad_start)  $display("  ** with bad start");
    if (force_bad_stop)   $display("  ** with bad stop");

    @(negedge clk);

    // start bit (normally 0)
    tb_ps2_dat_drive <= force_bad_start;
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b0;
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b1;

    // data bits
    for (k = 0; k < 8; k = k + 1) begin
      tb_ps2_dat_drive <= scancode[k];
      #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b0;
      #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b1;
    end

    // parity bit (odd parity)
    tb_ps2_dat_drive <= ^{scancode, !force_bad_parity};
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b0;
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b1;

    // stop bit (normally 1)
    tb_ps2_dat_drive <= !force_bad_stop;
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b0;
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b1;

    // release data
    tb_ps2_dat_drive <= 1'b1;
  end
  endtask

  // Audio toggle counter: proves PCM started (delta-sigma output toggles fast)
  integer aud_toggles;
  always @(posedge aud) begin
    aud_toggles = aud_toggles + 1;
  end

  // Helper to print 7-seg state (optional)
  task PRINT_7SEG;
  begin
    $display("t=%0t an3..0=%b%b%b%b seg(a..g)=%b dp=%b",
             $time, an3,an2,an1,an0, {a,b,c,d,e,f,g}, dp);
  end
  endtask

  initial begin
    $display("Run long enough (e.g. run -all or run 500 us).");

    aud_toggles = 0;

    // release PS/2 lines (idle high)
    tb_ps2_clk_drive <= 1'b1;
    tb_ps2_dat_drive <= 1'b1;

    // wait reset release
    @(negedge rst);
    $display("Reset deasserted at t=%0t", $time);

    // settle a bit
    repeat (20) @(negedge clk);

    // Send a MAKE scancode (Set 2). Example: 0x1C often corresponds to 'A'.
    SEND_SCANCODE(8'h1C, 0, 0, 0);

    // Wait for logic to process + display to refresh
    #500_000; // 500 us

    // Check audio activity
    if (aud_toggles > 100) begin
      $display("PASS: aud toggled (%0d posedges) after keypress.", aud_toggles);
    end else begin
      $display("FAIL: aud did not toggle enough (%0d posedges).", aud_toggles);
      $display("Check: pcm SYS_CLK_HZ=100MHz, init pulse, rom/seq/dac included.");
    end

    // Optional: sample the 7-seg signals a few times
    PRINT_7SEG;
    #50_000;
    PRINT_7SEG;

    $display("Simulation done. Inspect waveforms for data_present/data_half/data_full and 7-seg.");
    $stop;
  end

endmodule