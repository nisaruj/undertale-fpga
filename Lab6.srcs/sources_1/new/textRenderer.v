`timescale 1ns / 1ps

module textRenderer(
    output video_on,
    input [31:0] x,
    input [31:0] y,
    input clk
    );
    
        wire text;
        Pixel_On_Text2 #(.displayText("603xxxxxxx Name... Lastname...")) t1(
                clk,
                200, // text position.x (top left)
                200, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text  // result, 1 if current pixel is on text, 0 otherwise
            );
            
        assign video_on = text;
            
endmodule
