module ALU(
    input [15:0] Ain,
    input [15:0] Bin,
    input [1:0] ALUop,
    output reg [15:0] out,
    output reg [2:0] NVZ
);

    reg N;
    reg V;
    reg Z;

    always_comb begin
        case(ALUop)
            2'b00: out = Ain + Bin;
            2'b01: out = Ain - Bin;
            2'b10: out = Ain & Bin;
            default: out = Bin ^ 16'b1111111111111111;
        endcase

        if(out == 16'b0000000000000000) begin
            Z = 1'b1;
            end
        else begin
            Z = 1'b0;
        end

        if(out[15] == 1'b1) begin
            N = 1'b1;
        end
        else begin
            N = 1'b0;
        end

        if(~(out[15] ^ Ain[15]) && (Ain[15] ^ Bin[15])) begin
            V = 1'b1;
        end
        else begin
            V = 1'b0;
        end

        NVZ = {N, V, Z};
    end
endmodule
