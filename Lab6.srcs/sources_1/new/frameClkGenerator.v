`timescale 1ns / 1ps

module frameClkGenerator(
    output targetClk,
    input clk
);

parameter DIV_COUNT = 19;
wire [DIV_COUNT:0] tclk;
assign tclk[0]=clk;

genvar c;
generate for(c=0;c<DIV_COUNT;c=c+1)
begin
    clockDiv fdiv(tclk[c+1], tclk[c]);
end endgenerate

clockDiv fDivTarget(targetClk, tclk[DIV_COUNT]);

endmodule