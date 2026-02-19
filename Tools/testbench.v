// File:  testbench.v
// Date:  01/01/2005
// Name:  Eric Crabill
// 
// This is a top level testbench for the
// keyboard design, which is part of the EE178
// Lab #5 assignment.

// The `timescale directive specifies what
// the simulation time units are (1 ns here)
// and what the simulator timestep should be
// (1 ps here).

`timescale 1 ns / 1 ps

module keyboard_testbench_v_tf();

  // PS/2 lines (tri1 provides pull-up when released)
  tri1 ps2_clk;
  tri1 ps2_dat;

  reg tb_ps2_clk_drive;
  reg tb_ps2_dat_drive;

  // open-collector: drive low (0) or release (Z -> pulled up to 1)
  assign ps2_clk = tb_ps2_clk_drive ? 1'bz : 1'b0;
  assign ps2_dat = tb_ps2_dat_drive ? 1'bz : 1'b0;

  // 100 MHz system clock
  reg clk;
  reg rst;

  wire aud;

  // DUT: integrated top
  top_ps2_pcm dut (
    .clk(clk),
    .rst(rst),
    .ps2_clk(ps2_clk),
    .ps2_dat(ps2_dat),
    .aud(aud)
  );

  // 100 MHz clock generator (10 ns period)
  always begin
    clk = 1'b1; #5;
    clk = 1'b0; #5;
  end

  // async reset pulse
  initial begin
    rst = 1'b1;
    #110;
    rst = 1'b0;
  end

  // Send one PS/2 Set-2 style frame:
  // start(0), 8 data bits LSB-first, odd parity, stop(1)
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

    // start bit
    tb_ps2_dat_drive <= force_bad_start; // normally 0
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b0;
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b1;

    // data bits [0..7] LSB first
    for (k = 0; k < 8; k = k + 1) begin
      tb_ps2_dat_drive <= scancode[k];
      #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b0;
      #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b1;
    end

    // parity bit (odd parity expected by your keyboard.v "okay" logic)
    tb_ps2_dat_drive <= ^{scancode, !force_bad_parity};
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b0;
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b1;

    // stop bit (normally 1 -> release line)
    tb_ps2_dat_drive <= !force_bad_stop;
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b0;
    #3000; @(negedge clk); tb_ps2_clk_drive <= 1'b1;

    // release data to idle high
    tb_ps2_dat_drive <= 1'b1;
  end
  endtask

  // Count audio toggles to verify PCM started
  integer aud_toggles;
  always @(posedge aud) begin
    aud_toggles = aud_toggles + 1;
  end

  initial begin
    $display("Run long enough (e.g. run -all).");

    aud_toggles = 0;

    // idle bus released (pulled up)
    tb_ps2_clk_drive <= 1'b1;
    tb_ps2_dat_drive <= 1'b1;

    // wait reset release
    @(negedge rst);
    $display("Reset deasserted at t=%0t", $time);

    // settle
    repeat (10) @(negedge clk);

    // Send a MAKE scancode.
    // If your top triggers PCM on ANY key press, any valid scancode works.
    // If your top triggers only on a specific key, replace 8'h1C with that key's make code.
    SEND_SCANCODE(8'h1C, 0, 0, 0);

    // Wait for FIFO->decode->init pulse and PCM to start producing aud
    // (aud is delta-sigma at clk rate, so it should toggle a lot once playing)
    #200_000; // 200 us

    if (aud_toggles > 100) begin
      $display("PASS: aud toggled (%0d posedges) after keypress.", aud_toggles);
    end else begin
      $display("FAIL: aud did not toggle enough (%0d posedges).", aud_toggles);
      $display("Check: init pulse generation, scancode decode, pcm SYS_CLK_HZ=100MHz, and aud wiring.");
    end

    $stop;
  end

endmodule
