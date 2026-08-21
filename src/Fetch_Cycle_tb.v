module tb ();
 
    reg         clk;
    reg         RESET;
    reg  [1:0]  PCSrcE;
    reg  [31:0] PCTargetE;
    reg  [31:0] ResultE;
    reg         enableF;
    reg         enableD;
    reg         clearD;
 
    wire [31:0] InstrD;
    wire [31:0] PCD;
    wire [31:0] PCPlus4D;
 
    Fetch_Cycle dut (
        .clk(clk),
        .RESET(RESET),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .ResultE(ResultE),
        .enableF(enableF),
        .enableD(enableD),
        .clearD(clearD),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );
 
    // Clock 100ns period (50ns high / 50ns low)
    initial begin
        clk = 1'b0;
        forever #50 clk = ~clk;
    end
 
    // IMPORTANT: All signal modifications must be done at negedge clk,
    // NEVER change signals right at posedge clk (causes race conditions
    // - results will vary between different simulators/tools).
    initial begin
        // Initial values before the first clock edge
        RESET     = 1'b1;
        PCSrcE    = 2'b00;
        PCTargetE = 32'h00000000;
        ResultE   = 32'h00000000;
        enableF   = 1'b1;
        enableD   = 1'b1;
        clearD    = 1'b0;
 
        // 0 - 100ns : Hold reset for a full clock cycle
        @(negedge clk); // t = 50ns
        @(negedge clk); // t = 150ns -> Release reset here, stable before the next positive edge (200ns)
        RESET = 1'b0;
 
        // Run sequentially with PCSrcE = 00 for a few cycles
        @(negedge clk); // 250ns
        @(negedge clk); // 350ns
 
        // Jump to PCTargetE = 24
        PCSrcE    = 2'b01;
        PCTargetE = 32'd24;
        @(negedge clk); // 450ns
 
        // Jump to ResultE = 8
        PCSrcE  = 2'b10;
        ResultE = 32'd8;
        @(negedge clk); // 550ns
 
        // Return to PCSrcE = 00, test enableF = 0 (PC holds its value)
        PCSrcE  = 2'b00;
        enableF = 1'b0;
        @(negedge clk); // 650ns
 
        // Release enableF, resume normal operation
        enableF = 1'b1;
        @(negedge clk); // 750ns
 
        // Test enableD = 0 (IF/ID holds its value)
        enableD = 1'b0;
        @(negedge clk); // 850ns
 
        // Release enableD, test clearD = 1 (flush IF/ID)
        enableD = 1'b1;
        clearD  = 1'b1;
        @(negedge clk); // 950ns
 
        clearD = 1'b0;
        @(negedge clk); // 1050ns
        @(negedge clk); // 1150ns
 
        $finish;
    end
 
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end
 
endmodule