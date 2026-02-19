// File:  fifo_16x8.v
// Date:  01/01/2005
// Name:  Eric Crabill
// 
// This is the FIFO for use with the EE178
// Lab #5 assignment.  I had originally used
// the bbfifo_16x8 from the previous lab but
// ran into some unisim library simulation
// quirks and instead elected to use this.

// The `timescale directive specifies what
// the simulation time units are (1 ns here)
// and what the simulator timestep should be
// (1 ps here).

`timescale 1 ns / 1 ps

module fifo_16x8 (data_in, data_out, rst, write, read,
                  full, half_full, data_present, clk);

  input [7:0] data_in;
  output [7:0] data_out;
  input rst;
  input write; 
  input read;
  output full;
  output half_full;
  output data_present;
  input clk;

  wire data_present;
  reg [4:0] pointer;
  wire valid_write;

  SRL16E data_srl_0 
  (   	.D(data_in[0]),
         .CE(valid_write),
         .CLK(clk),
         .A0(pointer[0]),
         .A1(pointer[1]),
         .A2(pointer[2]),
         .A3(pointer[3]),
         .Q(data_out[0]));

  SRL16E data_srl_1 
  (   	.D(data_in[1]),
         .CE(valid_write),
         .CLK(clk),
         .A0(pointer[0]),
         .A1(pointer[1]),
         .A2(pointer[2]),
         .A3(pointer[3]),
         .Q(data_out[1]));

  SRL16E data_srl_2 
  (   	.D(data_in[2]),
         .CE(valid_write),
         .CLK(clk),
         .A0(pointer[0]),
         .A1(pointer[1]),
         .A2(pointer[2]),
         .A3(pointer[3]),
         .Q(data_out[2]));

  SRL16E data_srl_3 
  (   	.D(data_in[3]),
         .CE(valid_write),
         .CLK(clk),
         .A0(pointer[0]),
         .A1(pointer[1]),
         .A2(pointer[2]),
         .A3(pointer[3]),
         .Q(data_out[3]));

  SRL16E data_srl_4 
  (   	.D(data_in[4]),
         .CE(valid_write),
         .CLK(clk),
         .A0(pointer[0]),
         .A1(pointer[1]),
         .A2(pointer[2]),
         .A3(pointer[3]),
         .Q(data_out[4]));

  SRL16E data_srl_5 
  (   	.D(data_in[5]),
         .CE(valid_write),
         .CLK(clk),
         .A0(pointer[0]),
         .A1(pointer[1]),
         .A2(pointer[2]),
         .A3(pointer[3]),
         .Q(data_out[5]));

  SRL16E data_srl_6
  (   	.D(data_in[6]),
         .CE(valid_write),
         .CLK(clk),
         .A0(pointer[0]),
         .A1(pointer[1]),
         .A2(pointer[2]),
         .A3(pointer[3]),
         .Q(data_out[6])); 

  SRL16E data_srl_7 
  (   	.D(data_in[7]),
         .CE(valid_write),
         .CLK(clk),
         .A0(pointer[0]),
         .A1(pointer[1]),
         .A2(pointer[2]),
         .A3(pointer[3]),
         .Q(data_out[7]));

  assign valid_write = (write & read) | (write & !full);

  always @(posedge clk or posedge rst)
  begin
    if (rst) pointer <= 5'b11111;
    else
    begin
      case ({write, read, full, data_present})
        4'b0101: pointer <= pointer - 1;
        4'b0111: pointer <= pointer - 1;
        4'b1000: pointer <= pointer + 1;
        4'b1001: pointer <= pointer + 1;
        4'b1100: pointer <= pointer + 1;
        default: pointer <= pointer;
      endcase
    end
  end

  assign full = (pointer == 5'b01111);
  assign half_full = (pointer[4:3] == 2'b01);
  assign data_present = (pointer != 5'b11111);

endmodule