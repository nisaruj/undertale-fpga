`timescale 1ns / 1ps

module SceneRenderer(
    output [11:0] rgb,
    input [7:0] kbControl,
    input [9:0] x,
    input [9:0] y,
    input clk
    );
    
    //scene rgb
    parameter N_SCENE = 2;
    wire [11:0] rgb_out [N_SCENE - 1:0];
    
    textRenderer(rgb_out[0], x, y, clk);
    mapScene scene1(rgb_out[1], kbControl, x, y, clk);
    
    // scene decoder
    parameter N_SCENE_BIT = 1;
    reg [N_SCENE_BIT - 1: 0] scene_state;
    initial
    begin
        scene_state = 1'b0;
    end
    
    always @(posedge clk)
    begin
        if (scene_state == 0 && kbControl > 0)
            scene_state <= 1;
    end
    
    assign rgb = rgb_out[scene_state];
    
endmodule
