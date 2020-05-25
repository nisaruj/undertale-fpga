`timescale 1ns / 1ps

module gaugeRenderer(
    output reg video_on,
    input [31:0] x,
    input [31:0] y,
    input [15:0] currentOffset
    );
    
    always @(x or y or currentOffset)
    begin
        if (x == 80 || x == 560) // Vertical line
            video_on = y >= 280 && y <= 440;
        else if (y == 280 || y == 440) // Horizontal line
            video_on = x >= 80 && x <= 560;
        else if (x[15:0] == 16'd320 + currentOffset) // Moving pointer
            video_on = y >= 300 && y <= 420;
        else if (y >= 280 && y <= 300 && x >= 310 && x <= 330) // Center triangle
        begin
            if (x >= 320) video_on = (-y + 300 >= 2 * x - 640);
            else video_on = (-y + 300 >= -2 * x + 640);
        end
        else video_on = 0;
    end
    
endmodule
