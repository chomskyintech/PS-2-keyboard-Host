`timescale 1ns / 1ps

// Module Name: keyboard_testbench_v_tf2

module keyboard_testbench_v_tf2();

  tri1 ps2_clk;
  tri1 ps2_dat;

  reg tb_clk;
  reg tb_dat;

  // open-collector style drive: drive low or release (Z) so tri1 pull-up makes it '1'
  assign ps2_clk = tb_clk ? 1'bz : 1'b0;
  assign ps2_dat = tb_dat ? 1'bz : 1'b0;

  reg rd_kbrd;
  reg rd_dbug;
  reg clk;
  reg rst;

  wire [7:0] rd_data;
  wire data_present;
  wire data_half;
  wire data_full;

  keyboard my_keyboard (
    .ps2_clk(ps2_clk),
    .ps2_dat(ps2_dat),
    .rd_kbrd(rd_kbrd),
    .rd_dbug(rd_dbug),
    .clk(clk),
    .rst(rst),
    .rd_data(rd_data),
    .data_present(data_present),
    .data_half(data_half),
    .data_full(data_full)
  );

  // 100 MHz system clock
  always begin
    clk = 1'b1; #5;
    clk = 1'b0; #5;
  end

  initial begin
    rst = 1'b1;
    #110;
    rst = 1'b0;
  end

  task SEND_SCANCODE;
    input [7:0] scancode;
    input force_bad_parity;
    input force_bad_start;
    input force_bad_stop;
  begin
    $display("  Sending scancode 0x%x at t=%0t", scancode, $time);
    if (force_bad_parity) $display("  ** with bad parity");
    if (force_bad_start)  $display("  ** with bad start");
    if (force_bad_stop)   $display("  ** with bad stop");

    // start bit
    @(negedge clk);
    tb_dat <= force_bad_start;
    #3000;
    @(negedge clk);
    tb_clk <= 1'b0;
    #3000;
    @(negedge clk);
    tb_clk <= 1'b1;

    // data bit 0
    tb_dat <= scancode[0];
    #3000; @(negedge clk); tb_clk <= 1'b0;
    #3000; @(negedge clk); tb_clk <= 1'b1;

    // data bit 1
    tb_dat <= scancode[1];
    #3000; @(negedge clk); tb_clk <= 1'b0;
    #3000; @(negedge clk); tb_clk <= 1'b1;

    // data bit 2
    tb_dat <= scancode[2];
    #1000; @(negedge clk); tb_clk <= 1'b0;
    #3000; @(negedge clk); tb_clk <= 1'b1;

    // data bit 3
    tb_dat <= scancode[3];
    #1000; @(negedge clk); tb_clk <= 1'b0;
    #3000; @(negedge clk); tb_clk <= 1'b1;

    // data bit 4
    tb_dat <= scancode[4];
    #3000; @(negedge clk); tb_clk <= 1'b0;
    #3000; @(negedge clk); tb_clk <= 1'b1;

    // data bit 5
    tb_dat <= scancode[5];
    #3000; @(negedge clk); tb_clk <= 1'b0;
    #3000; @(negedge clk); tb_clk <= 1'b1;

    // data bit 6
    tb_dat <= scancode[6];
    #3000; @(negedge clk); tb_clk <= 1'b0;
    #3000; @(negedge clk); tb_clk <= 1'b1;

    // data bit 7
    tb_dat <= scancode[7];
    #3000; @(negedge clk); tb_clk <= 1'b0;
    #3000; @(negedge clk); tb_clk <= 1'b1;

    // parity bit (odd parity in the provided design)
    tb_dat <= ^{scancode, !force_bad_parity};
    #3000; @(negedge clk); tb_clk <= 1'b0;
    #3000; @(negedge clk); tb_clk <= 1'b1;

    // stop bit
    tb_dat <= !force_bad_stop;
    #3000; @(negedge clk); tb_clk <= 1'b0;
    #3000; @(negedge clk); tb_clk <= 1'b1;

    // release data line to idle high
    tb_dat <= 1'b1;
  end
  endtask

  // Optional: debug prints so you can confirm the task is actually toggling the line
  always @(tb_clk)  $display("tb_clk=%b  (drives ps2_clk %s) at t=%0t",
                             tb_clk, (tb_clk ? "Z/hi" : "0/low"), $time);
  always @(ps2_clk) $display("ps2_clk=%b at t=%0t", ps2_clk, $time);

  initial begin
    $display("If simulation ends prematurely, restart");
    $display("using 'run -all' on the command line.");

    // idle bus released (pulled up)
    tb_clk  <= 1'b1;   // release clock line (Z) => tri1 pulls it high
    tb_dat  <= 1'b1;   // release data line (Z)  => tri1 pulls it high

    // IMPORTANT FIX: do NOT hold read high, it will continuously drain the FIFO
    rd_kbrd <= 1'b0;
    rd_dbug <= 1'b0;

    // Wait until reset is deasserted.
    @(negedge rst);
    $display("Reset deasserted at t=%0t", $time);

    // Wait a few clk cycles
    repeat (4) @(negedge clk);

    $display("Calling SEND_SCANCODE at t=%0t", $time);
    SEND_SCANCODE(8'haa, 0, 0, 0);
    $display("Returned from SEND_SCANCODE at t=%0t", $time);

    // Wait some cycles for the shifter/FSM/FIFO to complete
    repeat (2000) @(negedge clk);

    if (data_present) begin
      $display("data_present=1, rd_data=0x%0x at t=%0t", rd_data, $time);

      // pulse read for 1 clock to pop the FIFO
      @(negedge clk);
      rd_kbrd <= 1'b1;
      @(negedge clk);
      rd_kbrd <= 1'b0;

      // allow output to settle
      repeat (2) @(negedge clk);
      $display("After read pulse: data_present=%b, rd_data=0x%0x at t=%0t",
               data_present, rd_data, $time);
    end else begin
      $display("ERROR: data_present is not asserted! t=%0t", $time);
    end

    $display("Simulation is over, check the waveforms.");
    $stop;
  end

endmodule