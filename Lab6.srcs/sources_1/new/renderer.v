`timescale 1ns / 1ps

module renderer(
    output video_on,
    input [31:0] center_x,
    input [31:0] center_y,
    input [31:0] x,
    input [31:0] y,
    input [31:0] radius
    );
    
    assign video_on = 
        ((center_x - x) * (center_x - x) 
        + (center_y - y) * (center_y - y))
        <= (radius * radius);
endmodule
