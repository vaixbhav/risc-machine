module mux_3to1(
    input [1:0]sel,
    input [15:0] A,
    input [15:0] B,
    input [15:0] C,
    output reg [15:0] out
);


    always_comb begin
        out = sel[0] ? (sel[1] ? C : B) : A;
    end
endmodule
