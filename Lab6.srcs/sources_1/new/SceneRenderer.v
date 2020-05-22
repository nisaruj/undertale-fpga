`timescale 1ns / 1ps

module SceneRenderer(
    output [11:0] rgb,
    input kbControl,
    input [9:0] x,
    input [9:0] y,
    input clk
    );
    
    //scene rgb
    parameter N_SCENE = 2;
    wire [11:0] rgb_out [N_SCENE - 1:0];
    
    mapScene scene1(rgb_out[0], kbControl, x, y, clk);
    textRenderer(rgb_out[1], x, y, clk);
    
    // scene decoder
    parameter N_SCENE_BIT = 1;
    reg [N_SCENE_BIT - 1: 0] scene_state;
    initial
    begin
        scene_state = 1'b1;
    end
    
    assign rgb = rgb_out[scene_state];
    
endmodule
