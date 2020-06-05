`timescale 1ns / 1ps
module barricadeRenderer(
    output hasBarricade,
    input [1:0] select,
    input [31:0] x,
    input [31:0] y,
    input clk
    );
    
    reg barricade;
    
    always @(posedge clk)
    begin
    if (select == 0)
    begin
        if (y < 100) //start map 1 x= 4 y= 476
            barricade = 1;
        else if (x < 50 && y < 400)
            barricade = 1;
        else if (x > 150 && x < 400 && y > 250)
            barricade = 1;
        else if (x > 500 && (y < 300 || y > 400))
            barricade = 1;
        else
            barricade = 0;
    end else if (select == 1)
    begin
        if (y < 50 && (x < 300 || x > 400)) //start map 2 x= 350 y= 4
            barricade = 1;
        else if (x < 50 || x > 600 || y > 420)
            barricade = 1;
        else
            barricade = 0;
    end else if (select == 2)
    begin
        if ((x < 20 && (y < 20 || y > 120)) || y < 20 || x > 620 || y > 456) //start map 3 x= 12 y= 60
            barricade = 1;
        else if (x > 120 && y > 120)
            barricade = 1;
        else
            barricade = 0;
    end
    end
    
    assign hasBarricade = barricade;
    
endmodule
