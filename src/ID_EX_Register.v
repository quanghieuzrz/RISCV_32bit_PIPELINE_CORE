// ID_EX_Register.v
// ID/EX Pipeline Register
// Matches the style of IF_ID_Register.v: Synchronous active-high RESET,
// enableE = stall (0 holds current value), clearE = flush (clears to 0)

module ID_EX_Register (
    input  wire        clk,
    input  wire        RESET,
    input  wire        enableE,
    input  wire        clearE,

    input  wire        RegWriteD,
    input  wire        ALUSrcD,
    input  wire        MemWriteD,
    input  wire [1:0]  ResultSrcD,   
    input  wire        BranchD,
    input  wire        JalD,
    input  wire        JalrD,
    input  wire [4:0]  ALUControlD,
    input  wire [31:0] RD1_D,
    input  wire [31:0] RD2_D,
    input  wire [31:0] Imm_Ext_D,
    input  wire [4:0]  RS1_D,
    input  wire [4:0]  RS2_D,
    input  wire [4:0]  RD_D,
    input  wire [31:0] PCD,
    input  wire [31:0] PCPlus4D,
    input  wire [4:0]  shamtD,

    output reg         RegWriteE,
    output reg         ALUSrcE,
    output reg         MemWriteE,
    output reg  [1:0]  ResultSrcE,   
    output reg         BranchE,
    output reg         JalE,
    output reg         JalrE,
    output reg  [4:0]  ALUControlE,
    output reg  [31:0] RD1_E,
    output reg  [31:0] RD2_E,
    output reg  [31:0] Imm_Ext_E,
    output reg  [4:0]  RS1_E,
    output reg  [4:0]  RS2_E,
    output reg  [4:0]  RD_E,
    output reg  [31:0] PCE,
    output reg  [31:0] PCPlus4E,
    output reg  [4:0]  shamtE
);

    always @(posedge clk) begin
        if (RESET || clearE) begin
            RegWriteE   <= 1'b0;
            ALUSrcE     <= 1'b0;
            MemWriteE   <= 1'b0;
            ResultSrcE  <= 2'b00;
            BranchE     <= 1'b0;
            JalE        <= 1'b0;
            JalrE       <= 1'b0;
            ALUControlE <= 5'b00000;
            RD1_E       <= 32'h00000000;
            RD2_E       <= 32'h00000000;
            Imm_Ext_E   <= 32'h00000000;
            RS1_E       <= 5'h00;
            RS2_E       <= 5'h00;
            RD_E        <= 5'h00;
            PCE         <= 32'h00000000;
            PCPlus4E    <= 32'h00000000;
            shamtE      <= 5'h00;
        end
        else if (enableE) begin
            RegWriteE   <= RegWriteD;
            ALUSrcE     <= ALUSrcD;
            MemWriteE   <= MemWriteD;
            ResultSrcE  <= ResultSrcD;
            BranchE     <= BranchD;
            JalE        <= JalD;
            JalrE       <= JalrD;
            ALUControlE <= ALUControlD;
            RD1_E       <= RD1_D;
            RD2_E       <= RD2_D;
            Imm_Ext_E   <= Imm_Ext_D;
            RS1_E       <= RS1_D;
            RS2_E       <= RS2_D;
            RD_E        <= RD_D;
            PCE         <= PCD;
            PCPlus4E    <= PCPlus4D;
            shamtE      <= shamtD;
        end
        // else: enableE = 0 -> stall, holds current registered values
    end

endmodule