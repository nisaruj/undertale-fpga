`timescale 1ns / 1ps

module battleScene(
    output [11:0] rgb,
    output reg attacked,
    output reg [31:0] attackDamage,
    input [7:0] kbControl,
    input [31:0] x,
    input [31:0] y,
    input isActive,
    input reset,
    input clk
//    ,
//    output reg [7:0] attackPenalty,
//    output wire [15:0] gaugeOffset
    );
    
    wire text, renderGauge;
    reg [7:0] attackPenalty; // 0 to 100%
    reg gaugePosition; // 0 leftside, 1 rightside of the center
    reg gaugeMovingDirection; // 0 to right, 1 to left
    wire [15:0] gaugeOffset;
    wire frameClk;
    reg miss;
    
    frameClkGenerator fclk(frameClk, clk);
    
    Pixel_On_Text2 #(.displayText("Battle Scene")) t1(
        clk, 200, 100, x, y, text);
        
    gaugeRenderer gauge(renderGauge, {22'd0,x}, {22'd0,y}, gaugeOffset);
    assign gaugeOffset = (attackPenalty * 8'd24 / 8'd10) * (gaugePosition == 0 ? -1 : 1);

    initial
    begin
        attackPenalty = 100;
        gaugeMovingDirection = 0;
        gaugePosition = 0;
        miss = 0;
    end
        
    always @(posedge clk)
    begin
        if (kbControl == 32 && isActive) //space 
        begin
            attacked <= 1;
            attackDamage <= 60 - (attackPenalty * 5 / 10);
        end
        else if (miss && isActive && !reset)
        begin
            attacked <= 1;
            attackDamage <= 0;
        end
        else
        begin
            attacked <= 0;
            attackDamage <= 0;
        end
    end
    
    // Moving gauge pointer
    always @(posedge frameClk)
    begin
        if (isActive)
        case ({ gaugePosition, gaugeMovingDirection })
            2'b00:
            begin
                attackPenalty <= attackPenalty - 1;
                if (attackPenalty == 0) gaugePosition <= 1;
            end
            2'b01:
            begin
                attackPenalty <= attackPenalty + 1;
                if (attackPenalty == 100) gaugeMovingDirection <= 0;
            end
            2'b10:
            begin
                attackPenalty <= attackPenalty + 1;
                if (attackPenalty == 100) 
                begin
                    miss <= 1;
                end
            end
            2'b11:
            begin
                attackPenalty <= attackPenalty - 1;
                if (attackPenalty == 0) gaugePosition <= 0;
            end
        endcase
        else 
        begin
            miss <= 0;
            gaugeMovingDirection <= 0;
            gaugePosition <= 0;
            attackPenalty <= 100;
        end
    end
        
    assign rgb = (text || renderGauge) ? 12'hFFF : 12'h000;
endmodule
