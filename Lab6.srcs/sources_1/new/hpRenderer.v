`timescale 1ns / 1ps

module hpRenderer(
    output reg video_on,
    input [31:0] x,
    input [31:0] y,
    input [31:0] posX, // 80
    input [31:0] posY,
    input [31:0] barHeight, // 20
    input [31:0] currentHP // 0 - 480
);
    
    always @(x or y or posX or posY or currentHP or barHeight)
    begin
        if (x >= posX && x <= posX + currentHP)
            video_on = y >= posY && y <= posY + barHeight;
        else video_on = 0;
    end
endmodule
