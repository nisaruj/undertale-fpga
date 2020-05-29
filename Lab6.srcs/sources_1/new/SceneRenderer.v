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
    wire switchToBattleScene, switchToMapScene, switchToDodgeScene;
    wire [31:0] attackDamage, receiveDamage;

    //scene rgb
    reg [2 ** N_SCENE_BIT - 1: 0] reset_scene;
    textRenderer(rgb_out[0], x, y, clk);
    mapScene scene1(rgb_out[1], switchToBattleScene, kbControl, x, y, scene_state == 1, clk);
    battleScene scene2(rgb_out[2], switchToDodgeScene, attackDamage, kbControl, x, y, scene_state == 2, clk);
    dodgeScene scene3(rgb_out[3], switchToMapScene, receiveDamage, kbControl, x, y, scene_state == 3, reset_scene[3], clk);
    
    // HP Bar
    reg [31:0] playerHP, enemyHP;
    wire [11:0] playerBarRgb, enemyBarRgb;
    wire renderPlayerHP, renderEnemyHP;
    
    hpRenderer playerHPBar(renderPlayerHP, x, y, 80, 20, 10, playerHP);
    assign playerBarRgb = (scene_state > 0 && renderPlayerHP) ? 12'h0F0 : 12'h000;
    
    hpRenderer enemyHPBar(renderEnemyHP, x, y, 80, 40, 10, enemyHP);
    assign enemyBarRgb = (scene_state > 0 && renderEnemyHP) ? 12'hF00 : 12'h000;
    
    // scene decoder
    initial
    begin
        scene_state = 1'b0;
        playerHP = 32'd480;
        enemyHP = 32'd480;
        reset_scene = 0;
    end
    
    always @(posedge clk)
    begin
        if (scene_state == 0 && kbControl > 0)
            scene_state <= 1;
        else if (scene_state == 1 && switchToBattleScene)
            scene_state <= 2;
        else if (scene_state == 2 && switchToDodgeScene)
        begin
            enemyHP <= enemyHP - attackDamage;
            scene_state <= 3;
            reset_scene[3] <= 1;
        end
        else if (scene_state == 3 && switchToMapScene)
        begin
            scene_state <= 1;
        end
        else reset_scene <= 0;
    end
    
    assign rgb = rgb_out[scene_state] | playerBarRgb | enemyBarRgb;
    
endmodule
