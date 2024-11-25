`timescale 1ns / 1ps

module ProgramCounter(clk, rst, nextPC, currentPC);
    input clk, rst;
    input [31:0] nextPC;
    output reg [31:0] currentPC;

    always @(posedge clk or posedge rst) begin
        if (rst)
            currentPC <= 32'b0; // Reset to the first instruction address
        else
            currentPC <= nextPC; // Update with the next instruction address
    end
endmodule


