`timescale 1ns / 1ps

module selectEnemyScene(
    output [11:0] rgb,
    output reg selected,
    output reg [1:0] selector,
    input [7:0] kbControl,
    input [31:0] x,
    input [31:0] y,
    input isActive,
    input clk
    );
    
    reg video_on;
    always @(posedge clk)
    begin
        if (x == 80 || x == 560) // Vertical line
            video_on = y >= 280 && y <= 440;
        else if (y == 280 || y == 440) // Horizontal line
            video_on = x >= 80 && x <= 560;
        else video_on = 0;
    end
    
    wire [3:0] enemyName;
    Pixel_On_Text2 #(.displayText("Select an enemy to attack.")) t1(
        clk, 140, 300, x, y, enemyName[0]);
    
    Pixel_On_Text2 #(.displayText("Enemy 1")) t2(
        clk, 150, 330, x, y, enemyName[1]);
    
    Pixel_On_Text2 #(.displayText("Enemy 2")) t3(
        clk, 150, 350, x, y, enemyName[2]);
        
    Pixel_On_Text2 #(.displayText("Enemy 3")) t4(
        clk, 150, 370, x, y, enemyName[3]);
    
    wire [31:0] selectorPos;
    wire renderSelector;
    assign selectorPos = 330 + selector * 20;
    heartRenderer pointer(renderSelector, x, y, 140, selectorPos, clk);
    
    always @(posedge clk)
    begin
        if (!isActive)
            selector <= 0;
        else if (kbControl == 32) selected <= 1; //space
        else if (kbControl == 119 && selector > 0) //w
            selector <= selector - 1;
        else if (kbControl == 115 && selector < 2) //s
            selector <= selector + 1; 
        else selected <= 0;
    end
    
    assign rgb = video_on || enemyName > 0 ? 12'hFFF : renderSelector ? 12'hF00 : 12'h000;
endmodule
