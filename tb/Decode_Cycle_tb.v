module tb ();

    reg         clk;
    reg         RESET;
    reg         enableE;
    reg         clearE;

    reg  [31:0] InstrD;
    reg  [31:0] PCD;
    reg  [31:0] PCPlus4D;

    reg         RegWriteW;
    reg  [4:0]  RDW;
    reg  [31:0] ResultW;

    wire        RegWriteE, ALUSrcE, MemWriteE;
    wire [1:0]  ResultSrcE;
    wire        BranchE, JalE, JalrE;
    wire [4:0]  ALUControlE;
    wire [31:0] RD1_E, RD2_E, Imm_Ext_E;
    wire [4:0]  RS1_E, RS2_E, RD_E;
    wire [31:0] PCE, PCPlus4E;
    wire [4:0]  shamtE;

    Decode_Cycle dut (
        .clk(clk),
        .RESET(RESET),
        .enableE(enableE),
        .clearE(clearE),
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

    // Clock 100ns period (50ns high / 50ns low)
    initial begin
        clk = 1'b0;
        forever #50 clk = ~clk;
    end

    // Task to write directly into the Register_File via the Writeback port,
    // used to preload sample values into x2..x12 before decoding
    task write_reg(input [4:0] addr, input [31:0] data);
        begin
            RegWriteW = 1'b1;
            RDW       = addr;
            ResultW   = data;
            @(negedge clk);
            RegWriteW = 1'b0;
        end
    endtask

    // IMPORTANT: change signals at negedge clk, not immediately after posedge
    initial begin
        // Initial values
        RESET     = 1'b1;
        enableE   = 1'b1;
        clearE    = 1'b0;
        InstrD    = 32'h00000000;
        PCD       = 32'h00000000;
        PCPlus4D  = 32'h00000004;
        RegWriteW = 1'b0;
        RDW       = 5'h00;
        ResultW   = 32'h00000000;

        // 0 - 300ns: hold RESET for 3 cycles
        @(negedge clk); // 50ns
        @(negedge clk); // 150ns

        // Preload values for registers to be used in the test
        // (Register_File can still write even when RESET=1, it only affects RD1/RD2 outputs)
        write_reg(5'd2,  32'd2);
        write_reg(5'd3,  32'd3);
        write_reg(5'd4,  32'd4);
        write_reg(5'd5,  32'd5);
        write_reg(5'd8,  32'd8);
        write_reg(5'd9,  32'd9);
        write_reg(5'd12, 32'd15);

        @(negedge clk); // exiting reset, preparing to release RESET on the clock edge
        RESET = 1'b0;

        // 300 - 400ns: R-type  add x8, x4, x5
        InstrD   = 32'h00520433;
        PCD      = 32'd300;
        PCPlus4D = 32'd304;
        @(negedge clk);

        // 400 - 500ns: I-type  addi x12, x8, 6
        InstrD   = 32'h00640613;
        PCD      = 32'd400;
        PCPlus4D = 32'd404;
        @(negedge clk);

        // 500 - 600ns: Load  lw x10, 6(x3)
        InstrD   = 32'h0061a503;
        PCD      = 32'd500;
        PCPlus4D = 32'd504;
        @(negedge clk);

        // 600 - 700ns: Store  sw x12, 4(x2)
        InstrD   = 32'h00c12223;
        PCD      = 32'd600;
        PCPlus4D = 32'd604;
        @(negedge clk);

        // 700 - 800ns: Branch  beq x8, x9, 8
        InstrD   = 32'h00940463;
        PCD      = 32'd700;
        PCPlus4D = 32'd704;
        @(negedge clk);

        // 800 - 900ns: Shift immediate  slli x6, x12, 3
        InstrD   = 32'h00361313;
        PCD      = 32'd800;
        PCPlus4D = 32'd804;
        @(negedge clk);

        // 900 - 1000ns: assert clearE to test ID/EX flush
        clearE   = 1'b1;
        InstrD   = 32'h00000000;
        @(negedge clk);
        clearE   = 1'b0;

        // 1000 - 1100ns: test another R-type instruction  sub x11, x5, x10
        InstrD   = 32'h40a355b3;
        PCD      = 32'd1000;
        PCPlus4D = 32'd1004;
        @(negedge clk);

        // 1100 - 1200ns: test enableE = 0 (ID/EX holds current values)
        enableE  = 1'b0;
        InstrD   = 32'h00000013; // nop
        @(negedge clk);

        enableE  = 1'b1;
        @(negedge clk);
        @(negedge clk);

        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

endmodule