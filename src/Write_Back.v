// Writeback (WB) stage 
// Selects ResultW from ALUResultW / ReadDataW / PCPlus4W via ResultSrcW

module write_back (
    input  wire        RegWriteW_in,   
    input  wire [4:0]  RDW_in,  
    input  wire [31:0] ALUResultW,
    input  wire [31:0] PCPlus4W,
    input  wire [31:0] ReadDataW,
    input  wire [1:0]  ResultSrcW,   // 00: ALU | 01: Data Memory | 10: PC+4
    output wire [31:0] ResultW,
    output wire        RegWriteW,      
    output wire [4:0]  RDW
);

    // 3-to-1 Result Multiplexer instance using Mux_Fetch
    // s = 00 -> a (ALUResultW)
    // s = 01 -> b (ReadDataW)
    // s = 10 -> c (PCPlus4W)
    Mux_Fetch resultw1 (
        .a   (ALUResultW),
        .b   (ReadDataW),
        .c   (PCPlus4W),
        .s   (ResultSrcW),
        .d   (ResultW)
    );

    assign RegWriteW = RegWriteW_in; 
    assign RDW       = RDW_in;

endmodule