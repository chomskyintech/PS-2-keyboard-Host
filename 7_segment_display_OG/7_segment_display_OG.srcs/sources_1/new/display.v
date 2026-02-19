`timescale 1ns / 1ps


module display(
input wire clk,
input wire rs,
input wire [3:0] val0,
input wire [3:0] val1,
input wire [3:0] val2,
input wire [3:0] val3,
input wire dot0,
input wire dot1,
input wire dot2,
input wire dot3,
output reg a,b,c,d,e,f,g,
output reg dp,
output reg an0,
output reg an1,
output reg an2,
output reg an3
    );
    reg [16:0]count = 17'd0;
    always@(posedge clk or posedge rs)
    if (rs) begin
    count <= 17'd0;
    end 
    else begin
    count <= count +17'd1;
    end
    wire [1:0] sel =  count [16:15];
    reg [3:0]val_next = 4'd0;
    reg dp_sel = 1'b1;
    reg [3:0] an_next = 4'b1111;
    
    always@(*) begin 
    
    case(sel)
     2'b00: begin val_next = val0; dp_sel = dot0; an_next = 4'b1110; end
     2'b01: begin val_next = val1; dp_sel = dot1; an_next = 4'b1101; end
     2'b10: begin val_next = val2; dp_sel = dot2; an_next = 4'b1011; end
     2'b11: begin val_next = val3; dp_sel = dot3; an_next = 4'b0111; end
   endcase
   end
    
   reg [6:0] seg_next;
    always@(*) begin
    seg_next = 7'b1111111;
    case(val_next)
    4'd0: seg_next = 7'b0000001;
            4'd1: seg_next = 7'b1001111;
            4'd2: seg_next = 7'b0010010;
            4'd3: seg_next = 7'b0000110;
            4'd4: seg_next = 7'b1001100;
            4'd5: seg_next = 7'b0100100;
            4'd6: seg_next = 7'b0100000;
            4'd7: seg_next = 7'b0001111;
            4'd8: seg_next = 7'b0000000;
            4'd9: seg_next = 7'b0000100;
            4'd10: seg_next = 7'b0001000; // A
            4'd11: seg_next = 7'b1100000; // b
            4'd12: seg_next = 7'b0110001; // C
            4'd13: seg_next = 7'b1000010; // d
            4'd14: seg_next = 7'b0110000; // E
            4'd15: seg_next = 7'b0111000; // F
            endcase
            end
    
   always@( posedge clk or posedge rs)
   if (rs) begin
   {a,b,c,d,e,f,g} <= 7'b1111111;
   dp <= 1'b1;
   {an3,an2,an1,an0} <= 4'b1111;
   end 
   else begin 
   {a,b,c,d,e,f,g} <= seg_next;
   {an3,an2,an1,an0} <= an_next;
   dp <= dp_sel ? 1'b0 : 1'b1;
   end 
endmodule
