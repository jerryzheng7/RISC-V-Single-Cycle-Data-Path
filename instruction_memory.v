
`timescale 1ns / 1ps

module InstructionMemory(
    input [31:0] Address,               // Address input
    output reg [31:0] ReadData1         // Output for the instruction
);
    parameter BITSIZE = 32;
    parameter REGSIZE = 128;            // Updated size to accommodate more instructions

    reg [BITSIZE-1:0] memory_file [0:REGSIZE-1]; // Memory array

    // Asynchronous read of memory
    always @(*) begin
        if (Address < (REGSIZE << 1)) // Ensure address is within bounds
            ReadData1 = memory_file[Address >> 0]; // Divide by 4 to convert byte address to word index
        else
            ReadData1 = 32'b0; // Return zero if out of bounds
    end

    integer i;
    // Method of filling the memory initially with some example instructions
    initial begin
        // Initialize all memory to 0
        for (i = 0; i < 30; i = i + 1) begin
            memory_file[i] = 32'b0;
        end

        // Initialize specific memory values with instructions
    i = 0;
    memory_file[i] = 32'b000000000001_00000_000_00001_0011111; // ADDI x1, x0, 1
    i = 1;
    memory_file[i] = 32'b000000000010_00001_000_00010_0011111; // ADDI x2, x1, 2
    i = 2;    
    memory_file[i] = 32'b000000000000_00001_001_00010_0011111; // ORI x2, x1, 0
    i = 3;
    memory_file[i] = 32'b0000000_00010_00001_001_00011_1110011; // ADD x3, x1, x2
    i = 4;
    memory_file[i] = 32'b0100000_00001_00011_001_00100_1110011; // SUB x4, x3, x1
    i = 5;
    memory_file[i] = 32'b0000000_00011_00100_000_00101_1110011; // AND x5, x4, x3
    i = 6;
    memory_file[i] = 32'b0000000_00100_00101_010_00110_1110011; // OR x6, x5, x4
    i = 7;
    memory_file[i] = 32'b0000000_00101_00110_100_00111_1110011; // XOR x7, x6, x5
    i = 8;
    memory_file[i] = 32'b0000000_00110_00111_101_01000_1110011; // SRA x8, x7, x6
    i = 9;
    memory_file[i] = 32'b0000000_00111_01000_111_01001_1110011; // SLT x9, x8, x7
    i = 10;
    memory_file[i] = 32'b000000000100_00010_010_01010_1000011;  // LW x10, 4(x2)
    i = 11;
    memory_file[i] = 32'b0000000_01010_00011_010_01000_1100011; // SW x10, 8(x3)
    i = 12;
    memory_file[i] = 32'b00000000000000000001_01011_0110000;    // LUI x11, 0x1
    i = 13;
    memory_file[i] = 32'b000000001000_00001_010_01101_0011111; // XORI x13, x1, 8
    i = 14;
    memory_file[i] = 32'b0000000_00100_00001_110_01010_1110011; // SLL x10, x1, x4 (Shift Left Logical)
    i = 15;
    memory_file[i] = 32'b0_000000_00100_00001_000_0001_0_1101011; // BEQ x1, x4 (branch  if x1 == x4)
    i = 17;
    memory_file[i] = 32'b0_000000_00101_00100_001_0001_0_1101011; // BLT x5, x4, offset (branch to offset if x4 < x5)
    end
endmodule



