// Main_Decoder.v
// Generates control signals based on Op (InstrD[6:0])

module Main_Decoder (
    input  wire [6:0] Op,
    output reg        RegWrite,
    output reg  [1:0] ImmSrc,
    output reg        ALUSrc,
    output reg        MemWrite,
    output reg  [1:0] ResultSrc,  // (00=ALU, 01=DMem, 10=PC+4)
    output reg        Branch,
    output reg        Jal,
    output reg        Jalr,
    output reg  [1:0] ALUOp
);

    always @(*) begin
        case (Op)
            7'b0000011: begin // LW
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b1;
                MemWrite  = 1'b0;
                ResultSrc = 2'b01; 
                Branch    = 1'b0;
                Jal       = 1'b0;
                Jalr      = 1'b0;
                ALUOp     = 2'b00;
            end

            7'b0100011: begin // SW
                RegWrite  = 1'b0;
                ImmSrc    = 2'b01;
                ALUSrc    = 1'b1;
                MemWrite  = 1'b1;
                ResultSrc = 2'b00;
                Branch    = 1'b0;
                Jal       = 1'b0;
                Jalr      = 1'b0;
                ALUOp     = 2'b00;
            end

            7'b1100011: begin // B-Type
                RegWrite  = 1'b0;
                ImmSrc    = 2'b10;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                ResultSrc = 2'b00;
                Branch    = 1'b1;
                Jal       = 1'b0;
                Jalr      = 1'b0;
                ALUOp     = 2'b01;
            end

            7'b1100111: begin // JALR 
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00;  
                ALUSrc    = 1'b1;   
                MemWrite  = 1'b0;
                ResultSrc = 2'b10;  
                Branch    = 1'b0;   
                Jal       = 1'b0;   
                Jalr      = 1'b1;
                ALUOp     = 2'b00;  
            end

            7'b0010011: begin // I-Type Arithmetic
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b1;
                MemWrite  = 1'b0;
                ResultSrc = 2'b00;
                Branch    = 1'b0;
                Jal       = 1'b0;
                Jalr      = 1'b0;
                ALUOp     = 2'b10;
            end

            7'b0110011: begin // R-Type
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                ResultSrc = 2'b00;
                Branch    = 1'b0;
                Jal       = 1'b0;
                Jalr      = 1'b0;
                ALUOp     = 2'b10;
            end

            7'b1101111: begin // JAL
                RegWrite  = 1'b1;
                ImmSrc    = 2'b11;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                ResultSrc = 2'b10; 
                Branch    = 1'b0;
                Jal       = 1'b1;
                Jalr      = 1'b0;
                ALUOp     = 2'b11;
            end

            default: begin
                RegWrite  = 1'b0;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                ResultSrc = 2'b00;
                Branch    = 1'b0;
                Jal       = 1'b0;
                Jalr      = 1'b0;
                ALUOp     = 2'b00;
            end
        endcase
    end

endmodule