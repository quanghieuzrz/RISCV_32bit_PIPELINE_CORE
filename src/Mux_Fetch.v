// Mux_Fetch Module
// 3-to-1 Multiplexer used to determine the next PC address:
// s = 2'b00: PC + 4 (Sequential execution)
// s = 2'b01: Branch Target Address
// s = 2'b10: Jump/JALR Target Address

module Mux_Fetch (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [31:0] c,
    input  wire [1:0]  s,
    output reg  [31:0] d
);
 
    always @(*) begin
        case (s)
            2'b00:   d = a;
            2'b01:   d = b;
            2'b10:   d = c;
            default: d = a;
        endcase
    end
 
endmodule