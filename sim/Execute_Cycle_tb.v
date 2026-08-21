module tb_execute ();

    reg         clk;
    reg         RESET;

    // Control signals from ID/EX
    reg         RegWriteE;
    reg         MemWriteE;
    reg         ALUSrcE;
    reg  [1:0]  ResultSrcE;
    reg         BranchE;
    reg         JalE;
    reg         JalrE;
    reg  [4:0]  ALUControlE;

    // Data from ID/EX
    reg  [31:0] RD1E;
    reg  [31:0] RD2E;
    reg  [31:0] Imm_Ext_E;
    reg  [4:0]  ShamtE;
    reg  [4:0]  RDE;
    reg  [31:0] PCE;
    reg  [31:0] PCPlus4E;

    // Forwarding
    reg  [1:0]  ForwardAE;
    reg  [1:0]  ForwardBE;
    reg  [31:0] ResultW;
    reg  [31:0] ALU_ResultM;

    // Outputs
    wire [1:0]  PCSrcE;
    wire [31:0] PCTargetE;
    wire [31:0] ResultE;
    wire        RegWriteM;
    wire        MemWriteM;
    wire [1:0]  ResultSrcM;
    wire [4:0]  RDM;
    wire [31:0] PCPlus4M;
    wire [31:0] WriteDataM;
    wire [31:0] ALU_ResultM_out;

    Execute_Cycle dut (
        .clk            (clk),
        .RESET          (RESET),
        .RegWriteE      (RegWriteE),
        .MemWriteE      (MemWriteE),
        .ALUSrcE        (ALUSrcE),
        .ResultSrcE     (ResultSrcE),
        .BranchE        (BranchE),
        .JalE           (JalE),
        .JalrE          (JalrE),
        .ALUControlE    (ALUControlE),
        .RD1E           (RD1E),
        .RD2E           (RD2E),
        .Imm_Ext_E      (Imm_Ext_E),
        .ShamtE         (ShamtE),
        .RDE            (RDE),
        .PCE            (PCE),
        .PCPlus4E       (PCPlus4E),
        .ForwardAE      (ForwardAE),
        .ForwardBE      (ForwardBE),
        .ResultW        (ResultW),
        .ALU_ResultM    (ALU_ResultM),
        .PCSrcE         (PCSrcE),
        .PCTargetE      (PCTargetE),
        .ResultE        (ResultE),
        .RegWriteM      (RegWriteM),
        .MemWriteM      (MemWriteM),
        .ResultSrcM     (ResultSrcM),
        .RDM            (RDM),
        .PCPlus4M       (PCPlus4M),
        .WriteDataM     (WriteDataM),
        .ALU_ResultM_out(ALU_ResultM_out)
    );

    // Clock 100ns period (50ns high / 50ns low)
    initial begin
        clk = 1'b0;
        forever #50 clk = ~clk;
    end

    // IMPORTANT: change signals at negedge clk to avoid race conditions
    initial begin
        // Default / reset values
        RESET       = 1'b1;
        RegWriteE   = 1'b0;
        MemWriteE   = 1'b0;
        ALUSrcE     = 1'b0;
        ResultSrcE  = 2'b00;
        BranchE     = 1'b0;
        JalE        = 1'b0;
        JalrE       = 1'b0;
        ALUControlE = 5'b00000;
        RD1E        = 32'h00000000;
        RD2E        = 32'h00000000;
        Imm_Ext_E   = 32'h00000000;
        ShamtE      = 5'h00;
        RDE         = 5'h00;
        PCE         = 32'h00000000;
        PCPlus4E    = 32'h00000000;
        ForwardAE   = 2'b00;
        ForwardBE   = 2'b00;
        ResultW     = 32'h00000000;
        ALU_ResultM = 32'h00000000;

        // 0 - 400ns : hold RESET for 4 clock cycles, check every output = 0
        @(negedge clk); // 50ns
        @(negedge clk); // 150ns
        @(negedge clk); // 250ns
        @(negedge clk); // 350ns
        RESET = 1'b0;

        // 400 - 500ns : add x1, x2, x3  ->  ResultE = RD1E + RD2E = 2 + 3 = 5
        RegWriteE   = 1'b1;
        MemWriteE   = 1'b0;
        ALUSrcE     = 1'b0;
        ResultSrcE  = 2'b00;
        BranchE     = 1'b0;
        JalE        = 1'b0;
        JalrE       = 1'b0;
        ALUControlE = 5'd6;          // Add
        RD1E        = 32'd2;         // x2
        RD2E        = 32'd3;         // x3
        Imm_Ext_E   = 32'd0;
        ShamtE      = 5'h00;
        RDE         = 5'd1;          // rd = x1
        PCE         = 32'd0;
        PCPlus4E    = 32'd4;
        ForwardAE   = 2'b00;
        ForwardBE   = 2'b00;
        ALU_ResultM = 32'h00000000;
        @(negedge clk);

        // 500 - 600ns : addi x4, x0, 60  ->  ResultE = RD1E + Imm_Ext_E = 0 + 60 = 60
        RegWriteE   = 1'b1;
        MemWriteE   = 1'b0;
        ALUSrcE     = 1'b1;          // select Imm_Ext_E
        ResultSrcE  = 2'b00;
        ALUControlE = 5'd6;          // Add
        RD1E        = 32'd0;         // x0
        Imm_Ext_E   = 32'd60;
        RDE         = 5'd4;          // rd = x4
        PCE         = 32'd4;
        PCPlus4E    = 32'd8;
        ForwardAE   = 2'b00;
        @(negedge clk);

        // 600 - 700ns : lw x10, 8(x4)  ->  Forward RD1E from ALU_ResultM (x4 = 60)
        //               ResultE = ALU_ResultM + Imm_Ext_E = 60 + 8 = 68
        RegWriteE   = 1'b1;
        MemWriteE   = 1'b0;
        ALUSrcE     = 1'b1;
        ResultSrcE  = 2'b01;         // Data Memory
        ALUControlE = 5'd0;          // Add (address calc)
        Imm_Ext_E   = 32'd8;
        RDE         = 5'd10;         // rd = x10
        PCE         = 32'd8;
        PCPlus4E    = 32'd12;
        ForwardAE   = 2'b10;         // forward from EX/MEM (ALU_ResultM)
        ALU_ResultM = 32'd60;        // result of previous addi (x4)
        @(negedge clk);

        // 700 - 800ns : sw x12, 8(x8)  ->  RD1E = x8 = 8, RD2E = x12 = 12
        //               ResultE = RD1E + Imm_Ext_E = 8 + 8 = 16
        RegWriteE   = 1'b0;
        MemWriteE   = 1'b1;
        ALUSrcE     = 1'b1;
        ResultSrcE  = 2'b00;
        ALUControlE = 5'd0;          // Add (address calc)
        RD1E        = 32'd8;         // x8 (base address)
        RD2E        = 32'd12;        // x12 (store data)
        Imm_Ext_E   = 32'd8;
        RDE         = 5'd0;
        PCE         = 32'd12;
        PCPlus4E    = 32'd16;
        ForwardAE   = 2'b00;
        ALU_ResultM = 32'h00000000;
        @(negedge clk);

        // 800 - 900ns : slli x3, x4, 6  ->  ResultE = RD1E << ShamtE = 60 << 6 = 3840
        RegWriteE   = 1'b1;
        MemWriteE   = 1'b0;
        ALUSrcE     = 1'b1;
        ResultSrcE  = 2'b00;
        ALUControlE = 5'd9;          // Slli
        RD1E        = 32'd60;        // x4
        ShamtE      = 5'd6;
        RDE         = 5'd3;          // rd = x3
        PCE         = 32'd16;
        PCPlus4E    = 32'd20;
        ForwardAE   = 2'b00;
        @(negedge clk);

        // 900 - 1000ns : beq x5, x6, label  ->  RD1E = 5, RD2E = 6 (not equal -> ResultE = 1, no branch)
        RegWriteE   = 1'b0;
        MemWriteE   = 1'b0;
        ALUSrcE     = 1'b0;
        ResultSrcE  = 2'b00;
        BranchE     = 1'b1;
        ALUControlE = 5'd1;          // Beq compare
        RD1E        = 32'd5;         // x5
        RD2E        = 32'd6;         // x6
        Imm_Ext_E   = 32'd8;         // branch offset
        ShamtE      = 5'h00;
        RDE         = 5'd0;
        PCE         = 32'd20;
        PCPlus4E    = 32'd24;
        ForwardAE   = 2'b00;
        ForwardBE   = 2'b00;
        @(negedge clk);

        $finish;
    end

    initial begin
        $dumpfile("dump_execute.vcd");
        $dumpvars(0, tb_execute);
    end

endmodule