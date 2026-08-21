// ALU.v
// 32-bit Arithmetic Logic Unit for RISC-V Execution Stage
// Control Mapping (5-bit) — MUST match ALU_Decoder.v exactly:
//   5'd0  (00000) : ADD  (Lw/Sw address, branch default)
//   5'd1  (00001) : SUB  (Beq compare)
//   5'd2  (00010) : ADD  (Jalr target = rs1 + imm)
//   5'd3  (00011) : SUB  (Bne compare)
//   5'd4  (00100) : SLT  (Blt compare)
//   5'd5  (00101) : SLT  (Bge compare)
//   5'd6  (00110) : ADD  (add / addi)
//   5'd7  (00111) : SUB  (sub)
//   5'd8  (01000) : SLL  (sll)
//   5'd9  (01001) : SLL  (slli)
//   5'd10 (01010) : SLT  (slt / slti)
//   5'd11 (01011) : XOR  (xor / xori)
//   5'd12 (01100) : SRL  (srl)
//   5'd13 (01101) : SRA  (sra)
//   5'd14 (01110) : SRL  (srli)
//   5'd15 (01111) : SRA  (srai)
//   5'd16 (10000) : OR   (or / ori)
//   5'd17 (10001) : AND  (and / andi)
//   5'd18 (10010) : ADD  (jal, unused — result comes from PC+4 instead)

module ALU (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [4:0]  Shamt,
    input  wire [4:0]  ALUControl,
    output reg  [31:0] Result,
    output wire        Zero,
    output wire        Negative,
    output wire        Carry,
    output wire        OverFlow
);

    wire [32:0] sub_ext = {1'b0, A} - {1'b0, B};

    always @(*) begin
        case (ALUControl)
            5'd0:    Result = A + B;                                     // ADD (Lw/Sw/branch default)
            5'd1:    Result = A - B;                                     // SUB (Beq)
            5'd2:    Result = A + B;                                     // ADD (Jalr)
            5'd3:    Result = A - B;                                     // SUB (Bne)
            5'd4:    Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT (Blt)
            5'd5:    Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT (Bge)
            5'd6:    Result = A + B;                                     // ADD (add/addi)
            5'd7:    Result = A - B;                                     // SUB (sub)
            5'd8:    Result = A << Shamt;                                // SLL (sll)
            5'd9:    Result = A << Shamt;                                // SLL (slli)
            5'd10:   Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT (slt/slti)
            5'd11:   Result = A ^ B;                                     // XOR (xor/xori)
            5'd12:   Result = A >> Shamt;                                // SRL (srl)
            5'd13:   Result = $signed(A) >>> Shamt;                      // SRA (sra)
            5'd14:   Result = A >> Shamt;                                // SRL (srli)
            5'd15:   Result = $signed(A) >>> Shamt;                      // SRA (srai)
            5'd16:   Result = A | B;                                     // OR (or/ori)
            5'd17:   Result = A & B;                                     // AND (and/andi)
            5'd18:   Result = A + B;                                     // ADD (jal, unused)
            default: Result = 32'h00000000;
        endcase
    end

    // is_sub
    wire is_sub = (ALUControl == 5'd1) || (ALUControl == 5'd3) ||
                  (ALUControl == 5'd7);
    wire is_add = (ALUControl == 5'd0) || (ALUControl == 5'd2) ||
                  (ALUControl == 5'd6) || (ALUControl == 5'd18);

    // Status Flags Generation
    assign Zero     = (Result == 32'h00000000);
    assign Negative = Result[31];
    assign Carry    = is_sub ? ~sub_ext[32] : sub_ext[32];

    // Overflow detection for signed ADD and SUB operations
    assign OverFlow = (is_add || is_sub) &&
                       ((A[31] ^ B[31] ^ is_sub) == 1'b0) &&
                       (Result[31] != A[31]);

endmodule