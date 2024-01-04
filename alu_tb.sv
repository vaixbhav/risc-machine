module ALU_tb;

    reg [15:0] Ain;
    reg [15:0] Bin;
    reg [1:0] ALUop;
    reg err;

    wire [15:0] out;
    wire Z;

    ALU DUT(.Ain(Ain), .Bin(Bin), .ALUop(ALUop), .out(out), .Z(Z));

    initial begin

        Ain = 16'b1111000011001111;
        Bin = 16'b1111000011001111;
	    err = 1'b0;

	    #10;
        ALUop = 2'b00;
	    #10
        if(16'b1111000011001111 + 16'b1111000011001111 == out) begin
            if(Z == 1'b0) $display("Addition successful!");
            else err = 1'b1;
        end
        else begin
            err = 1'b1;
            $display("Expected %b, and the result was %b.", 16'b1111000011001111 + 16'b1111000011001111, out);
        end
        

        ALUop = 2'b01;
        #10;
        if(16'b1111000011001111 - 16'b1111000011001111 == out) begin
            if(Z == 1'b1) $display("Subtraction successful!");
            else err = 1'b1;
        end
        else begin
            err = 1'b1;
            $display("Expected %b, and the result was %b.", 16'b1111000011001111 - 16'b1111000011001111, out);
        end

        ALUop = 2'b10;
        #10;
        if(16'b1111000011001111 & 16'b1111000011001111 == out) begin
            if(Z == 1'b0) $display("AND successful!");
            else err = 1'b1;
        end
        else begin
            err = 1'b1;
            $display("Expected %b, and the result was %b.", 16'b1111000011001111 & 16'b1111000011001111, out);
        end

	    ALUop = 2'b11;
        #10;
        if(16'b1111111111111111 ^ 16'b1111000011001111 == out) begin
            if(Z == 1'b0) $display("NOT successful!");
            else err = 1'b1;
        end
        else begin
            err = 1'b1;
            $display("Expected %b, and the result was %b.", 16'b1111111111111111 ^ 16'b1111000011001111, out);
        end

        if(err == 1'b0) begin
            $display("ERROR!");
        end

    end
endmodule : ALU_tb


