`timescale 1ns/1ps

module tb();

    // ── Clock & Reset ──────────────────────────────────────────────────────
    reg clk = 0, rst;

    always #50 clk = ~clk;   // 100ns period = 10MHz

    // ── DUT ───────────────────────────────────────────────────────────────
    Pipeline_Top dut (
        .clk  (clk),
        .RESET(~rst)    // active-low rst input -> active-high RESET output
    );

    // ── VCD dump ──────────────────────────────────────────────────────────
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

    // ── Instruction Memory + Register File + Data Memory Initialization ─────
    integer k;
    initial begin

        // --- Instruction Memory ---
        for (k = 0; k < 64; k = k + 1)
            dut.Fetch.u_instr_mem.mem[k] = 32'h00000013; // NOP

        dut.Fetch.u_instr_mem.mem[0]  = 32'h007474B3; // and  x9,  x8, x7
        dut.Fetch.u_instr_mem.mem[1]  = 32'h00036BB3; // or   x23, x6, x0
        dut.Fetch.u_instr_mem.mem[2]  = 32'h00520433; // add  x8,  x4, x5
        dut.Fetch.u_instr_mem.mem[3]  = 32'h409381B3; // sub  x3,  x7, x9
        dut.Fetch.u_instr_mem.mem[4]  = 32'h00431133; // sll  x2,  x6, x4
        dut.Fetch.u_instr_mem.mem[5]  = 32'h00942333; // slt  x6,  x8, x9
        dut.Fetch.u_instr_mem.mem[6]  = 32'h00630513; // addi x10, x6, 6
        dut.Fetch.u_instr_mem.mem[7]  = 32'h00736613; // ori  x12, x6, 7
        dut.Fetch.u_instr_mem.mem[8]  = 32'h0061A503; // lw   x10, 6(x3)
        dut.Fetch.u_instr_mem.mem[9]  = 32'h00950693; // addi x13, x10, 9
        dut.Fetch.u_instr_mem.mem[10] = 32'h00C12223; // sw   x12, 4(x2)
        dut.Fetch.u_instr_mem.mem[11] = 32'h00940C63; // beq  x8, x9, +24 (not taken: x8=9 != x9=0)
        dut.Fetch.u_instr_mem.mem[12] = 32'h00165A63; // bge  x12, x1, +20 (taken: x12=7 >= x1=1 -> addr 68 = mem[17])
        dut.Fetch.u_instr_mem.mem[13] = 32'h00100213; // addi x4,  x0, 1
        dut.Fetch.u_instr_mem.mem[14] = 32'h00118293; // addi x5,  x3, 1
        dut.Fetch.u_instr_mem.mem[15] = 32'h00329593; // slli x11, x5, 3
        dut.Fetch.u_instr_mem.mem[16] = 32'h00265A13; // srli x20, x12, 2
        dut.Fetch.u_instr_mem.mem[17] = 32'h00130493; // addi x9,  x6, 1   <- label target (addr=68)
        dut.Fetch.u_instr_mem.mem[18] = 32'h034000E7; // jalr x1,  x0, 52  (jump to addr=52=mem[13])
        dut.Fetch.u_instr_mem.mem[19] = 32'h007474B3; // and  x9,  x8, x7
        dut.Fetch.u_instr_mem.mem[20] = 32'h00637B93; // andi x23, x6, 6
        dut.Fetch.u_instr_mem.mem[21] = 32'h00000013; // NOP padding
        dut.Fetch.u_instr_mem.mem[22] = 32'h00000013;
        dut.Fetch.u_instr_mem.mem[23] = 32'h00000013;

        // --- Register File: Register[i] = 32'd{i} ---
        for (k = 0; k < 32; k = k + 1)
            dut.Decode.u_rf.Register[k] = k;
        dut.Decode.u_rf.Register[0] = 32'd0; // x0 is always 0

        // --- Data Memory: according to document diagram ---
        dut.Memory.dmem.mem[0]  = 32'h00000420;
        dut.Memory.dmem.mem[1]  = 32'h00050001;
        dut.Memory.dmem.mem[2]  = 32'd13;
        dut.Memory.dmem.mem[3]  = 32'h08000003;
        dut.Memory.dmem.mem[4]  = 32'h00000004;
        dut.Memory.dmem.mem[5]  = 32'h10000005;
        dut.Memory.dmem.mem[6]  = 32'h00000006;
        dut.Memory.dmem.mem[7]  = 32'h00000007;
        dut.Memory.dmem.mem[8]  = 32'h00000008;
        dut.Memory.dmem.mem[9]  = 32'h00000009; // lw x10,6(x3): addr=x3+6=3+6=9 byte -> word[2]=mem[2] or byte-addr/4
        dut.Memory.dmem.mem[10] = 32'h0000000a;
        dut.Memory.dmem.mem[11] = 32'h0000000b;
        dut.Memory.dmem.mem[12] = 32'h0000000c;
        dut.Memory.dmem.mem[13] = 32'h0000000d;
        dut.Memory.dmem.mem[14] = 32'h0000000e;
        dut.Memory.dmem.mem[15] = 32'h0000000f;
        dut.Memory.dmem.mem[16] = 32'h00000010;
        dut.Memory.dmem.mem[17] = 32'h08000003;
        dut.Memory.dmem.mem[18] = 32'h00000004;
        dut.Memory.dmem.mem[19] = 32'h10000005;
        dut.Memory.dmem.mem[20] = 32'h00000006;
        dut.Memory.dmem.mem[21] = 32'h00000007;
        dut.Memory.dmem.mem[22] = 32'h00000008;
        dut.Memory.dmem.mem[23] = 32'h00000009;
        dut.Memory.dmem.mem[24] = 32'h0000000a;
        dut.Memory.dmem.mem[25] = 32'h0000000b;
        dut.Memory.dmem.mem[26] = 32'h0000000c;
        dut.Memory.dmem.mem[27] = 32'h0000000d;
        dut.Memory.dmem.mem[28] = 32'h0000000e;
        dut.Memory.dmem.mem[29] = 32'h0000000f;
        dut.Memory.dmem.mem[30] = 32'h00000010;
    end

    // ── Task: print pipeline state ─────────────────────────────────────────
    task print_state;
        input integer cyc;
        begin
            $display("──────────────────────────── Cycle %0d | %0t ns", cyc, $time/1000);
            $display("  [IF] PC=%0d  Instr=0x%08h",
                dut.Fetch.u_pc.PC,
                dut.Fetch.u_instr_mem.RD);
            $display("  [ID] ALUCtrl=%0d RS1D=%0d RS2D=%0d RDD=%0d RD1D=%0d RD2D=%0d RegWrite=%b ALUSrc=%b Branch=%b Jal=%b Jalr=%b MemtoReg=%b",
                dut.Decode.u_control.ALUControl,
                dut.InstrD[19:15], dut.InstrD[24:20], dut.InstrD[11:7],
                dut.Decode.u_rf.RD1, dut.Decode.u_rf.RD2,
                dut.Decode.u_control.RegWrite,
                dut.Decode.u_control.ALUSrc,
                dut.Decode.u_control.Branch,
                dut.Decode.u_control.Jal,
                dut.Decode.u_control.Jalr,
                dut.MemtoRegE);
            $display("  [EX] SrcA=%0d SrcB=%0d ResultE=%0d PCTarget=%0d PCSrc=%0d Zero=%b FwdA=%0d FwdB=%0d",
                dut.Execute.Src_A,
                dut.Execute.Src_B,
                dut.Execute.ResultE,
                dut.PCTargetE,
                dut.PCSrcE,
                dut.Execute.ZeroE,
                dut.ForwardAE,
                dut.ForwardBE);
            $display("  [MA] ALUResM=%0d WriteDataM=%0d ReadDataM=%0d MemWrite=%b",
                dut.ALU_ResultM,
                dut.WriteDataM,
                dut.Memory.dmem.RD,
                dut.MemWriteM);
            $display("  [WB] ResultSrcW=%0d ResultW=%0d RegWrite=%b RDW=%0d",
                dut.ResultSrcW,
                dut.WriteBack.ResultW,
                dut.RegWriteW,
                dut.RDW);
            $display("  [HU] StallF=%b StallD=%b FlushD=%b FlushE=%b",
                dut.StallF, dut.StallD, dut.FlushD, dut.FlushE);
        end
    endtask

    // ── Task: check register values ─────────────────────────────────────────
    task check_reg;
        input [4:0]   idx;
        input [31:0]  exp;
        input [127:0] name;
        begin
            if (dut.Decode.u_rf.Register[idx] === exp)
                $display("  PASS | x%-2d = %0d", idx, exp);
            else
                $display("  FAIL | x%-2d expected=%0d got=%0d — %s",
                    idx, exp, dut.Decode.u_rf.Register[idx], name);
        end
    endtask

    // ── Main ─────────────────────────────────────────────────────────────
    integer cyc;
    initial begin
        rst = 1'b0;
        #200;
        rst = 1'b1;

        $display("==========================================================");
        $display("  RISC-V Pipeline — Table 4.1 Testbench");
        $display("==========================================================");

        for (cyc = 0; cyc < 35; cyc = cyc + 1) begin
            @(posedge clk); #1;
            print_state(cyc);
        end

        repeat(5) @(posedge clk); #1;

        $display("");
        $display("==========================================================");
        $display("  Register Check Results");
        $display("==========================================================");

        // R-type
        check_reg(23, 32'd6,  "or  x23,x6,x0 = 6|0 = 6");
        check_reg(8,  32'd9,  "add x8,x4,x5 = 4+5 = 9");
        check_reg(3,  32'd7,  "sub x3,x7,x9 = 7-0 = 7");
        check_reg(2,  32'd96, "sll x2,x6,x4 = 6<<4 = 96");
        check_reg(6,  32'd0,  "slt x6,x8,x9 = 9<0? = 0");

        // I-type + Load/Store
        check_reg(12, 32'd7,   "ori x12,x6,7 = 0|7 = 7");
        // lw x10,6(x3): byte addr = x3+6 = 7+6 = 13 -> word[13>>2]=word[3] = 0x08000003
        // addi x13,x10,9 => x13 = 0x08000003 + 9 = 0x0800000C = 134217740
        check_reg(13, 32'd134217740, "addi x13,x10,9 = 0x08000003 + 9 = 0x0800000C");

        // Branch taken -> label
        check_reg(9,  32'd1,  "x9 final = 1 (overwritten by addi x9,x6,1)");

        // JALR: x1 = PC+4 = 72+4 = 76
        check_reg(1,  32'd76, "jalr x1,x0,52: x1=PC+4=76");

        $display("==========================================================");
        $display("  Simulation DONE");
        $display("==========================================================");
        $finish;
    end

endmodule