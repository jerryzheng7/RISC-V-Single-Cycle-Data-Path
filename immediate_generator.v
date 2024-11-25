

`timescale 1ns / 1ps

module ImmediateGenerator(
    input  wire [31:0] instruction,
    output reg  [31:0] immediate
    );

    always @(*) begin
        case (instruction[6:0])
            // I-Type Instructions (e.g., LW, ADDI, ORI, XORI)
            7'b1000011: // Load (LW)
                begin
                    immediate = {{20{instruction[31]}}, instruction[31:20]};
                end            
            7'b0011111: // ADDI, ORI, XORI (according to the given table)
                begin
                    immediate = {{20{instruction[31]}}, instruction[31:20]};
                end
                
            // S-Type Instructions (e.g., SW)
            7'b1100011: // Store Word (SW)
                begin
                    immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                end
            
            // B-Type Instructions (e.g., BEQ, BLT)
            7'b1101011: // Branch (BEQ, BLT)
                begin
                    immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
                end
            
            // U-Type Instructions (e.g., LUI)
            7'b0110000: // LUI
                begin
//                    immediate = {{12{instruction[31]}}, instruction[31:12], 12'b0};
                    immediate = { instruction[31:12], 12'b0};
                end
            
  

            // R-Type Instructions: AND, ADD, SUB, OR, XOR, SRA, SLL, SLT
            7'b1110011: // R-Type (AND, ADD, SUB, etc. as per the provided table)
                begin
                    // R-Type instructions do not use the immediate field
                    immediate = 32'b0;
                end

            default: begin
                immediate = 32'd0; // Default value for unsupported opcodes
            end
        endcase
    end

endmodule

