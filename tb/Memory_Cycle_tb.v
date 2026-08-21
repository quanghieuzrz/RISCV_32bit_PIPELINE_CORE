module tb ();

    reg         clk;
    reg         rst;              // Active-low reset
    reg         RegWriteM;
    reg         MemWriteM;
    reg  [1:0]  ResultSrcM;
    reg  [4:0]  RD_M;
    reg  [31:0] PCPlus4M;
    reg  [31:0] WriteDataM;
    reg  [31:0] ALU_ResultM;

    wire        RegWriteW;
    wire [1:0]  ResultSrcW;
    wire [4:0]  RD_W;
    wire [31:0] PCPlus4W;
    wire [31:0] ALU_ResultW;
    wire [31:0] ReadDataW;

    memory_cycle dut (
        .clk(clk),
        .rst(rst),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .RD_W(RD_W),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW)
    );

    // Clock 100ns period (50ns high / 50ns low)
    initial begin
        clk = 1'b0;
        forever #50 clk = ~clk;
    end

    initial begin
        // 0 - 100ns: Reset active
        rst         = 1'b0;
        RegWriteM   = 1'b0;
        MemWriteM   = 1'b0;
        ResultSrcM  = 2'b00;
        RD_M        = 5'h00;
        PCPlus4M    = 32'h00000000;
        WriteDataM  = 32'h00000000;
        ALU_ResultM = 32'h00000000;

        #100;

        // 100 - 200ns: WRITE cycle (MemWriteM = 1)
        rst         = 1'b1;
        RegWriteM   = 1'b1;
        MemWriteM   = 1'b1;
        ResultSrcM  = 2'd2;
        RD_M        = 5'd7;
        PCPlus4M    = 32'd4;
        ALU_ResultM = 32'd8;          // Address = 8
        WriteDataM  = 32'hb2b2b2b2;   // Data to write

        #100;

        // 200 - 300ns: READ cycle (MemWriteM = 0)
        MemWriteM   = 1'b0;
        ALU_ResultM = 32'd8;

        #200;

        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

endmodule