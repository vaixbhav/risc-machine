module datapath_tb;
    reg clk;
    reg [2:0] readnum;
    reg vsel;
    reg loada;
    reg loadb;
    reg [1:0] shift;
    reg asel;
    reg bsel;
    reg [1:0] ALUop;
    reg loadc;
    reg loads;
    reg [2:0] writenum;
    reg write;
    reg [15:0] datapath_in;
    reg err;


    wire Z_out;
    wire [15:0] datapath_out;

    datapath DUT(
    .clk(clk),
    .readnum(readnum),
    .vsel(vsel),
    .loada(loada),
    .loadb(loadb),
    .shift(shift),
    .asel(asel),
    .bsel(bsel),
    .ALUop(ALUop),
    .loadc(loadc),
    .loads(loads),
    .writenum(writenum),
    .write(write),
    .datapath_in(datapath_in),
    .Z_out(Z_out),
    .datapath_out(datapath_out)
	);

    initial begin
	clk = 0;
	#5;
	forever begin
	clk = 1;
	#5;
        clk = 0; 
	#5; 
    end
end

    initial begin
	err =1'b0;

        //writing 7 to R0 
        readnum = 3'b000;
        vsel = 1;
        loada = 0;
        loadb = 0;
        shift = 2'b00;
        asel = 1;
        bsel = 1;
        ALUop = 2'b00;
        loadc = 0;
        loads = 0;
        writenum = 3'b000;
        write = 1;
        datapath_in = 16'b0000000000000111;
        
        #10;

        //Writing 2 to R1
        writenum = 3'b001;
        datapath_in = 16'b0000000000000010;
        #10;

        //Reading R0 to A
        write = 0;
        readnum = 3'b000;
        loada = 1;
        #10;

        loada = 0;

        #10;

        //Reading R1 to B
        loadb = 1;
        readnum = 3'b001;
        #10;

        //Shift B
        shift = 2'b01;
        #10;

        //ALU
        asel = 0;
        bsel = 0;
        #10;
        loadc = 1;
        loads = 1;
	
	#10;	

        if(datapath_out !== 16'b0000000000001011) begin
            $display("ERROR: datapath out is :%b, expected is: %b",datapath_out,  16'b0000000000001011);
            err = 1'b1;
        end

        if(Z_out !== 0) begin
            $display("ERROR: Z out is: %b, expected is: %b",Z_out, 0);
            err = 1'b1;
        end

        if(err == 1'b1) begin
            $display("ERROR");
        end
    end
endmodule


