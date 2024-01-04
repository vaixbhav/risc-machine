module cpu_tb ();
    reg SIM_clk, SIM_reset, SIM_s, SIM_load;
    reg [15:0] SIM_in;
    wire [15:0] SIM_out;
    wire SIM_N, SIM_V, SIM_Z, SIM_w;

    reg err;

    //cpu module instantiation
    cpu DUT(SIM_clk, SIM_reset, SIM_s, SIM_load, SIM_in, SIM_out, SIM_N, SIM_V, SIM_Z, SIM_w);

    //clk cycle
    initial begin
        SIM_clk = 0; #5;
        forever begin
        SIM_clk = 1; #5;
        SIM_clk = 0; #5;
        end
    end

    //Test benches
    initial begin
        //Initializations
        err = 0;
        SIM_reset = 1; SIM_s = 0; SIM_load = 0; SIM_in = 16'b0;
        #10;
        SIM_reset = 0; 
        #10;

        //Test: MOV R1, #70
        SIM_in = 16'b1101000101000110;
        SIM_load = 1;
        #10;
        SIM_load = 0;
        SIM_s = 1;
        #10
        SIM_s = 0;
        @(posedge SIM_w); // wait for w to go high again
        #10;
        if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'b1101000101000110) begin
        err = 1;
        $display("FAILED TEST #1: MOV R1, #70");
        $stop;
        end

        //Test: MOV R2, #2
        @(negedge SIM_clk);
        SIM_in = 16'b1101001000000010;
        SIM_load = 1;
        #10;
        SIM_load = 0;
        SIM_s = 1;
        #10
        SIM_s = 0;
        @(posedge SIM_w); // wait for w to go high again
        #10;
        if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'd2) begin
        err = 1;
        $display("FAILED TEST #2: MOV R2, #2");
        $stop;
        end

        //Test: MOV R3, #8
        @(negedge SIM_clk);
        SIM_in = 16'b1101001100001000;
        SIM_load = 1;
        #10;
        SIM_load = 0;
        SIM_s = 1;
        #10
        SIM_s = 0;
        @(posedge SIM_w); // wait for w to go high again
        #10;
        if (cpu_tb.DUT.DP.REGFILE.R3 !== 16'd8) begin
        err = 1;
        $display("FAILED TEST #3: MOV R3, #8");
        $stop;
        end


        //Test: MOV R1, R0, LSL#1 (R1 Should Equal 20)
        @(negedge SIM_clk);
        SIM_in = 16'b1100000000101000;
        SIM_load = 1;
        #10;
        SIM_load = 0;
        SIM_s = 1;
        #10
        SIM_s = 0;
        @(posedge SIM_w); // wait for w to go high again
        #10;
        if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'd20) begin
        err = 1;
        $display("FAILED TEST #9: MOV R1, R0, LSL#1");
        $stop;
        end
        


        //Test: ADD R2, R1, R5 (R2 Should Equal 24)
        @(negedge SIM_clk);
        SIM_in = 16'b1010000101000101;
        SIM_load = 1;
        #10;
        SIM_load = 0;
        SIM_s = 1;
        #10
        SIM_s = 0;
        @(posedge SIM_w); // wait for w to go high again
        #10;
        if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'd24) begin
        err = 1;
        $display("FAILED TEST #11: ADD R2, R1, R5");
        $stop;
        end



        //Test: CMP R0, R1, LSR#1 (R0 Should Equal R1/2)
        @(negedge SIM_clk);
        SIM_in = 16'b1010100000010001;
        SIM_load = 1;
        #10;
        SIM_load = 0;
        SIM_s = 1;
        #10
        SIM_s = 0;
        @(posedge SIM_w); // wait for w to go high again
        #10;
        if (cpu_tb.DUT.Z !== 1'd1) begin
        err = 1;
        $display("FAILED TEST #14: CMP R0, R1, LSR#1");
        $stop;
        end


        //Test: AND R7, R2, R3
        @(negedge SIM_clk);
        SIM_in = 16'b1011001011100011;
        SIM_load = 1;
        #10;
        SIM_load = 0;
        SIM_s = 1;
        #10
        SIM_s = 0;
        @(posedge SIM_w); // wait for w to go high again
        #10;
        if (cpu_tb.DUT.DP.REGFILE.R7 !== 16'b1111111111110110) begin
        err = 1;
        $display("FAILED TEST #19: AND R7, R2, R3");
        $stop;
        end

    

        //Test: MVN R4, R4
        @(negedge SIM_clk);
        SIM_in = 16'b1011100010000100;
        SIM_load = 1;
        #10;
        SIM_load = 0;
        SIM_s = 1;
        #10
        SIM_s = 0;
        @(posedge SIM_w); // wait for w to go high again
        #10;
        if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'b1111111111101010) begin
        err = 1;
        $display("FAILED TEST #22a: MVN R4, R4");
        $stop;
        end
        if (cpu_tb.DUT.N !== 1'd1) begin
        err = 1;
        $display("FAILED TEST #22b: MVN R4, R4");
        $stop;
        end
        if (cpu_tb.DUT.V !== 1'd1) begin
        err = 1;
        $display("FAILED TEST #22c: MVN R4, R4");
        $stop;
        end

        if (~err) $display("All tests passed");

        $stop;

    end
endmodule