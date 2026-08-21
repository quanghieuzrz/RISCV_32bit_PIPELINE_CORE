// Hazard_Unit.v
// Hazard processing unit 

module Hazard_Unit (
    input  wire        MemtoRegE,   // 1 = instruction currently in Execute is a Load
    input  wire [4:0]  RS1D,
    input  wire [4:0]  RDE,
    input  wire [4:0]  RS2D,
    input  wire [1:0]  PCSrcE,
    input  wire [4:0]  RS1E,
    input  wire [4:0]  RDM,
    input  wire [4:0]  RS2E,
    input  wire        RegWriteM,
    input  wire [4:0]  RDW,
    input  wire        RegWriteW,
    input  wire        RESET,

    output reg  [1:0]  ForwardAE,
    output reg  [1:0]  ForwardBE,
    output wire        StallF,
    output wire        StallD,
    output wire        FlushD,
    output wire        FlushE
);

    // ---- Forwarding for Execute (prioritize MEM stage first, then WB stage) ----
    always @(*) begin
        if (RESET) begin
            ForwardAE = 2'b00;
            ForwardBE = 2'b00;
        end
        else begin
            if (RegWriteM && (RDM != 5'h00) && (RDM == RS1E))
                ForwardAE = 2'b10;
            else if (RegWriteW && (RDW != 5'h00) && (RDW == RS1E))
                ForwardAE = 2'b01;
            else
                ForwardAE = 2'b00;

            if (RegWriteM && (RDM != 5'h00) && (RDM == RS2E))
                ForwardBE = 2'b10;
            else if (RegWriteW && (RDW != 5'h00) && (RDW == RS2E))
                ForwardBE = 2'b01;
            else
                ForwardBE = 2'b00;
        end
    end

    // ---- Load-use hazard: Load instruction in Execute, instruction in Decode needs its result ----
    wire LoadUseHazard = MemtoRegE && (RDE != 5'h00) &&
                         ((RDE == RS1D) || (RDE == RS2D));

    // ---- Branch/Jump taken in Execute -> IF and ID contain incorrect instructions ----
    wire BranchFlush = (PCSrcE != 2'b00);

    // ---- Stall: 1 = normal, 0 = hold (acts like enableF/enableD) ----
    assign StallF = RESET ? 1'b1 : LoadUseHazard;
    assign StallD = RESET ? 1'b1 : LoadUseHazard;

    // ---- Flush ----
    assign FlushD = RESET ? 1'b0 : BranchFlush;
    assign FlushE = RESET ? 1'b0 : (LoadUseHazard | BranchFlush);

endmodule