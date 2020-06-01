`timescale 1ns / 1ps
module barricadeRenderer(
    output [11:0] rgb,
    input [31:0] x,
    input [31:0] y,
    input clk
    );
    
    reg hasBarricade;
    
    always @(posedge clk)
    begin
        if (y < 100)
            hasBarricade = 1;
        else if (x < 50 && y < 400)
            hasBarricade = 1;
        else if (x > 150 && x < 400 && y > 250)
            hasBarricade = 1;
        else if (x > 500 && (y < 300 || y > 400))
            hasBarricade = 1;
        else
            hasBarricade = 0;
    end
    
    assign rgb = hasBarricade;
    
endmodule
