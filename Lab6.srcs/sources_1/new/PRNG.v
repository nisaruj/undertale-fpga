`timescale 1ns / 1ps

module PRNG(
    output reg [3:0] random,
    input clk
    );
   
   // Seed
   initial
       random = 4'h0;
   
   always @(posedge clk)
   begin
       random[3:1] <= random[2:0];
       random[0] <= ~^random[3:2];
   end
endmodule
