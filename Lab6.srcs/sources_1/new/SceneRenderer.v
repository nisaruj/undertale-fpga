`timescale 1ns / 1ps

module SceneRenderer(
    output [11:0] rgb,
    input [7:0] kbControl,
    input [9:0] x,
    input [9:0] y,
    input clk
    );
    
    parameter N_SCENE_BIT = 2;
    reg [N_SCENE_BIT - 1: 0] scene_state;
    wire [11:0] rgb_out [2 ** N_SCENE_BIT - 1:0];
    wire switchToBattleScene, switchToMapScene;

    //scene rgb
    textRenderer(rgb_out[0], x, y, clk);
    mapScene scene1(rgb_out[1], switchToBattleScene, kbControl, x, y, clk);
    battleScene scene2(rgb_out[2], switchToMapScene, kbControl, x, y, clk);
    
    // scene decoder
    initial
    begin
        scene_state = 1'b0;
    end
    
    always @(posedge clk)
    begin
        if (scene_state == 0 && kbControl > 0)
            scene_state <= 1;
        else if (scene_state == 1 && switchToBattleScene)
            scene_state <= 2;
        else if (scene_state == 2 && switchToMapScene)
            scene_state <= 1;
    end
    
    assign rgb = rgb_out[scene_state];
    
endmodule
