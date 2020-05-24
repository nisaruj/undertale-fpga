`timescale 1ns / 1ps

module textRenderer(
    output [11:0] rgb,
    input [31:0] x,
    input [31:0] y,
    input clk
    );
    
    wire member1, member2, member3, member4, member5, anykey;
    Pixel_On_Text2 #(.displayText("6031033521 Nisaruj Rattanaaram")) t1(
        clk, 200, 100, x, y, member1);
    Pixel_On_Text2 #(.displayText("603*****21 Sorawit Sunthawatrodom")) t2(
        clk, 200, 150, x, y, member2);
    Pixel_On_Text2 #(.displayText("603*****21 Pawat Amornpitakpun")) t3(
        clk, 200, 200, x, y, member3);
    Pixel_On_Text2 #(.displayText("603*****21 Siwat Pongpanit")) t4(
        clk, 200, 250, x, y, member4);
    Pixel_On_Text2 #(.displayText("603*****21 Khanisorn Khemthong")) t5(
        clk, 200, 300, x, y, member5);
    Pixel_On_Text2 #(.displayText("Press any key to continue...")) t6(
        clk, 200, 350, x, y, anykey);
        
    assign rgb = (member1 || member2 || member3 || member4 || member5 || anykey) ? 12'hFFF : 12'h000;
endmodule
