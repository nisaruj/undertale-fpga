`timescale 1ns / 1ps

module gridRenderer(
    output video_on,
    input [31:0] x,
    input [31:0] y,
    input [31:0] size
    );
                
    assign video_on = (x % size == 0) || (y % size == 0);
endmodule
