`timescale 1ns / 1ps

module heartRenderer(
    output reg video_on,
    input [31:0] x,
    input [31:0] y,
    input [31:0] pos_x,
    input [31:0] pos_y,
    input clk
    );
   parameter ROM_WIDTH = 8; // Image's width
   parameter ROM_ADDR_BITS = 4; // Image's height = 2**n_bit

   (* rom_style="{distributed | block}" *)
   reg [ROM_WIDTH-1:0] rom [(2**ROM_ADDR_BITS)-1:0];

   initial
      $readmemb("rom/heart.bit", rom, 0, (2**ROM_ADDR_BITS)-1);

   always @(posedge clk)
      if (y >= pos_y && y <= pos_y + 2**ROM_ADDR_BITS && x >= pos_x && x <= pos_x + ROM_WIDTH)
        video_on <= rom[y-pos_y][x-pos_x];
      else video_on <= 0;
endmodule
