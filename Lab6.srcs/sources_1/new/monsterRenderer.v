`timescale 1ns / 1ps

module monsterRenderer(
    output reg video_on,
    input [31:0] x,
    input [31:0] y,
    input [31:0] pos_x,
    input [31:0] pos_y,
    input [1:0] monster,
    input clk
    );
    
   parameter ROM_WIDTH = 128; // Image's width
   parameter ROM_ADDR_BITS = 6; // Image's height = 2**n_bit

   (* rom_style="{distributed | block}" *)
   reg [ROM_WIDTH-1:0] rom1 [(2**ROM_ADDR_BITS)-1:0];
   (* rom_style="{distributed | block}" *)
   reg [ROM_WIDTH-1:0] rom2 [(2**ROM_ADDR_BITS)-1:0];
   (* rom_style="{distributed | block}" *)
   reg [ROM_WIDTH-1:0] rom3 [(2**ROM_ADDR_BITS)-1:0];
   (* rom_style="{distributed | block}" *)
   reg [ROM_WIDTH-1:0] rom11 [(2**ROM_ADDR_BITS)-1:0];
   (* rom_style="{distributed | block}" *)
   reg [ROM_WIDTH-1:0] rom21 [(2**ROM_ADDR_BITS)-1:0];
   (* rom_style="{distributed | block}" *)
   reg [ROM_WIDTH-1:0] rom31 [(2**ROM_ADDR_BITS)-1:0];

   initial
   begin
      $readmemb("rom/monster1-1.bit", rom1, 0, (2**ROM_ADDR_BITS)-1);
      $readmemb("rom/monster1-2.bit", rom11, 0, (2**ROM_ADDR_BITS)-1);
      $readmemb("rom/monster2-1.bit", rom2, 0, (2**ROM_ADDR_BITS)-1);
      $readmemb("rom/monster2-2.bit", rom21, 0, (2**ROM_ADDR_BITS)-1);
      $readmemb("rom/monster3-1.bit", rom3, 0, (2**ROM_ADDR_BITS)-1);
      $readmemb("rom/monster3-2.bit", rom31, 0, (2**ROM_ADDR_BITS)-1);
    end
    
   wire frameClk;
   reg [7:0] timeCounter;
   reg animationFrame;
   frameClkGenerator fclk(frameClk, clk);
   
   initial
   begin
    animationFrame = 0;
    timeCounter = 0;
   end
   
   always @(posedge frameClk)
   begin
        timeCounter <= timeCounter + 1;
        if (timeCounter == 0) animationFrame <= ~animationFrame;
   end

   always @(posedge clk)
      if (y >= pos_y && y <= pos_y + 2**ROM_ADDR_BITS && x >= pos_x && x <= pos_x + ROM_WIDTH)
        begin
            if (monster == 0) video_on <= animationFrame ? rom11[y-pos_y][x-pos_x] : rom1[y-pos_y][x-pos_x];
            else if (monster == 1) video_on <= animationFrame ? rom21[y-pos_y][x-pos_x] : rom2[y-pos_y][x-pos_x];
            else video_on <= animationFrame ? rom31[y-pos_y][x-pos_x] : rom3[y-pos_y][x-pos_x];
        end
      else video_on <= 0;
endmodule
