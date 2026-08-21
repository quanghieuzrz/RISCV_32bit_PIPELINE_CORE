// Control_Unit_Top.v
// Top-level Control Unit combining Main_Decoder and ALU_Decoder

module Control_Unit_Top (
    input  wire [6:0] Op,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output wire        RegWrite,
    output wire [1:0]  ImmSrc,
    output wire        ALUSrc,
    output wire        MemWrite,
    output wire [1:0]  ResultSrc,  
    output wire        Branch,
    output wire        Jal,
    output wire        Jalr,
    output wire [4:0]  ALUControl
);
    wire [1:0] ALUOp;

    Main_Decoder u_main (
        .Op(Op),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jal(Jal),
        .Jalr(Jalr),
        .ALUOp(ALUOp)
    );

    ALU_Decoder u_alu (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .op(Op),
        .ALUControl(ALUControl)
    );

endmodule