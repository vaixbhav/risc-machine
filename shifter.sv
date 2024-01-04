module shifter(
    input [15:0] in,
    input [1:0] shift,
    output reg [15:0] sout
);


    always @(*) begin
        case(shift)
            2'b01: sout = {in[14:0], 1'b0};
            2'b10: sout = {1'b0, in[15:1]};
	    2'b11: sout = {in[15], in[15:1]};
            default: sout = in;
        endcase
    end
endmodule