

module ALU (
    input [31:0] A,                // First operand
    input [31:0] B,                // Second operand
    input [3:0] ALU_Control,       // ALU operation control signal
    output reg [31:0] ALU_Out,     // Output of the ALU operation
    output reg zero                // Zero flag, high if ALU_Out is 0
);

    always @(*) begin
        // Initialize output to prevent latches
        ALU_Out = 32'b0;

        case (ALU_Control)
            4'b0000: ALU_Out = A & B;              // AND Operation
            4'b0001: ALU_Out = A | B;              // OR Operation
            4'b0010: ALU_Out = A ^ B;              // XOR Operation
            4'b0011: ALU_Out = A >>> B[4:0];       // Arithmetic Shift Right (only use lower 5 bits for shift value)
            4'b0100: ALU_Out = A << B[4:0];        // Logical Shift Left (only use lower 5 bits for shift value)
            4'b0101: ALU_Out = A - B;              // Subtract
            4'b0110: ALU_Out = A + B;              // Add
            4'b0111: ALU_Out = (A < B) ? 1 :0; // Set on Less Than (signed comparison)
            4'b1000: zero =(A==B) ? 1:0;
            4'b1001: zero =(A<B) ? 1:0; 
            4'b1100: ALU_Out = B; 
            default: ALU_Out = 32'b0;              // Default case: Output 0
        endcase

        // Set the zero flag if ALU_Out is zero
        zero = (ALU_Out == 32'b0) ? 1 : 0;
    end
endmodule



