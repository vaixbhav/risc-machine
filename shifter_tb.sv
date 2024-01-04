module shifter_tb;

    reg [15:0] in;
    reg [1:0] shift;
    wire [15:0] sout;
    reg err;

    shifter DUT(.in(in), .shift(shift), .sout(sout));

    initial begin

        in = 16'b1111000011001111;
        err = 1'b0;

	#10;
        shift = 2'b00;
	#10
        if(16'b1111000011001111 == sout) $display("00 no shift successful!");
        else begin
                err = 1'b1;
                $display("Expected %b, and the result was %b", 16'b1111000011001111, sout);
        end

        shift = 2'b01;
        #10;
        if(16'b1110000110011110 == sout) $display("Left shift successful!");
        else begin
                err = 1'b1;
                $display("Expected %b, and the result was %b", 16'b1110000110011110, sout);
        end

        shift = 2'b10;
        #10;
        if(16'b0111100001100111 == sout) $display("Right shift successful!");
        else begin
                err = 1'b1;
                $display("Expected %b, and the result was %b", 16'b011100001100111, sout);
        end

	shift = 2'b11;
        #10;
        if(16'b1111100001100111 == sout) $display("11 shift successful!");
        else begin
                err = 1'b1;
                $display("Expected %b, and the result was %b", 16'b1111100001100111, sout);
        end

        if(err == 1'b1) $display("ERROR!");
    end
endmodule : shifter_tb



