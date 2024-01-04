module mux4_to1(
    input [1:0] sel,
    input [15:0] A,
    input [15:0] B,
    input [15:0] C,
    input [15:0] D,
    output reg [15:0] out
);

    always_comb begin
        out = sel[1] ? (sel[0] ? D : C) : (sel[0] ? B : A);
    end

endmodule