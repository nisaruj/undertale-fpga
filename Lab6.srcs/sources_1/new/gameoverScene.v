`timescale 1ns / 1ps

module gameoverScene(
    output [11:0] rgb,
    input [31:0] x,
    input [31:0] y,
    input clk
    );
    
    wire gameover;
    Pixel_On_Text2 #(.displayText("Gameover: Press anykey to play again.")) t1(
        clk, 200, 100, x, y, gameover);
        
    assign rgb = gameover ? 12'hFFF : 12'h000;
endmodule
