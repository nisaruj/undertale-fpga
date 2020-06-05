`timescale 1ns / 1ps
module mapRenderer(
    output out,
    output isPotion,
    output w,
    output a,
    output s,
    output d,
    input [1:0] select,
    input [9:0] x,
    input [9:0] y,
    input [9:0] c_x,
    input [9:0] c_y,    
    input clk
    );
    
    reg [1:0] Potion [2:0];
    reg [1:0] resetPotion;
    wire renderBarricade, renderPotion1, renderPotion2;
    wire WBarricade, SBarricade, ABarricade, DBarricade;
    wire collectPotion1, collectPotion2;
    
    initial
    begin
        Potion[0] = 3;
        Potion[1] = 3;
        Potion[2] = 3;               
    end
    
    barricadeRenderer barricade(renderBarricade, select, {22'd0,x}, {22'd0,y}, clk);
    barricadeRenderer W(WBarricade, select, {22'd0,c_x}, {22'd0,c_y - 8}, clk);
    barricadeRenderer A(ABarricade, select, {22'd0,c_x - 8}, {22'd0,c_y}, clk);
    barricadeRenderer S(SBarricade, select, {22'd0,c_x}, {22'd0,c_y + 8}, clk);
    barricadeRenderer D(DBarricade, select, {22'd0,c_x + 8}, {22'd0,c_y}, clk);    
    potionRenderer potion(renderPotion1, renderPotion2, select, {22'd0,x}, {22'd0,y}, clk);
    potionRenderer collect(collectPotion1, collectPotion2, select, {22'd0,c_x}, {22'd0,c_y}, clk);  
    
    assign out =  ( renderPotion1 && Potion[select][0] ) || ( renderPotion2 && Potion[select][1] ) || renderBarricade;
    assign isPotion = ( renderPotion1 && Potion[select][0] ) || ( renderPotion2 && Potion[select][1] );
    assign w = WBarricade;
    assign s = SBarricade;
    assign a = ABarricade;
    assign d = DBarricade;
   
    always @(posedge clk)
    begin
        if(collectPotion1 && Potion[select][0])
            Potion[select][0] = 0; //collect potion 1
        else if(collectPotion2 && Potion[select][1])
            Potion[select][1] = 0; //collect potion 2
    end    
    
endmodule
