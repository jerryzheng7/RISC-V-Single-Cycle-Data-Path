`timescale 1ns / 1ps

             module Datapath(clk, rst);

    input clk, rst;
    
//----------------Program Counter----------------//
    
    wire [31:0] InstructionCountIn;
    wire [31:0] InstructionCountOut;
    
    // Instantiate Program Counter
    ProgramCounter PC (
        .clk(clk),
        .rst(rst),
        .nextPC(InstructionCountIn),
        .currentPC(InstructionCountOut)
    );

//----------------Instruction Memory----------------//    

wire [31:0] ReadInstruction;

// Instantiate the Instruction Memory
InstructionMemory #(32, 128) IMem ( // Updated parameter for REGSIZE to 128 for a larger memory
    .Address(InstructionCountOut),  // Address from the program counter
    .ReadData1(ReadInstruction)     // Instruction output
);



//----------------Control Unit----------------//

// Wire declarations
wire [4:0] ReadReg1Address, ReadReg2Address, WriteRegAddress;
wire [31:0] Immediate;
wire ALU_Src, MemtoReg, RegWrite, MemRead, MemWrite, Branch;
wire [3:0] ALU_Control;

// Instantiate Control Unit
ControlLogic CU (
    .opcode(ReadInstruction[6:0]),        // Pass opcode from instruction
    .funct3(ReadInstruction[14:12]),      // Pass funct3 from instruction
    .funct7(ReadInstruction[31:25]),      // Pass funct7 from instruction
    .instruction(ReadInstruction),        // Pass the entire instruction
    .RegWrite(RegWrite),
    .ALU_Src(ALU_Src),
    .MemtoReg(MemtoReg),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .ALU_Control(ALU_Control),
    .Reg1Address(ReadReg1Address),
    .Reg2Address(ReadReg2Address),
    .WriteRegAddress(WriteRegAddress),
    .Immediate(Immediate)
);



//----------------Immediate Generator----------------//

wire [31:0] Immediate;

// Instantiate Immediate Generator
ImmediateGenerator ImmGen (
    .instruction(ReadInstruction), // Correct input port name
    .immediate(Immediate)          // Corrected output port name to match the module's definition
);
//----------------Register File----------------//

/*
Note: the register file module has two PARAMETERS. The instantiation of the register file also
needs to set the size of the PARAMETERS; the proper format to do so is provided.
*/

wire [31:0] ReadRegData1, ReadRegData2;
wire [31:0] WriteRegData;


    Register_File #(32, 32) regfile (
        .ReadSelect1(ReadInstruction[19:15]), // rs1 field for reading register 1
        .ReadSelect2(ReadInstruction[24:20]), // rs2 field for reading register 2
        .WriteSelect(ReadInstruction[11:7]),  // rd field for writing data to register
        .WriteData(WriteRegData),             // Data to write to the register
        .WriteEnable(RegWrite),               // Enable signal for writing to the register
        .ReadData1(ReadRegData1),             // Data read from register 1
        .ReadData2(ReadRegData2),             // Data read from register 2
        .clk(clk),
        .rst(rst)
    );

//----------------ALU----------------//

// Wires for ALU inputs and output
wire [31:0] ALU1, ALU2;
wire [31:0] ALU_Out;
wire zero;

// Assign values to ALU inputs
assign ALU1 = ReadRegData1; // ALU1 is assigned to the data from the first register

// ALU2 depends on ALU_Src: choose between ReadRegData2 and Immediate value
assign ALU2 = ALU_Src ? Immediate : ReadRegData2;

// Instantiate ALU module
ALU alu_unit (
    .A(ALU1),                // First operand from register file
    .B(ALU2),                // Second operand: either immediate value or second register value
    .ALU_Control(ALU_Control), // ALU control signal from control unit
    .ALU_Out(ALU_Out),       // Output from ALU
    .zero(zero)              // Zero flag output for branch control
);



//----------------Branch Control----------------//

wire [31:0] BranchAddress;  // Calculated address to jump to if branch is taken
wire select_branch;

// Calculate the branch address (PC + immediate left-shifted by 1)
assign BranchAddress = InstructionCountOut + (Immediate << 1);

// Instantiate Branch Control Unit
BranchControl BC (
    .branch(Branch),                   // Branch signal from control unit
    .zero(zero),                       // Zero flag from ALU
    .pc_address(InstructionCountOut),  // Current PC address from Program Counter
    .branch_address(BranchAddress),    // Calculated branch address
    .next_pc(InstructionCountIn),      // Output next PC value to update Program Counter
    .branch_taken(select_branch)       // Branch taken signal for debugging/monitoring
);
//----------------Data Memory----------------//

// Wire declarations for interfacing with Data Memory
wire [31:0] ReadMemData; // Output from data memory (read data)
wire [31:0] ALU_Out;     // Assuming ALU_Out is from the ALU and used as an address
wire MemRead, MemWrite;  // Control signals from the control unit

// DataMemory Module Instantiation
DataMemory #(32, 6) DMem (
    .clk(clk),                   // Clock signal
    .MemRead(MemRead),           // Read enable from control unit
    .MemWrite(MemWrite),         // Write enable from control unit
    .address(ALU_Out[5:0]),      // Use lower 6 bits of ALU output for addressing memory
    .writeData(ReadRegData2),    // Data to be written to memory, from second register value
    .readData(ReadMemData)       // Data read from memory
);


//----------------Write Back----------------//

    // Write back data to the register file
    assign WriteRegData = MemtoReg ? ReadMemData : ALU_Out;

endmodule





