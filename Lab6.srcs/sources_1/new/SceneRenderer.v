`timescale 1ns / 1ps

module SceneRenderer(
    output [11:0] rgb,
    input [7:0] kbControl,
    input [9:0] x,
    input [9:0] y,
    input clk
    );
    
    parameter N_SCENE_BIT = 3;
    reg [N_SCENE_BIT - 1: 0] scene_state;
    wire [11:0] rgb_out [2 ** N_SCENE_BIT - 1:0];
    wire switchToBattleScene, switchToMapScene, switchToDodgeScene, wasAttacked, switchToEnemySelectScene;
    wire [31:0] attackDamage, receiveDamage;
    wire [1:0] enemySelector;

    //scene rgb
    reg [2 ** N_SCENE_BIT - 1: 0] reset_scene;
    textRenderer(rgb_out[0], x, y, clk);
    mapScene scene1(rgb_out[1], switchToEnemySelectScene, kbControl, x, y, scene_state == 1, clk);
    battleScene scene2(rgb_out[2], switchToDodgeScene, attackDamage, kbControl, x, y, scene_state == 2, reset_scene[2], clk);
    dodgeScene scene3(rgb_out[3], switchToMapScene, wasAttacked, receiveDamage, kbControl, x, y, scene_state == 3, reset_scene[3], clk);
    gameoverScene scene4(rgb_out[4], x, y, clk);
    selectEnemyScene scene7(rgb_out[7], switchToBattleScene, enemySelector, kbControl, x, y, scene_state == 7, clk);
    
    // HP Bar
    parameter ENEMY_COUNT = 3;
    reg [1:0] enemySelect;
    reg [31:0] playerHP;
    reg [31:0] enemyHP [ENEMY_COUNT-1:0];
    wire [11:0] playerBarRgb;
    wire [31:0] enemyBarRgb [ENEMY_COUNT-1:0];
    wire renderPlayerHP;
    wire renderEnemyHP [ENEMY_COUNT-1:0];
    wire enemyAllDie;
    
    assign enemyAllDie = (enemyHP[0] == 0) && (enemyHP[1] == 0) && (enemyHP[2] == 0);
  
    hpRenderer playerHPBar(renderPlayerHP, x, y, 80, 20, 10, playerHP);
    assign playerBarRgb = (scene_state > 0 && renderPlayerHP) ? 12'h0F0 : 12'h000;
    
    hpRenderer enemyHPBar0(renderEnemyHP[0], x, y, 80, 40, 5, enemyHP[0]);
    hpRenderer enemyHPBar1(renderEnemyHP[1], x, y, 80, 50, 5, enemyHP[1]);
    hpRenderer enemyHPBar2(renderEnemyHP[2], x, y, 80, 60, 5, enemyHP[2]);

    assign enemyBarRgb[0] = (scene_state > 0 && renderEnemyHP[0]) ? 12'hF00 : 12'h000;
    assign enemyBarRgb[1] = (scene_state > 0 && renderEnemyHP[1]) ? 12'hF00 : 12'h000;
    assign enemyBarRgb[2] = (scene_state > 0 && renderEnemyHP[2]) ? 12'hF00 : 12'h000;

    // scene decoder
    initial
    begin
        scene_state = 1'b0;
        playerHP = 32'd480;
        enemyHP[0] = 32'd480;
        enemyHP[1] = 32'd480;
        enemyHP[2] = 32'd480;
        reset_scene = 0;
        enemySelect = 0;
    end
    
    always @(posedge clk)
    begin
        if (scene_state == 0 && kbControl > 0)
            scene_state <= 1;
        else if (scene_state == 1 && switchToEnemySelectScene)
        begin
            scene_state <= 7;
            reset_scene[7] <= 1;
        end
        else if (scene_state == 2 && switchToDodgeScene)
        begin
            if (enemyHP[enemySelect] <= attackDamage) 
            begin
                enemyHP[enemySelect] <= 0;
                if (enemyAllDie) scene_state <= 4;
                else
                begin
                    scene_state <= 3;
                    reset_scene[3] <= 1;
                end
            end
            else 
            begin
                enemyHP[enemySelect] <= enemyHP[enemySelect] - attackDamage;
                scene_state <= 3;
                reset_scene[3] <= 1;
            end
        end
        else if (scene_state == 3)
        begin
            if (wasAttacked)
                if (playerHP <= receiveDamage) scene_state <= 4;
                else playerHP <= playerHP - receiveDamage;
            else if (switchToMapScene)
                scene_state <= 1;
        end
        else if (scene_state == 4 && kbControl > 0)
        begin
            scene_state = 1'b0;
            playerHP = 32'd480;
            enemyHP[0] = 32'd480;
            enemyHP[1] = 32'd480;
            enemyHP[2] = 32'd480;
            reset_scene = 0;
        end
        else if (scene_state == 7 && switchToBattleScene)
        begin
            enemySelect <= enemySelector;
            scene_state <= 2;
            reset_scene[2] <= 1;
        end
        else reset_scene <= 0;
    end
    
    assign rgb = rgb_out[scene_state] | playerBarRgb | enemyBarRgb[0] | enemyBarRgb[1] | enemyBarRgb[2];
//    assign rgb = rgb_out[1];
        
endmodule