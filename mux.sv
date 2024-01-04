module mux(
    input sel,
    input [15:0] A,
    input [15:0] B,
    output reg [15:0] out
);


    always_comb begin
        out = sel ? A : B;
    end
endmodule