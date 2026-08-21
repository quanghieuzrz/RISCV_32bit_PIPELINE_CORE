// Decode_Cycle.v
// Instruction Decode stage
// Integrates: Control_Unit_Top, Register_File, Sign_Extend, ID_EX_Register
// Matches the architecture style of Fetch_Cycle.v

// Control_Unit_Top.v and ID_EX_Register.v so that those 2 modules also output/receive
// ResultSrc as 2-bit - if ResultSrc inside those 2 files remains 1-bit,
// the width-mismatch error will just be pushed down to lower stages.


module Decode_Cycle (
    input  wire        clk,
    input  wire        RESET,      // Synchronous reset, active-high (matches Fetch_Cycle)
    input  wire        enableE,    // Stall ID/EX register (0 = hold current state)
    input  wire        clearE,     // Flush ID/EX register (used for hazards or branch mispredictions)

    // From IF/ID pipeline register
    input  wire [31:0] InstrD,
    input  wire [31:0] PCD,
    input  wire [31:0] PCPlus4D,

    // From Writeback stage, writing back to Register_File
    input  wire        RegWriteW,
    input  wire [4:0]  RDW,
    input  wire [31:0] ResultW,

    // To Execute stage outputs
    output wire        RegWriteE,
    output wire        ALUSrcE,
    output wire        MemWriteE,
    output wire [1:0]  ResultSrcE,   
    output wire        BranchE,
    output wire        JalE,
    output wire        JalrE,
    output wire [4:0]  ALUControlE,
    output wire [31:0] RD1_E,
    output wire [31:0] RD2_E,
    output wire [31:0] Imm_Ext_E,
    output wire [4:0]  RS1_E,
    output wire [4:0]  RS2_E,
    output wire [4:0]  RD_E,
    output wire [31:0] PCE,
    output wire [31:0] PCPlus4E,
    output wire [4:0]  shamtE
);

    // Internal wires for the Decode stage (combinational logic before pipeline registers)
    wire               RegWriteD, ALUSrcD, MemWriteD;
    wire [1:0]         ResultSrcD;          
    wire               BranchD, JalD, JalrD;
    wire [1:0]         ImmSrcD;
    wire [4:0]         ALUControlD;
    wire [31:0]        RD1_D, RD2_D, Imm_Ext_D;

    // 1. Control Unit
    Control_Unit_Top u_control (
        .Op(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct7(InstrD[31:25]),
        .RegWrite(RegWriteD),
        .ImmSrc(ImmSrcD),
        .ALUSrc(ALUSrcD),
        .MemWrite(MemWriteD),
        .ResultSrc(ResultSrcD),
        .Branch(BranchD),
        .Jal(JalD),
        .Jalr(JalrD),
        .ALUControl(ALUControlD)
    );

    // 2. Register File
    // Note: Register_File uses an active-low reset (rst == 1'b0 -> clear).
    // Fetch_Cycle uses an active-high RESET, so we invert it using ~RESET.
    Register_File u_rf (
        .clk(clk),
        .rst(~RESET),
        .WE3(RegWriteW),
        .WD3(ResultW),
        .A1(InstrD[19:15]),
        .A2(InstrD[24:20]),
        .A3(RDW),
        .RD1(RD1_D),
        .RD2(RD2_D)
    );

    // 3. Sign Extension (Immediate Generator)
    Sign_Extend u_sign_extend (
        .In(InstrD),
        .ImmSrc(ImmSrcD),
        .Imm_Ext(Imm_Ext_D)
    );

    // 4. ID/EX Pipeline Register
    ID_EX_Register u_id_ex (
        .clk(clk),
        .RESET(RESET),
        .enableE(enableE),
        .clearE(clearE),

        .RegWriteD(RegWriteD),
        .ALUSrcD(ALUSrcD),
        .MemWriteD(MemWriteD),
        .ResultSrcD(ResultSrcD),
        .BranchD(BranchD),
        .JalD(JalD),
        .JalrD(JalrD),
        .ALUControlD(ALUControlD),
        .RD1_D(RD1_D),
        .RD2_D(RD2_D),
        .Imm_Ext_D(Imm_Ext_D),
        .RS1_D(InstrD[19:15]),
        .RS2_D(InstrD[24:20]),
        .RD_D(InstrD[11:7]),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .shamtD(InstrD[24:20]),   // Shift amount occupies the same bit fields as rs2

        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .JalE(JalE),
        .JalrE(JalrE),
        .ALUControlE(ALUControlE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RS1_E(RS1_E),
        .RS2_E(RS2_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .shamtE(shamtE)
    );

endmodule