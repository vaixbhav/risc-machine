module mux_9bit(
    input sel,
    input [8:0] A,
    input [8:0] B,
    output reg [8:0] out
);


    always_comb begin
        out = sel ? A : B;
    end
endmodule