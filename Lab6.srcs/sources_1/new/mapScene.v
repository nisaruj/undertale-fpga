`timescale 1ns / 1ps

module mapScene(
    output wire[11:0] out,
    input wire[7:0] kbControl, //keyboard key
    input [9:0] x,
    input [9:0] y,
    input clk
);
    reg [11:0] rgb_reg;
	reg [9:0] center_x, center_y;
	wire renderPlayer;
	
	initial
    begin
        center_x = 9'd320;
        center_y = 9'd240;
        rgb_reg = 12'hFFF;
    end
    
    renderer circle(renderPlayer, {22'd0, center_x}, {22'd0,center_y}, {22'd0,x}, {22'd0,y}, 100); 
    
    assign out = renderPlayer ? rgb_reg : 12'b0;

    always @(posedge clk)
    begin
        if (kbControl == 119) //w
            center_y <= center_y - 1;
        else if (kbControl == 97) //a
            center_x <= center_x - 1;
        else if (kbControl == 115) //s
            center_y <= center_y + 1;
        else if (kbControl == 100) //d
            center_x <= center_x + 1;
        else if (kbControl == 99) //c
            rgb_reg <= 12'h0FF;
        else if (kbControl == 109) //m
            rgb_reg <= 12'hF0F;
        else if (kbControl == 121) //y
            rgb_reg <= 12'hFF0;
        else if (kbControl == 32) //space
            rgb_reg <= 12'hFFF;
    end
    
endmodule
