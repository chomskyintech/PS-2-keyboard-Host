

// The `timescale directive specifies what
// the simulation time units are (1 ns here)
// and what the simulator timestep should be
// (1 ps here).

`timescale 1 ns / 1 ps

 module keyboard (ps2_clk, ps2_dat, rd_kbrd, rd_dbug, clk, rst, 
                 rd_data, data_present, data_half, data_full);

  input ps2_clk;  // must be pulled up at pin
  input ps2_dat;  // must be pulled up at pin

  input rd_kbrd;
  input rd_dbug;
  input clk;
  input rst;

  output [7:0] rd_data;
  output data_present;
  output data_half;
  output data_full;

  //the synchronizer and debouncer code
  //dbug_d1 and dbug_d2 help in synchronization

  wire read;
  reg dbug_d1, dbug_d2;
  reg [20:0] dbug_ctr;
  reg dbug_det;

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      // just reset everything
      dbug_d1 <= 1'b0;
      dbug_d2 <= 1'b0;
      dbug_ctr <= 21'h000000;
      dbug_det <= 1'b0;
    end
    else
    begin
      // next two lines are synchronizer
      dbug_d1 <= rd_dbug;
      dbug_d2 <= dbug_d1;
      if (dbug_d2)
      begin
        // button is pressed
        // count up to 21'hfffff and stop
        // if we get to 21'hffffe then
        // signal 1 cycle debounce detect
        // incresed the debug_ctr to 21 bits to accomodate the 
        //100 MHZ clock
        if (dbug_ctr != 21'h1fffff) dbug_ctr <= dbug_ctr + 21'h000001;
        dbug_det <= (dbug_ctr == 21'h1ffffe); 
      end
      else
      begin
        // button not pressed
        // clear everything
        dbug_ctr <= 21'h000000;
        dbug_det <= 1'b0;
      end
    end
  end

  assign read = rd_kbrd | dbug_det;


   
  wire ps2_data, ps2_edge;
  reg data_d1, data_d2;
  reg edge_d1, edge_d2;
  reg [3:0] edge_ctr;
  reg edge_det;

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      // just reset everything
      data_d1 <= 1'b1;
      data_d2 <= 1'b1;
      edge_d1 <= 1'b1;
      edge_d2 <= 1'b1;
      edge_ctr <= 4'h0;
      edge_det <= 1'b0;
    end
    else
    begin
      // next four lines are synchronizer
      data_d1 <= ps2_dat;
      data_d2 <= data_d1;
      edge_d1 <= ps2_clk;
      edge_d2 <= edge_d1;
      if (edge_d2)
      begin
        // clock signal is high
        // clear everything
        edge_ctr <= 4'h0;
        edge_det <= 1'b0;
      end
      else
      begin
        // clock signal is low
        // count up to 4'hf and stop
        // if we get to 4'he then
        // signal 1 cycle edge detect
        if (edge_ctr != 4'hf) edge_ctr <= edge_ctr + 4'h1;
        edge_det <= (edge_ctr == 4'he); 
      end
    end
  end

  assign ps2_edge = edge_det;
  assign ps2_data = data_d2;

  // Implement an 11-bit shift register that has
  // a single shift control and data input.  This
  // shift register also has two outputs; one is
  // the 8-bit received data and the other is a
  // status signal that indicates the start, stop,
  // and parity check out okay.

  wire shift, okay;
  reg [10:0] shifter;
  wire [7:0] data_in;

  always @(posedge clk or posedge rst)
  begin
    if (rst) shifter <= 11'b00000000000;
    else if (shift) shifter <= {ps2_data, shifter[10:1]};
  end
  
  assign data_in = shifter[8:1];
  assign okay = !shifter[0] && shifter[10] && ^shifter[9:1];
 

  // Implement a time-out counter.  Each time a bit
  // is shifted, start counting.  After 100 usec or
  // so, signal that the timer has expired.  The
  // expired signal is generated with combinational
  // logic so that in the next cycle after a shift,
  // the expired signal will be deasserted.  This
  // ensures the FSM can start looking at expired
  // immediately after a shift state.  The idea is
  // that the FSM, while waiting for the next bit,
  // can abort if this timer expires.  Hopefully
  // this will handle cases of surprise keyboard
  // removal during a transmission, and cases of
  // controller resets during transmission.

  wire expired;
  reg [12:0] timeout_ctr;

  always @(posedge clk or posedge rst)
  begin
    if (rst) timeout_ctr <= 13'h0000;
    else if (shift) timeout_ctr <= 13'h0000;
    else if (timeout_ctr != 13'h1fff) timeout_ctr <= timeout_ctr + 13'h0001;
  end

  assign expired = (timeout_ctr == 13'h1ffe);

  // Instantiate the fifo_16x8 module.  This acts
  // as a 16-deep scan code buffer from the keyboard
  // so that whoever's reading the scan codes does not
  // need to pick them up immediately upon reception.
  // also this FIFO is 8 bytes long to accomodate the 
  // 8 byte long data signal

  wire write;

  fifo_16x8 my_fifo (
    .data_in(data_in),
    .data_out(rd_data),
    .rst(rst),
    .write(write),
    .read(read),
    .full(data_full),
    .half_full(data_half),
    .data_present(data_present),
    .clk(clk));

  // Instantiate the FSM that controls the datapath.
  // You will have to design this for yourself.

  fsm my_fsm (
    .shift(shift),
    .write(write),
    .expired(expired),
    .okay(okay),
    .ps2_edge(ps2_edge),
    .clk(clk),
    .rst(rst));

endmodule