`timescale 1ns/1ps

module tb();

    // ── Inputs to DUT ────────────────────────────────────────────────
    reg         RESET;
    reg         MemtoRegE;
    reg  [4:0]  RS1D;
    reg  [4:0]  RDE;
    reg  [4:0]  RS2D;
    reg  [1:0]  PCSrcE;
    reg  [4:0]  RS1E;
    reg  [4:0]  RDM;
    reg  [4:0]  RS2E;
    reg         RegWriteM;
    reg  [4:0]  RDW;
    reg         RegWriteW;

    // ── Outputs from DUT ─────────────────────────────────────────────
    wire [1:0]  ForwardAE;
    wire [1:0]  ForwardBE;
    wire        StallF;
    wire        StallD;
    wire        FlushD;
    wire        FlushE;

    // ── DUT instantiation ────────────────────────────────────────────
    Hazard_Unit dut (
        .MemtoRegE (MemtoRegE),
        .RS1D      (RS1D),
        .RDE       (RDE),
        .RS2D      (RS2D),
        .PCSrcE    (PCSrcE),
        .RS1E      (RS1E),
        .RDM       (RDM),
        .RS2E      (RS2E),
        .RegWriteM (RegWriteM),
        .RDW       (RDW),
        .RegWriteW (RegWriteW),
        .RESET     (RESET),
        .ForwardAE (ForwardAE),
        .ForwardBE (ForwardBE),
        .StallF    (StallF),
        .StallD    (StallD),
        .FlushD    (FlushD),
        .FlushE    (FlushE)
    );

    // ── VCD dump ─────────────────────────────────────────────────────
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

    // ── Task: check and print result for each signal ──────────────────
    task check_bit(input [63:0] name, input actual, input expected);
        begin
            if (actual === expected)
                $display("  PASS | %-10s = %0d", name, actual);
            else
                $display("  FAIL | %-10s expected=%0d got=%0d", name, expected, actual);
        end
    endtask

    task check_vec2(input [63:0] name, input [1:0] actual, input [1:0] expected);
        begin
            if (actual === expected)
                $display("  PASS | %-10s = %0d", name, actual);
            else
                $display("  FAIL | %-10s expected=%0d got=%0d", name, expected, actual);
        end
    endtask

    // ── Main stimulus ────────────────────────────────────────────────
    initial begin
        $display("==========================================================");
        $display("    Hazard_Unit Testbench");
        $display("==========================================================");

        // ---- 0 - 100ns : RESET ----
        RESET     = 1'b1;
        MemtoRegE = 1'b0;
        RS1D      = 5'h00;
        RDE       = 5'h00;
        RS2D      = 5'h00;
        PCSrcE    = 2'b00;
        RS1E      = 5'h00;
        RDM       = 5'h00;
        RS2E      = 5'h00;
        RegWriteM = 1'b0;
        RDW       = 5'h00;
        RegWriteW = 1'b0;
        #100;

        $display("");
        $display("[0-100ns] Check RESET:");
        check_vec2("ForwardAE", ForwardAE, 2'b00);
        check_vec2("ForwardBE", ForwardBE, 2'b00);
        check_bit ("FlushD",    FlushD,    1'b0);
        check_bit ("FlushE",    FlushE,    1'b0);
        check_bit ("StallF",    StallF,    1'b1);
        check_bit ("StallD",    StallD,    1'b1);

        // ---- 100 - 200ns : Forwarding from MEM ----
        RESET     = 1'b0;
        RDM       = 5'd9;
        RS1E      = 5'd9;
        RegWriteM = 1'b1;
        RS2E      = 5'd8;    // no match -> ForwardBE must be = 0
        RDW       = 5'd20;
        RegWriteW = 1'b0;
        #100;

        $display("");
        $display("[100-200ns] Check Forward from MEM (RDM=RS1E=9, RegWriteM=1):");
        check_vec2("ForwardAE", ForwardAE, 2'b10);
        check_vec2("ForwardBE", ForwardBE, 2'b00);

        // ---- 200 - 300ns : Forwarding from WB ----
        RegWriteM = 1'b0;
        RDM       = 5'd7;    // no longer matches RS1E -> ForwardAE must be = 0
        RS1E      = 5'd10;
        RS2E      = 5'd14;
        RDW       = 5'd14;
        RegWriteW = 1'b1;
        #100;

        $display("");
        $display("[200-300ns] Check Forward from WB (RDW=RS2E=14, RegWriteW=1):");
        check_vec2("ForwardAE", ForwardAE, 2'b00);
        check_vec2("ForwardBE", ForwardBE, 2'b01);

        // ---- 300 - 400ns : Load-use hazard ----
        RegWriteW = 1'b0;
        MemtoRegE = 1'b1;
        RDE       = 5'd12;
        RS2D      = 5'd12;
        RS1D      = 5'd7;
        PCSrcE    = 2'b00;
        #100;

        $display("");
        $display("[300-400ns] Check Load-use hazard (RS2D=RDE=12, MemtoRegE=1):");
        check_bit("StallF", StallF, 1'b0);
        check_bit("StallD", StallD, 1'b0);
        check_bit("FlushE", FlushE, 1'b1);
        check_bit("FlushD", FlushD, 1'b0);

        // ---- 400ns onwards : Branch/Jump taken ----
        MemtoRegE = 1'b0;
        RDE       = 5'd3;
        RS2D      = 5'd4;
        RS1D      = 5'd7;
        PCSrcE    = 2'b10;
        #100;

        $display("");
        $display("[400ns+] Check Branch/Jump taken (PCSrcE=2'b10):");
        check_bit("FlushD", FlushD, 1'b1);
        check_bit("FlushE", FlushE, 1'b1);
        check_bit("StallF", StallF, 1'b0);  
        check_bit("StallD", StallD, 1'b0);

        #100;
        $display("");
        $display("==========================================================");
        $display("    Simulation DONE");
        $display("==========================================================");
        $finish;
    end

endmodule