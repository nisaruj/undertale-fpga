`timescale 1ns / 1ps

module dodgeScene(
    output reg [11:0] rgb,
    output reg wasAttacked,
    output reg [31:0] attackDamage,
    input [7:0] kbControl,
    input [31:0] x,
    input [31:0] y,
    input isActive,
    input reset,
    input clk
    );
    
    // background
    reg video_on;
    always @(x or y)
    begin
        if (x == 160 || x == 480) // Vertical line
            video_on = y >= 280 && y <= 440;
        else if (y == 280 || y == 440) // Horizontal line
            video_on = x >= 160 && x <= 480;
        else video_on = 0;
    end
    
    // Player (Heart)
    reg [31:0] center_x, center_y;
    wire renderPlayer;
    heartRenderer heart(renderPlayer, x, y, center_x, center_y, clk); 
    
    initial
    begin
        center_x = 320;
        center_y = 360;
    end
    
    always @(posedge clk)
    begin
        wasAttacked <= 0;
        if (reset)
        begin
            center_x = 320;
            center_y = 360;
        end
        else if (isActive)
        begin
            if (kbControl == 119 && center_y > 280) //w
                center_y <= center_y - 2;
            else if (kbControl == 97 && center_x > 160) //a
                center_x <= center_x - 2;
            else if (kbControl == 115 && center_y < 440) //s
                center_y <= center_y + 2;
            else if (kbControl == 100 && center_x < 480) //d
                center_x <= center_x + 2;
            else if (kbControl == 32)
                wasAttacked <= 1;
        end
    end
    
    always @(posedge clk)
    begin
        if (renderPlayer) rgb <= 12'hF00;
        else if (video_on) rgb <= 12'hFFF;
        else rgb <= 12'h000; 
    end
endmodule
