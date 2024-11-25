`timescale 1ns / 1ps

module ControlLogic(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input [31:0] instruction,
    output reg RegWrite,
    output reg ALU_Src,
    output reg MemtoReg,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg [3:0] ALU_Control,
    output reg [4:0] Reg1Address,
    output reg [4:0] Reg2Address,
    output reg [4:0] WriteRegAddress,
    output reg [31:0] Immediate
);

    always @(*) begin
        // Default values
        RegWrite = 0;
        ALU_Src = 0;
        MemtoReg = 0;
        MemRead = 0;
        MemWrite = 0;
        Branch = 0;
        ALU_Control = 4'b0000;
        Reg1Address = instruction[19:15];
        Reg2Address = instruction[24:20];
        WriteRegAddress = instruction[11:7];
        Immediate = 32'b0;

        case (opcode)
            // R-Type Instructions: AND, ADD, SUB, OR, XOR, SRA, SLL, SLT
            7'b1110011: begin 
                RegWrite = 1;
                ALU_Src = 0; // Use register values for ALU operand
                MemWrite = 0;
                Branch = 0;
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000)
                            ALU_Control = 4'b0000; // AND
                    end
                    3'b001: begin
                        if (funct7 == 7'b0000000)
                            ALU_Control = 4'b0110; // ADD
                        else if (funct7 == 7'b0100000)
                            ALU_Control = 4'b0101; // SUB 
                    end
                    3'b111: begin
                    if (funct7 == 7'b0000000)
                        ALU_Control = 4'b0111; // SLT (Set Less Than)
                    end
                    3'b100: begin
                    if (funct7 == 7'b0000000) 
                        ALU_Control = 4'b0010; // XOR
                    end
                    3'b101: begin
                        if (funct7 == 7'b0000000)
                            ALU_Control = 4'b0011; // SRA (Arithmetic Shift Right)
                    end
                    3'b010: begin
                    if (funct7 == 7'b0000000) 
                        ALU_Control = 4'b0001; // OR
                    end
                    3'b110: begin
                    if (funct7 == 7'b0000000)
                        ALU_Control = 4'b0100; // SLL
                    end
                    3'b000: ALU_Control = 4'b0000; // AND (Redundant for clarity)
                    default: ALU_Control = 4'b0000; // Default to AND
                endcase
            end

            // I-Type Instructions: ADDI, ORI, XORI
            7'b0011111: begin
                RegWrite = 1;
                ALU_Src = 1; // Use immediate value for ALU operand
                Immediate = {{20{instruction[31]}}, instruction[31:20]}; // Sign extend immediate
                MemWrite = 0;
                Branch = 0;
                case (funct3)
                    3'b000: ALU_Control = 4'b0110; // ADDI
                    3'b001: ALU_Control = 4'b0001; // ORI
                    3'b010: ALU_Control = 4'b0010; // XORI
                    default: ALU_Control = 4'b0000;
                endcase
            end

            // Load Word (LW)
            7'b1000011: begin 
                RegWrite = 1;
                ALU_Src = 1; // Use immediate value for address calculation
                MemRead = 1;
                MemtoReg = 1; // Load result into register
                Immediate = {{20{instruction[31]}}, instruction[31:20]}; // Sign extend immediate
                MemWrite = 0;
                Branch = 0;
                case (funct3)
                    3'b010: ALU_Control = 4'b0110; // ADD for address calculation
                endcase
            end

            // Store Word (SW)
            7'b1100011: begin
                RegWrite = 0;
                ALU_Src = 1; // Use immediate value for address calculation
                Immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S-type immediate
                MemWrite = 1;
                MemRead = 0;
                Branch = 0;
                case (funct3)
                    3'b010: ALU_Control = 4'b0110; // ADD for address calculation
                endcase
            end

            // B-Type Instructions: BEQ, BLT
            7'b1101011: begin
                RegWrite = 0;
                ALU_Src = 0; // Use register value for comparison
                MemWrite = 0;
                MemRead = 0;
                Branch = 1;
                Immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8]}; // B-type immediate
                case (funct3)
                    3'b000: ALU_Control = 4'b1000; // BEQ (Subtract and check Zero)
                    3'b001: ALU_Control = 4'b1001; // BLT (Set Less Than)
                    default: ALU_Control = 4'b0000;
                endcase
            end

            // Load Upper Immediate (LUI)
            7'b0110000: begin
                RegWrite = 1;
                ALU_Src = 1; // Use immediate value for LUI
                Immediate = {instruction[31:12], 12'b0}; // LUI immediate
                MemWrite = 0;
                MemRead = 0;
                Branch = 0;
                ALU_Control = 4'b1100; // No ALU operation, pass through immediate
            end

            // Default Case
            default: begin
                RegWrite = 0;
                ALU_Src = 0;
                MemtoReg = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                ALU_Control = 4'b0000; 
                Immediate = 32'b0;
            end
        endcase
    end
endmodule




