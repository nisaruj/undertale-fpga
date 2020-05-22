`timescale 1ns / 1ps

module textRenderer(
    output video_on,
    input [31:0] x,
    input [31:0] y,
    input clk
    );
        wire member1, member2, member3, member4, member5;
        Pixel_On_Text2 #(.displayText("603xxxxxxx Name... Lastname...1")) t1(
                clk,
                200,
                100,
                x,
                y,
                member1 
            );
        Pixel_On_Text2 #(.displayText("603xxxxxxx Name... Lastname...2")) t2(
                clk,
                200,
                150,
                x,
                y,
                member2
            ); 
        Pixel_On_Text2 #(.displayText("603xxxxxxx Name... Lastname...3")) t3(
                clk,
                200,
                200,
                x,
                y,
                member3
            );
        Pixel_On_Text2 #(.displayText("603xxxxxxx Name... Lastname...4")) t4(
                clk,
                200,
                250,
                x,
                y,
                member4
            );
        Pixel_On_Text2 #(.displayText("603xxxxxxx Name... Lastname...5")) t5(
                clk,
                200,
                300,
                x,
                y,
                member5
            );                                               
            
        assign video_on = member1 || member2 || member3 || member4 || member5;
            
endmodule
