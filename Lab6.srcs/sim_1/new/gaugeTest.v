`timescale 1ns / 1ps

module gaugeTest;
    wire [11:0] rgb;
    wire attacked;
    reg [7:0] kb;
    reg [31:0] x, y;
    reg clk = 0;
    
    wire [7:0] attackPenalty;
    wire [15:0] gaugeOffset;
    wire [15:0] realPosX;
    
    assign realPosX = 16'd320 + gaugeOffset;
    
    always
        #10
        clk = ~clk;
    
    battleScene bs(rgb, attacked, kb, x, y, clk, attackPenalty, gaugeOffset);
endmodule
