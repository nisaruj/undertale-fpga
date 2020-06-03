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
	reg isPotion1, isPotion2;
	wire renderPlayer, renderGrid, renderBarricade, renderPotion1, renderPotion2;
	wire WBarricade, SBarricade, ABarricade, DBarricade;
	wire collectPotion1, collectPotion2;
	
	// 4bit Random number generator
	wire [3:0] rng;
	PRNG prng(rng, clk);
	
	initial
    begin
        center_x = 9'd4;
        center_y = 9'd476;
        rgb_reg = 12'hFFF;
        isPotion1 = 1;
        isPotion2 = 1;
    end
    
    barricadeRenderer barricade(renderBarricade, {22'd0,x}, {22'd0,y}, clk);
    barricadeRenderer W(WBarricade, {22'd0,center_x}, {22'd0,center_y - 8}, clk);
    barricadeRenderer A(ABarricade, {22'd0,center_x - 8}, {22'd0,center_y}, clk);
    barricadeRenderer S(SBarricade, {22'd0,center_x}, {22'd0,center_y + 8}, clk);
    barricadeRenderer D(DBarricade, {22'd0,center_x + 8}, {22'd0,center_y}, clk);
    renderer circle(renderPlayer, {22'd0, center_x}, {22'd0,center_y}, {22'd0,x}, {22'd0,y}, 4); 
    potionRenderer potion1(renderPotion1, {22'd0, 80}, {22'd0, 300}, {22'd0,x}, {22'd0,y}, clk);
    potionRenderer potion2(renderPotion2, {22'd0, 300}, {22'd0, 150}, {22'd0,x}, {22'd0,y}, clk);
    potionRenderer collect1(collectPotion1, {22'd0, 80}, {22'd0, 300}, {22'd0,center_x}, {22'd0,center_y}, clk);
    potionRenderer collect2(collectPotion2, {22'd0, 300}, {22'd0, 150}, {22'd0,center_x}, {22'd0,center_y}, clk);    
//    gridRenderer grid(renderGrid, {22'd0,x}, {22'd0,y}, 8);
    
    assign out = ( ( renderPotion1 && isPotion1 ) || ( renderPotion2 && isPotion2 ) ? 12'hF00 : ((renderPlayer || renderBarricade /*|| renderGrid*/) ? rgb_reg : 12'b0));

    always @(posedge clk)
    begin
        if(collectPotion1 && isPotion1)
            isPotion1 = 0; //collect potion 1
        else if(collectPotion2 && isPotion2)
            isPotion2 = 0; //collect potion 2
    end
        
    // Change to battle scene randomly
//    always @(posedge clk)
//        if (kbControl > 0)
//            begin
//            if (rng > 4'd13)
//                sceneChangeTrigger <= 1;
//            end
//        else
//            sceneChangeTrigger <= 0;

    always @(posedge clk)
    begin
        if (isActive)
        begin
            if (kbControl == 119 && !WBarricade) //w
                center_y <= center_y - 8;
            else if (kbControl == 97 && !ABarricade) //a
                center_x <= center_x - 8;
            else if (kbControl == 115 && !SBarricade) //s
                center_y <= center_y + 8;
            else if (kbControl == 100 && !DBarricade) //d
                center_x <= center_x + 8;
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
