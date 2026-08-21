// Program Counter (PC) Register Module
// RESET (active high, synchronous): PC <= 0
// enableF = 0 : stall - hazard/stall
// enableF = 1 : PC <= PC_Next

module PC (
    input  wire        clk,
    input  wire        RESET,
    input  wire        enableF,
    input  wire [31:0] PC_Next,
    output reg  [31:0] PC
);

    always @(posedge clk) begin
        if (RESET)
            PC <= 32'h00000000;
        else if (enableF)
            PC <= PC_Next;
        // enableF == 0 -> giu nguyen (stall)
    end

endmodule