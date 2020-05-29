`timescale 1ns / 1ps
module menuRenderer(
    output [11:0] rgb,
    output [1:0] select,
    input [7:0] kbControl,
    input [31:0] x,
    input [31:0] y,
    input clk
    );
    
    wire option1, option2, option3, option4, cursor1, cursor2, cursor3, cursor4;
    reg [1:0] state;
    Pixel_On_Text2 #(.displayText("FIGHT")) t1(
        clk, 150, 450, x, y, option1);
    Pixel_On_Text2 #(.displayText("ACT")) t2(
        clk, 250, 450, x, y, option2);
    Pixel_On_Text2 #(.displayText("ITEM")) t3(
        clk, 350, 450, x, y, option3);
    Pixel_On_Text2 #(.displayText("MERCY")) t4(
        clk, 450, 450, x, y, option4); 
    Pixel_On_Text2 #(.displayText(">")) t5(
        clk, 130, 450, x, y, cursor1);   
    Pixel_On_Text2 #(.displayText(">")) t6(
        clk, 230, 450, x, y, cursor2);
    Pixel_On_Text2 #(.displayText(">")) t7(
        clk, 330, 450, x, y, cursor3);
    Pixel_On_Text2 #(.displayText(">")) t8(
        clk, 430, 450, x, y, cursor4);                
     
    always @(posedge clk)
    begin
        if (kbControl == 97 && state > 0) //a
            state = state - 1;
        else if (kbControl == 100 && state < 4) //d
            state = state + 1;
    end        
        
    assign select = state;
    assign rgb = (option1 || option2 || option3 || option4 || (state[1] ? (state[0] ? cursor4 : cursor3) : (state[0] ? cursor2 : cursor1))) ? 12'hFFF : 12'h000;
    
endmodule
