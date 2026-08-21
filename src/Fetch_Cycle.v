// Fetch Cycle - instruction fetch stage
// Includes: PC, PC_Adder, Mux_Fetch, Instruction_Memory, IF_ID_Register


module Fetch_Cycle (
    input  wire        clk,
    input  wire        RESET,       // synchronous reset, active high
    input  wire [1:0]  PCSrcE,      // 00: PC+4 | 01: PCTargetE | 10: ResultE
    input  wire [31:0] PCTargetE,   // Branch / JAL target from Execute
    input  wire [31:0] ResultE,     // JALR target (rs1+imm) from Execute
    input  wire        enableF,     // stall PC (0 = hold value)
    input  wire        enableD,     // stall IF/ID (0 = hold value)
    input  wire        clearD,      // flush IF/ID (branch misprediction)
    output wire [31:0] InstrD,
    output wire [31:0] PCD,
    output wire [31:0] PCPlus4D
);

    // Internal wires
    wire [31:0] PC_current;   // PCF
    wire [31:0] PC_plus4;     // PCPlus4F
    wire [31:0] PC_next;      // PC_next
    wire [31:0] InstrF;

    // 1. Mux to select the next PC source
    Mux_Fetch u_mux_fetch (
        .a(PC_plus4),
        .b(PCTargetE),
        .c(ResultE),
        .s(PCSrcE),
        .d(PC_next)
    );

    // 2. PC Register
    PC u_pc (
        .clk(clk),
        .RESET(RESET),
        .enableF(enableF),
        .PC_Next(PC_next),
        .PC(PC_current)
    );

    // 3. PC + 4 Adder
    PC_Adder u_pc_adder (
        .a(PC_current),
        .b(32'h00000004),
        .c(PC_plus4)
    );

    // 4. Instruction Memory
    Instruction_Memory u_instr_mem (
        .A(PC_current),
        .RD(InstrF)
    );

    // 5. IF/ID Pipeline Register
    IF_ID_Register u_if_id (
        .clk(clk),
        .RESET(RESET),
        .enableD(enableD),
        .clearD(clearD),
        .InstrF(InstrF),
        .PCF(PC_current),
        .PCPlus4F(PC_plus4),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );

endmodule