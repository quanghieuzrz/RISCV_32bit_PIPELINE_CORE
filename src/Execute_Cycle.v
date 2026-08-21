// Execute_Cycle.v
// Execution Stage for RISC-V 5-Stage Pipeline Core
// Includes Forwarding Muxes, ALU, Target Adder, PCSrc Logic, and EX/MEM Pipeline Register

module Execute_Cycle (
    input  wire        clk,
    input  wire        RESET,            // Synchronous reset, active-high

    // Control signals from ID/EX pipeline register
    input  wire        RegWriteE,
    input  wire        MemWriteE,
    input  wire        ALUSrcE,          // 0: Src_B_fwd | 1: Imm_Ext_E
    input  wire [1:0]  ResultSrcE,       // 00: ALU | 01: Data Memory | 10: PC+4
    input  wire        BranchE,
    input  wire        JalE,
    input  wire        JalrE,
    input  wire [4:0]  ALUControlE,

    // Data inputs from ID/EX pipeline register
    input  wire [31:0] RD1E,
    input  wire [31:0] RD2E,
    input  wire [31:0] Imm_Ext_E,
    input  wire [4:0]  ShamtE,
    input  wire [4:0]  RDE,
    input  wire [31:0] PCE,
    input  wire [31:0] PCPlus4E,

    // Forwarding inputs
    input  wire [1:0]  ForwardAE,        // 00: RD1E | 01: ResultW | 10: ALU_ResultM
    input  wire [1:0]  ForwardBE,        // 00: RD2E | 01: ResultW | 10: ALU_ResultM
    input  wire [31:0] ResultW,          // Forwarded data from Writeback (WB) stage
    input  wire [31:0] ALU_ResultM,      // Forwarded data from Memory (MEM) stage

    // Outputs to Fetch stage
    output wire [1:0]  PCSrcE,
    output wire [31:0] PCTargetE,
    output wire [31:0] ResultE,          // ALU Result, used as JALR target address

    // Outputs to Memory stage (via EX/MEM pipeline register)
    output wire        RegWriteM,
    output wire        MemWriteM,
    output wire [1:0]  ResultSrcM,
    output wire [4:0]  RDM,
    output wire [31:0] PCPlus4M,
    output wire [31:0] WriteDataM,
    output wire [31:0] ALU_ResultM_out
);

    // Internal wires
    wire [31:0] Src_A, Src_B_fwd, Src_B;
    wire        ZeroE;
    wire [31:0] ALUResultE;  

    // EX/MEM pipeline registers
    reg         RegWriteE_r, MemWriteE_r;
    reg  [1:0]  ResultSrcE_r;
    reg  [4:0]  RDE_r;
    reg  [31:0] PCPlus4E_r, WriteDataE_r, ResultE_r;

    // 1. Forwarding Multiplexers for Src_A and Src_B
    Mux_Fetch srca_mux (
        .a(RD1E),
        .b(ResultW),
        .c(ALU_ResultM),
        .s(ForwardAE),
        .d(Src_A)
    );

    Mux_Fetch srcb_mux (
        .a(RD2E),
        .b(ResultW),
        .c(ALU_ResultM),
        .s(ForwardBE),
        .d(Src_B_fwd)
    );

    // 2. ALU Source Multiplexer (Selects between forwarded Src_B and Immediate)
    Mux_Fetch alu_src_mux (
        .a(Src_B_fwd),
        .b(Imm_Ext_E),
        .c(32'h00000000),      // Unused port
        .s({1'b0, ALUSrcE}),
        .d(Src_B)
    );

    // 3. Arithmetic Logic Unit (ALU)
    ALU u_alu (
        .A(Src_A),
        .B(Src_B),
        .Shamt(ShamtE),
        .ALUControl(ALUControlE),
        .Result(ALUResultE),
        .Zero(ZeroE),
        .Negative(),
        .Carry(),
        .OverFlow()
    );
    
    assign ResultE = JalrE ? {ALUResultE[31:1], 1'b0} : ALUResultE;

    // 4. Target Address Adder for Branch and JAL (PCE + Imm_Ext_E)
    PC_Adder branch_adder (
        .a(PCE),
        .b(Imm_Ext_E),
        .c(PCTargetE)
    );

    // 5. Next PC Selection Logic (PCSrcE)
    // 2'b10: JALR target address (ResultE = rs1 + imm from ALU)
    // 2'b01: Branch taken (BranchE & ZeroE) or JAL target address (PCTargetE)
    // 2'b00: Normal sequential PC (PC + 4)
    assign PCSrcE = JalrE                      ? 2'b10 :
                    (JalE | (BranchE & ZeroE)) ? 2'b01 :
                    2'b00;

    // 6. EX/MEM Pipeline Register Update
    always @(posedge clk) begin
        if (RESET) begin
            RegWriteE_r  <= 1'b0;
            MemWriteE_r  <= 1'b0;
            ResultSrcE_r <= 2'b00;
            RDE_r        <= 5'h00;
            PCPlus4E_r   <= 32'h00000000;
            WriteDataE_r <= 32'h00000000;
            ResultE_r    <= 32'h00000000;
        end
        else begin
            RegWriteE_r  <= RegWriteE;
            MemWriteE_r  <= MemWriteE;
            ResultSrcE_r <= ResultSrcE;
            RDE_r        <= RDE;
            PCPlus4E_r   <= PCPlus4E;
            WriteDataE_r <= Src_B_fwd;     // Forwarded rs2 value, used for Store instructions
            ResultE_r    <= ResultE;
        end
    end

    // 7. Assign outputs to MEM stage
    assign RegWriteM       = RegWriteE_r;
    assign MemWriteM       = MemWriteE_r;
    assign ResultSrcM      = ResultSrcE_r;
    assign RDM             = RDE_r;
    assign PCPlus4M        = PCPlus4E_r;
    assign WriteDataM      = WriteDataE_r;
    assign ALU_ResultM_out = ResultE_r;

endmodule