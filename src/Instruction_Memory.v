// Instruction Memory - reads by word, A is the byte address
// Therefore it must be divided by 4 (A >> 2) when indexing the mem[] array
//   address 4  -> 32'h409381b3
//   address 8  -> 32'h00621133
//   address 12 -> 32'h008200e7
//   address 24 -> 32'h40a355b3
// All remaining locations are filled with NOP (addi x0, x0, 0)
 
module Instruction_Memory (
    input  wire [31:0] A,
    output wire [31:0] RD
);
 
    reg [31:0] mem [0:63];
    integer i;
 
    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'h00000013; // NOP
 
        mem[1] = 32'h409381b3; // address 4
        mem[2] = 32'h00621133; // address 8
        mem[3] = 32'h008200e7; // address 12
        mem[6] = 32'h40a355b3; // address 24
    end
 
    assign RD = mem[A[31:2]];
 
endmodule
 