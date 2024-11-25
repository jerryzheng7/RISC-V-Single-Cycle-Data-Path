`timescale 1ns / 1ps

module Register_File(
    input [$clog2(REGSIZE)-1:0] ReadSelect1, ReadSelect2, WriteSelect,
    input [BITSIZE-1:0] WriteData,
    input WriteEnable,
    output reg [BITSIZE-1:0] ReadData1, ReadData2,
    input clk, rst
);
    parameter BITSIZE = 32;
    parameter REGSIZE = 32;

    reg [BITSIZE-1:0] reg_file [REGSIZE-1:0];   // Entire list of registers

    integer i; // Used for initializing registers

    initial begin
        reg_file[0] = 32'd0;  // x0 = 0
        // Initialize x1 to x13 to 1
        for (i = 1; i <= 13; i = i + 1) begin
            reg_file[i] = 32'd0;
        end
        // Initialize the rest of the registers to zero
        for (i = 14; i < REGSIZE; i = i + 1) begin
            reg_file[i] = 32'd0;
        end
    end

    // Asynchronous read of register file.
    always @(*) begin
        ReadData1 = reg_file[ReadSelect1];
        ReadData2 = reg_file[ReadSelect2];
    end

    // Write back to register file on clk edge.
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < REGSIZE; i = i + 1)
                reg_file[i] <= 32'b0; // Reset all registers
        end else if (WriteEnable && WriteSelect != 0) begin
            reg_file[WriteSelect] <= WriteData; // Write back data
        end
    end
endmodule
