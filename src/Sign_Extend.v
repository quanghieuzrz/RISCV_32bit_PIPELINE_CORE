// Sign_Extend.v
// ImmSrc = 00: I / JALR | 01: S | 10: B | 11: JAL

module Sign_Extend (
    input  wire [31:0] In,
    input  wire [1:0]  ImmSrc,
    output reg  [31:0] Imm_Ext
);

    always @(*) begin
        case (ImmSrc)
            2'b00: Imm_Ext = {{20{In[31]}}, In[31:20]};                          // I / JALR (12-bit immediate)
            2'b01: Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]};                // S-Type (12-bit immediate split into two parts)
            2'b10: Imm_Ext = {{20{In[31]}}, In[7], In[30:25], In[11:8], 1'b0};   // B-Type (Branch immediate, lsb forced to 0)
            2'b11: Imm_Ext = {{12{In[31]}}, In[19:12], In[20], In[30:21], 1'b0}; // JAL (20-bit immediate, lsb forced to 0)
            default: Imm_Ext = 32'h00000000;
        endcase
    end

endmodule