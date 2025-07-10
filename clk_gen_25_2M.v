`timescale 1ns / 1ps
module clk_gen_25_2M(
    input clk_ref,
    input rst,
    output clk_25_2M, clk_100M
    );
    clk_wiz_0 clk_gen (.clk_out1(clk_25_2M), .clk_out2(clk_100M), .reset(rst), .clk_in1(clk_ref));
endmodule
