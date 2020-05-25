`timescale 1ns / 1ps

module clockDiv(
    output reg clkDiv,
    input clk
    );
    
initial
    clkDiv=0;
    
always @(posedge clk)
    clkDiv=~clkDiv;
    
endmodule
