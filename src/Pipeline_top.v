// Pipeline_Top.v
// Integrates 5 pipeline stages (Fetch, Decode, Execute, Memory, Writeback) + Hazard Unit

module Pipeline_Top (
    input wire clk,
    input wire RESET     // active-high, synchronous (matches Fetch/Decode/Execute)
);

    // ---- Fetch <-> Decode (IF/ID) ----
    wire [31:0] InstrD, PCD, PCPlus4D;

    // ---- Execute -> Fetch ----
    wire [1:0]  PCSrcE;
    wire [31:0] PCTargetE, ResultE;

    // ---- Decode -> Execute (ID/EX) ----
    wire        RegWriteE, ALUSrcE, MemWriteE, BranchE, JalE, JalrE;
    wire [1:0]  ResultSrcE;
    wire [4:0]  ALUControlE;
    wire [31:0] RD1_E, RD2_E, Imm_Ext_E;
    wire [4:0]  RS1_E, RS2_E, RD_E;
    wire [31:0] PCE, PCPlus4E;
    wire [4:0]  shamtE;

    // ---- Hazard Unit -> Fetch / Decode ----
    wire        StallF, StallD, FlushD, FlushE;

    // ---- Specific to Hazard Unit: rs1/rs2 of instruction in Decode, and Load in Execute ----
    wire [4:0]  RS1D = InstrD[19:15];
    wire [4:0]  RS2D = InstrD[24:20];
    wire        MemtoRegE = (ResultSrcE == 2'b01);

    // ---- Hazard Unit -> Execute (forwarding) ----
    wire [1:0]  ForwardAE, ForwardBE;

    // ---- Execute -> Memory (EX/MEM), also MEM forwarding source back to Execute ----
    wire        RegWriteM, MemWriteM;
    wire [1:0]  ResultSrcM;
    wire [4:0]  RDM;
    wire [31:0] PCPlus4M, WriteDataM, ALU_ResultM;

    // ---- Memory -> Writeback (MEM/WB) ----
    wire        RegWriteW_mem;
    wire [1:0]  ResultSrcW;
    wire [4:0]  RDW_mem;
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;

    // ---- Writeback outputs (passthrough RegWriteW/RDW + mux ResultW) ----
    wire        RegWriteW;
    wire [4:0]  RDW;
    wire [31:0] ResultW;

    // 1. Fetch
    Fetch_Cycle Fetch (
        .clk(clk),
        .RESET(RESET),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .ResultE(ResultE),
        .enableF(~StallF),
        .enableD(~StallD),
        .clearD(FlushD),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );

    // 2. Decode
    Decode_Cycle Decode (
        .clk(clk),
        .RESET(RESET),
        .enableE(1'b1),      
        .clearE(FlushE),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RegWriteW(RegWriteW),
        .RDW(RDW),
        .ResultW(ResultW),
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

    // 3. Execute
    Execute_Cycle Execute (
        .clk(clk),
        .RESET(RESET),
        .RegWriteE(RegWriteE),
        .MemWriteE(MemWriteE),
        .ALUSrcE(ALUSrcE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .JalE(JalE),
        .JalrE(JalrE),
        .ALUControlE(ALUControlE),
        .RD1E(RD1_E),
        .RD2E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .ShamtE(shamtE),
        .RDE(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .ResultW(ResultW),
        .ALU_ResultM(ALU_ResultM),       // internal forwarding loop from Execute's EX/MEM
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .ResultE(ResultE),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RDM(RDM),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM_out(ALU_ResultM)    // direct output wired to the shared wire above
    );

    // 4. Memory
    // NOTE: Memory_Cycle uses active-low "rst" (different from active-high RESET above) so it must be bitwise inverted when connected.
    memory_cycle Memory (
        .clk(clk),
        .rst(~RESET),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RDM),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .RegWriteW(RegWriteW_mem),
        .ResultSrcW(ResultSrcW),
        .RD_W(RDW_mem),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW)
    );

    // 5. Writeback
    write_back WriteBack (
        .RegWriteW_in(RegWriteW_mem),
        .RDW_in(RDW_mem),
        .ALUResultW(ALU_ResultW),
        .PCPlus4W(PCPlus4W),
        .ReadDataW(ReadDataW),
        .ResultSrcW(ResultSrcW),
        .RegWriteW(RegWriteW),
        .RDW(RDW),
        .ResultW(ResultW)
    );

    // 6. Hazard Unit (forwarding + stall + flush)
    Hazard_Unit HazardUnit (
        .MemtoRegE(MemtoRegE),
        .RS1D(RS1D),
        .RDE(RD_E),
        .RS2D(RS2D),
        .PCSrcE(PCSrcE),
        .RS1E(RS1_E),
        .RDM(RDM),
        .RS2E(RS2_E),
        .RegWriteM(RegWriteM),
        .RDW(RDW),
        .RegWriteW(RegWriteW),
        .RESET(RESET),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

endmodule