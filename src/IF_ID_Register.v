// IF/ID Pipeline Register
// RESET   : clears all 3 outputs to 0 (highest priority)
// clearD  : flush - clears to 0 (used for branch misprediction / bubble)
// enableD = 0 : stall - holds the current value (used for load-use hazard)
// enableD = 1 : updates normally with InstrF / PCF / PCPlus4F
 
module IF_ID_Register (
    input  wire        clk,
    input  wire        RESET,
    input  wire        enableD,
    input  wire        clearD,
    input  wire [31:0] InstrF,
    input  wire [31:0] PCF,
    input  wire [31:0] PCPlus4F,
    output reg  [31:0] InstrD,
    output reg  [31:0] PCD,
    output reg  [31:0] PCPlus4D
);
 
    always @(posedge clk) begin
        if (RESET || clearD) begin
            InstrD   <= 32'h00000000;
            PCD      <= 32'h00000000;
            PCPlus4D <= 32'h00000000;
        end
        else if (enableD) begin
            InstrD   <= InstrF;
            PCD      <= PCF;
            PCPlus4D <= PCPlus4F;
        end
        // enableD == 0 -> hold current value (stall)
    end
 
endmodule