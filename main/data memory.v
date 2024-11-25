
`timescale 1ns / 1ps

module DataMemory #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 6
) (
    input wire clk,                 // Clock signal for synchronous writes
    input wire MemRead,             // Enable signal for read
    input wire MemWrite,            // Enable signal for write
    input wire [ADDR_WIDTH-1:0] address,
    input wire [DATA_WIDTH-1:0] writeData,
    output reg [DATA_WIDTH-1:0] readData
);

    // Memory Declaration: Array of registers, with 2^ADDR_WIDTH addresses
    reg [DATA_WIDTH-1:0] data_mem [(2**ADDR_WIDTH)-1:0];

    // Initialize memory contents to zero for simulation consistency
    integer i;
    initial begin
        for (i = 0; i < (2**ADDR_WIDTH); i = i + 1) begin
            data_mem[i] = {DATA_WIDTH{1'b0}}; // Set all memory values to zero initially
        end
    end

    // Synchronous Write Operation - Occurs on rising edge of the clock
    always @(posedge clk) begin
        if (MemWrite) begin
            data_mem[address] <= writeData; // Write data to the specified memory address
        end
    end

    // Asynchronous Read Operation - Only when MemRead is high
    always @(*) begin
        if (MemRead) begin
            readData = data_mem[address]; // Read data from memory if MemRead is asserted
        end else begin
            readData = {DATA_WIDTH{1'bz}}; // High impedance if not reading
        end
    end

endmodule

