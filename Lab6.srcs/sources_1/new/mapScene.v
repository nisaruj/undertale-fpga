`timescale 1ns / 1ps

module mapScene(
    output [11:0] out,
    output reg sceneChangeTrigger,
    input [7:0] kbControl, //keyboard key
    input [9:0] x,
    input [9:0] y,
    input isActive,
    input clk
);
    reg [11:0] rgb_reg;
	reg [9:0] center_x, center_y;
	reg [1:0] selector;
	wire renderPlayer, renderGrid;
	wire WBarricade, SBarricade, ABarricade, DBarricade, isPotion, mapResult;
	
	// 4bit Random number generator
	wire [3:0] rng;
	PRNG prng(rng, clk);
	
	initial
    begin
        center_x = 9'd4;
        center_y = 9'd476;
        rgb_reg = 12'hFFF;
    end
    
    renderer circle(renderPlayer, {22'd0, center_x}, {22'd0,center_y}, {22'd0,x}, {22'd0,y}, 4); 
    mapRenderer map(mapResult, isPotion, WBarricade, ABarricade, SBarricade, DBarricade, selector, {22'd0,x}, {22'd0,y}, {22'd0, center_x}, {22'd0,center_y}, clk);
//    gridRenderer grid(renderGrid, {22'd0,x}, {22'd0,y}, 8);
    
    assign out = (mapResult && isPotion) ? 12'hF00 : (renderPlayer || mapResult) ? rgb_reg : 12'b0;
//    assign out = ( ( renderPotion1 && isPotion1 ) || ( renderPotion2 && isPotion2 ) ? 12'hF00 : ((renderPlayer || renderBarricade /*|| renderGrid*/) ? rgb_reg : 12'b0));

    // Change to battle scene randomly
    always @(posedge clk)
        if (kbControl > 0)
            begin
            if (rng > 4'd13)
                sceneChangeTrigger <= 1;
            end
        else
            sceneChangeTrigger <= 0;

    always @(posedge clk)
    begin
        if (isActive)
        begin
            if (kbControl == 119 && !WBarricade) //w
            begin
                center_y <= center_y - 8;
                if ((center_y <= 12 || center_y > 476) && selector == 1 && center_x >= 300 && center_x <= 400) //overflow negative?
                begin
                    selector = 0;
                    center_x <= 452;
                    center_y <= 468;
                end                
            end
            else if (kbControl == 97 && !ABarricade) //a
            begin
                center_x <= center_x - 8;
                if (center_x <= 12 && selector == 2 && (center_y >= 20 || center_y <= 120))
                begin
                    selector = 0;
                    center_x <= 612;
                    center_y <= 348;
                end                
            end
            else if (kbControl == 115 && !SBarricade) //s
            begin
                center_y <= center_y + 8;
                if (center_y >= 476 && selector == 0 && center_x >= 400 && center_x <= 500)
                begin
                    selector = 1;
                    center_x <= 348;
                    center_y <= 20;
                end
            end
            else if (kbControl == 100 && !DBarricade) //d
            begin
                center_x <= center_x + 8;
                if (center_x >= 620 && selector == 0 && (center_y >= 300 || center_y <= 400))
                begin
                    selector = 2;
                    center_x <= 20;
                    center_y <= 60;
                end                
            end
            else if (kbControl == 99) //c
                rgb_reg <= 12'h0FF;
            else if (kbControl == 109) //m
                rgb_reg <= 12'hF0F;
            else if (kbControl == 121) //y
                rgb_reg <= 12'hFF0;
            else if (kbControl == 32) //space
                rgb_reg <= 12'hFFF;
        end
    end
    
endmodule
