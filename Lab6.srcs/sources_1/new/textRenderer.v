`timescale 1ns / 1ps

module textRenderer(
    output [11:0] rgb,
    input [31:0] x,
    input [31:0] y,
    input clk
    );
    
    wire member1;
    Pixel_On_Text2 #(.displayText("6031033521 Name... Lastname...")) t1(
        clk, 200, 100, x, y, member1);
        
    assign rgb = member1 ? 12'hFFF : 12'h000;
endmodule
