# PS-2-keyboard-Host
PS/2 host capable of receiving and processing data
The program receives data from the keyboard,passes it through the synchronizer, debouncer, shift register, and FIFO to the output. The system works on serial interface keeping the ps2 clock line high in idle state and lowering it when the data is passing, this is aligned to a normal PS2 interface architecture.

# Features:

1 Using a Finite State machine as the control path to work as a mechanism for the data path to carry out its functions.

2 Using a debouncer to make sure the scan code only moves forward when someone actually presses a key.

3 No latches used.

4 Only clock at 100 MHZ used in the system.

# The theory behind how this system works is as: 

<img width="863" height="412" alt="image" src="https://github.com/user-attachments/assets/524c591f-6660-481f-a40c-45204c5dd2f8" />


The system is divided into three main layers as

Datapath

Control path

System level integration

At the highest level, the system receives serial data from a PS/2 keyboard, decodes valid key press events, stores them temporarily in a FIFO buffer, and distributes the information to multiple subsystems. Each detected key press triggers an audio playback sequence and updates a multiplexed seven-segment display to show the corresponding hex scan code. FIFO occupancy is also indicated to provide real time feedback on buffer usage.

The keyboard interface operates by sampling the keyboard generated clock and data signals. Since these signals are asynchronous to the FPGA clock, they are first synchronised using multi-stage flipflop synchronisers to avoid metastability.

A clock edge conditioning block detects valid falling edges of the PS/2 clock. Serial data bits are captured using an 11 bit shift register that stores the complete PS/2 frame consisting of a start bit, eight data bits, a parity bit and a stop bit.

A finite state machine(FSM) forms the core of the control path. The FSM governs when the shift register is enabled, monitors frame progress, and decides whether received data should be accepted or discarded. The FSM transitions through states corresponding to idle waiting, active shifting and frame validation.

A FIFO provides status signals indicating whether data is present, full or half full. These signals are used both for the system monitoring and for visual display purposes.

In addition to all of this, an audio playback subsystem is integrated to provide audible feedback for each key press. When a MAKE code is detected, it generates a trigger signal that initiates playback of a stored audio sample.

Likewise, a multiplexed seven segment display is used to present system information visually. The display driver cycles through the digits at a rate fast enough to appear continuous to the human eye.

All of the subsystems are instantiated and interconnected in a top level module. This module is responsible for signal routing, clock and reset distribution and overall system coordination. By isolating system integration from functional modules, the design remains modular and easy to debug or extend.


The synthesized diagram is:

<img width="1166" height="653" alt="image" src="https://github.com/user-attachments/assets/3fc40c97-7c0a-48b2-ba95-a170b97184f2" />

#

The Image shows the working of different modules of the system as well as the Registers and the Seven Segment display. We note that the schematic shows the use of 8 bits FIFO which takes the scan code and outputs the data as rd_data one byte at a time. It is to be noted that the average data size of a PS2 data line is 11 bits, out of which two bits are start and stop and one bit is the parity bit. The remaining 8 bits are used as the data bits.

It is also noted that the PS2 interface use odd bit parity, whereby the total number of bits including the parity bit at the output should be odd. This works like a guardrail and helps us to identify if any of the bits was corrupted during the transmission. However, this system only works if one bit is corrupted at a time.

In addition to this, some of the PS2 interfaces use latches instead of FIFO. However for the nature of the project a FIFO works better.

# Report 

<img width="807" height="171" alt="image" src="https://github.com/user-attachments/assets/776f43c1-a5e0-45c6-bdad-6824c2eef968" />

# Clock

<img width="382" height="262" alt="image" src="https://github.com/user-attachments/assets/fff05536-6b30-4c34-8d06-d44b8bb3effd" />

# Simulation Graph

<img width="1340" height="673" alt="image" src="https://github.com/user-attachments/assets/270d1dd9-cb58-4c97-90eb-6b7baf0b06ce" />

The simulation shows the output of the seven segment display as well as the an0,1,2,3 and a,b,…g.

We also see the output of the audio signals. It is to be noted that the ps2 clock goes back to its idle high state right after a signal is transmitted. In the previous waveform, it was not prominent as the simulation was zoomed in.

# Flashing on FPGA PROM
<img width="1200" height="1600" alt="image" src="https://github.com/user-attachments/assets/554a6e22-d564-4342-841e-d56b59c3bde6" />


To program the code onto the PROM there are usually three methods including JTAG, QSPI and USB-c. I used the QSPI method. To continue I placed the jumper in the QSPI position, as shown by point 10 in figure 9.

A .bin file was generated afterwards which was then used to program the FPGA.To make sure the project was working correctly and as intended, the FPGA was turned off, power supply was cut and the FPGA was then powered by a Power bank as shown in figure 10. The FPGA was turned on and the keyboard was connected again. 

The system worked correctly and the hex code ‘’35’’ was displayed after I pressed the letter Y.

It is to be noted that the FPGA was solely powered by the Power bank without any external input.
In addition to this, the intended code was for the sound as well. However because of the unavailability of an amplifier or speaker this could not be implemented on the FPGA. I would like to emphasize that even though the sound could not be implemented on the FPGA, we can still see the outputs of the sound bits on the simulation.
