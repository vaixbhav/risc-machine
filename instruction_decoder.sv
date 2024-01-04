
module instruction_decoder(
        C,
        nsel,
        opcode,
        op,
        out
);

input [15:0] C;
input [1:0] nsel;
output [2:0] opcode;
output [1:0] op;
output [41:0] out;

reg [2:0] Rm, Rd, Rn;
reg [1:0] shift;
reg [15:0] sximm8;
reg [15:0] sximm5;
reg [1:0] ALUop;
reg [2:0] readnum, writenum;
reg [41:0] out;
reg [2:0] opcode;
reg [1:0] op;


always @(*) begin
    opcode = C[15:13];
    op = C[12:11];
    ALUop = C[12:11];
    sximm8 = {{8{C[7]}}, C[7:0]};
    sximm5 = {{11{C[4]}}, C[4:0]};
    shift = C[4:3];
    Rm = C[2:0];
    Rn = C[10:8];
    Rd = C[7:5];
    writenum = nsel[1] ? (Rm) : (nsel[0] ? Rd : Rn);
    readnum = nsel[1] ? (Rm) : (nsel[0] ? Rd : Rn);
    out = {writenum, readnum, shift, sximm8, sximm5, ALUop};
end
endmodule
