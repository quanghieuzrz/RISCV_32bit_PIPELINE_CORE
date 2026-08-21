// ALU_Decoder.v
// ALUControl [4:0] is determined by ALUOp, funct3, and {op[5], funct7[5], op[2]}

module ALU_Decoder (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    input  wire [6:0] op,
    output reg  [4:0] ALUControl
);

    // combo = {op[5], funct7[5], op[2]}
    wire [2:0] combo = {op[5], funct7[5], op[2]};

    always @(*) begin
        case (ALUOp)

            2'b00: ALUControl = 5'b00000; // Lw, Sw

            2'b01: begin // Branch group
                case (funct3)
                    3'b000: ALUControl = op[2] ? 5'b00010 : 5'b00001; // op[2]=1: Jalr | op[2]=0: Beq
                    3'b001: ALUControl = 5'b00011; // Bne
                    3'b100: ALUControl = 5'b00100; // Blt
                    3'b101: ALUControl = 5'b00101; // Bge
                    default: ALUControl = 5'b00000;
                endcase
            end

            2'b10: begin // Arithmetic / Logic group
                case (funct3)
                    3'b000: ALUControl = (combo == 3'b110) ? 5'b00111 : 5'b00110; // Sub : Add-Addi
                    3'b001: ALUControl = op[5] ? 5'b01000 : 5'b01001;             // Sll : Slli
                    3'b010: ALUControl = 5'b01010; // Slt-Slti
                    3'b100: ALUControl = 5'b01011; // Xor-Xori
                    3'b101: begin
                        case (combo)
                            3'b100:  ALUControl = 5'b01100; // Srl
                            3'b110:  ALUControl = 5'b01101; // Sra
                            3'b000:  ALUControl = 5'b01110; // Srli
                            3'b010:  ALUControl = 5'b01111; // Srai
                            default: ALUControl = 5'b00000;
                        endcase
                    end
                    3'b110: ALUControl = 5'b10000; // Or-Ori
                    3'b111: ALUControl = 5'b10001; // And-Andi
                    default: ALUControl = 5'b00000;
                endcase
            end

            2'b11: ALUControl = 5'b10010; // Jal

            default: ALUControl = 5'b00000;
        endcase
    end

endmodule