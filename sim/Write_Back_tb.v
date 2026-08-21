module tb ();

    reg  [31:0] ALUResultW;
    reg  [31:0] PCPlus4W;
    reg  [31:0] ReadDataW;
    reg  [1:0]  ResultSrcW;

    wire [31:0] ResultW;

    write_back dut (
        .ALUResultW(ALUResultW),
        .PCPlus4W(PCPlus4W),
        .ReadDataW(ReadDataW),
        .ResultSrcW(ResultSrcW),
        .ResultW(ResultW)
    );

    // Clock 100ns period (only used as a time reference on the waveform,
    // write_back is a purely combinational block)
    reg clk;
    initial begin
        clk = 1'b0;
        forever #50 clk = ~clk;
    end

    initial begin
        // Keep data inputs constant throughout, only ResultSrcW changes
        ALUResultW = 32'hc3c3c3c3;
        ReadDataW  = 32'h12341234;
        PCPlus4W   = 32'h2f2f2f2f;

        // 0 - 100ns : ResultSrcW = 00 -> ResultW = ALUResultW
        ResultSrcW = 2'd0;
        #100;

        // 100 - 200ns : ResultSrcW = 01 -> ResultW = ReadDataW
        ResultSrcW = 2'd1;
        #100;

        // 200 - 300ns : ResultSrcW = 10 -> ResultW = PCPlus4W
        ResultSrcW = 2'd2;
        #100;

        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

endmodule