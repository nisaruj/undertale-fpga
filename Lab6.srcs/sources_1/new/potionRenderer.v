`timescale 1ns / 1ps

module potionRenderer(
    output hasPotion,
    input [31:0] center_x,
    input [31:0] center_y,    
    input [31:0] x,
    input [31:0] y,
    input clk
    );
    
    assign hasPotion =  ((center_x - x) * (center_x - x) 
        + (center_y - y) * (center_y - y))
        <= (10 * 10);
    
endmodule
