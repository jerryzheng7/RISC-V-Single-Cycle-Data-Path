`timescale 1ns / 1ps

module BranchControl(
    input branch,                  // Branch control signal from Control Logic
    input zero,                    // Zero flag from ALU indicating if the condition for branching is true
    input [31:0] pc_address,       // Current PC address
    input [31:0] branch_address,   // Calculated branch address (PC + immediate offset)
    output reg [31:0] next_pc,     // Output to determine the next PC value
    output branch_taken            // Output branch taken signal
);

    assign branch_taken = branch & zero; // Branch taken when branch control is high and zero flag is set

    always @(*) begin
        if (branch_taken) begin
            next_pc = branch_address;  // Update the PC to branch address if branch is taken
        end else begin
            next_pc = pc_address + 32'd1;  // Default is to move to the next sequential instruction (PC + 1)
        end
    end
endmodule




