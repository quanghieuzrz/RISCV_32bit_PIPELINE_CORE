// data_memory.v
// Fixed Word-Addressing Data Memory
// Used inside Memory Access stage (instance name: dm1)

module data_memory (
    input  wire        clk,
    input  wire        reset,     // Active-low reset
    input  wire        WE,        // Write enable (MemWriteM)
    input  wire [31:0] WD,        // Write data (WriteDataM)
    input  wire [31:0] A,         // Byte Address from ALU (ALUResultM)
    output wire [31:0] RD         // Read data
);

    reg [31:0] mem [0:1023];

    // Word Addressing: Convert Byte Address to Word Index (A[11:2])
    wire [9:0] word_addr = A[11:2];

    // Synchronous write
    always @(posedge clk) begin
        if (WE)
            mem[word_addr] <= WD;
    end

    // Combinational read, forced to 0 while reset is asserted (active-low)
    assign RD = (~reset) ? 32'h00000000 : mem[word_addr];

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h00000000;
    end

endmodule