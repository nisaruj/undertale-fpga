`timescale 1ns / 1ps

module dodgeScene(
    output reg [11:0] rgb,
    output reg sceneFinished,
    output reg wasAttacked,
    output reg [31:0] attackDamage,
    input [7:0] kbControl,
    input [31:0] x,
    input [31:0] y,
    input isActive,
    input reset,
    input clk
    );
    
    wire frameClk;
    reg [31:0] timeCounter;
    frameClkGenerator fclk(frameClk, clk);
    
    // background
    reg video_on;
    always @(x or y)
    begin
        if (x == 160 || x == 480) // Vertical line
            video_on = y >= 280 && y <= 440;
        else if (y == 280 || y == 440) // Horizontal line
            video_on = x >= 160 && x <= 480;
        else video_on = 0;
    end
    
    // Player (Heart)
    reg [31:0] center_x, center_y;
    wire renderPlayer;
    heartRenderer heart(renderPlayer, x, y, center_x, center_y, clk); 
    
    // Bullets
    parameter BULLET_COUNT = 2;
    reg [31:0] bullet_posX [BULLET_COUNT-1:0];
    reg [31:0] bullet_posY [BULLET_COUNT-1:0];
    reg [31:0] bullet_dirX [BULLET_COUNT-1:0];
    reg [31:0] bullet_dirY [BULLET_COUNT-1:0];
    reg [BULLET_COUNT-1:0] bullet_disappeared;
    wire [31:0] renderBullet [BULLET_COUNT-1:0];
    
    renderer b1(renderBullet[0], bullet_posX[0], bullet_posY[0], x, y, 6);
    renderer b2(renderBullet[1], bullet_posX[1], bullet_posY[1], x, y, 6);
    
    reg isCollide;
    
    initial
    begin
        center_x = 320;
        center_y = 360;
    end
    
    // Time counter
    always @(posedge frameClk)
    begin
        if (!isActive)
        begin
            timeCounter <= 0;
            sceneFinished <= 0;
        end else
            timeCounter <= timeCounter + 1;
        if (timeCounter > 1000)
            sceneFinished <= 1;
    end
    
    // Detect collision
    always @(posedge clk)
    begin
        if (!isActive)
        begin
            isCollide <= 0;
            bullet_disappeared <= 0;
        end
        else if (renderPlayer)
        begin
            if (renderBullet[0] && !bullet_disappeared[0])
            begin
                isCollide <= 1;
                bullet_disappeared[0] <= 1;
            end
            else if (renderBullet[1] && !bullet_disappeared[1])
            begin
                isCollide <= 1;
                bullet_disappeared[1] <= 1;
            end
        end
        else
            isCollide <= 0;
    end
    
    // Trigger damage
    reg [31:0] triggerPosX = 0, triggerPosY = 0;
    wire isTriggered = (x == triggerPosX) && (y == triggerPosY);
    
    always @(posedge clk)
    begin
        if (!isActive)
        begin
            triggerPosX <= -1;
            triggerPosY <= -1;
        end
        else if (isCollide && !isTriggered)
        begin
            wasAttacked <= 1;
            attackDamage <= 5;
            triggerPosX <= x;
            triggerPosY <= y;
        end
        else
            wasAttacked <= 0;
    end
    
    // Moving bullets
    always @(posedge frameClk)
    begin
        if (!isActive)
        begin
            bullet_posX[0] = 160;
            bullet_posY[0] = 360;
            bullet_dirX[0] = 1;
            bullet_dirY[0] = 0;
            bullet_posX[1] = 400;
            bullet_posY[1] = 280;
            bullet_dirX[1] = 0;
            bullet_dirY[1] = 1;
        end
        else
        begin
            // Bullet 1 moves horizontally
            bullet_posX[0] <= bullet_posX[0] + bullet_dirX[0];
            if (bullet_posX[0] > 480)
                bullet_dirX[0] <= -1;
            if (bullet_posX[0] < 160)
                bullet_dirX[0] <= 1;
                
            // Bullet 2 moves vertically
            bullet_posY[1] <= bullet_posY[1] + bullet_dirY[1];
            if (bullet_posY[1] > 440)
                bullet_dirY[1] <= -1;
            if (bullet_posY[1] < 280)
                bullet_dirY[1] <= 1;
        end
    end
    
    // Player control
    always @(posedge clk)
    begin
        if (!isActive)
        begin
            center_x = 320;
            center_y = 360;
        end
        else
        begin
            if (kbControl == 119 && center_y > 280) //w
                center_y <= center_y - 2;
            else if (kbControl == 97 && center_x > 160) //a
                center_x <= center_x - 2;
            else if (kbControl == 115 && center_y < 440) //s
                center_y <= center_y + 2;
            else if (kbControl == 100 && center_x < 480) //d
                center_x <= center_x + 2;
//            else if (kbControl == 32)
//                wasAttacked <= 1;
        end
    end
    
    // Render RGB
    always @(posedge clk)
    begin
        if (renderPlayer) rgb <= 12'hF00;
        else if (video_on) rgb <= 12'hFFF;
        else if (
            (renderBullet[0] && !bullet_disappeared[0]) || 
            (renderBullet[1] && !bullet_disappeared[1])
        )rgb <= 12'hABC;
        else rgb <= 12'h000; 
    end
endmodule
