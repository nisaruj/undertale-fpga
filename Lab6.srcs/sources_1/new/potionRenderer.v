`timescale 1ns / 1ps

module potionRenderer(
    output hasPotion1,
    output hasPotion2,
    input [1:0] select,    
    input [31:0] x,
    input [31:0] y,
    input clk
    );
    
    reg potion1, potion2;
    
    always @(posedge clk)
    begin
        if(select == 0)
        begin
            potion1 = (((80 - x) * (80 - x) 
        + (300 - y) * (300 - y))
        <= (10 * 10));
            potion2 = (((300 - x) * (300 - x) 
        + (150 - y) * (150 - y))
        <= (10 * 10));
        end else if(select == 1)
        begin
            potion1 = (((100 - x) * (100 - x) 
        + (200 - y) * (200 - y))
        <= (10 * 10));
            potion2 = (((450 - x) * (450 - x) 
        + (350 - y) * (350 - y))
        <= (10 * 10));
        end else if(select == 2)
        begin
            potion1 = (((570 - x) * (570 - x) 
        + (70 - y) * (70 - y))
        <= (10 * 10));
            potion2 = (((70 - x) * (70 - x) 
        + (406 - y) * (406 - y))
        <= (10 * 10));
        end
    end
    
    assign hasPotion1 =  potion1;
    assign hasPotion2 =  potion2;
    
endmodule
