// PC Adder Module
// Adds offset (4 bytes) to current PC address

module PC_Adder (
    input wire [31:0] a,     // Current PC address
    input wire [31:0] b,     // Constant value (usually 4)
    output wire [31:0] c     // Next sequential PC address (PC + 4)
);

    assign c = a + b;

endmodule