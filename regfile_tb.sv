`define reg0 3'b000
`define reg1 3'b001
`define reg2 3'b010
`define reg3 3'b011
`define reg4 3'b100
`define reg5 3'b101
`define reg6 3'b110
`define reg7 3'b111

`define reg0_decoded 8'b00000001
`define reg1_decoded 8'b00000010
`define reg2_decoded 8'b00000100
`define reg3_decoded 8'b00001000
`define reg4_decoded 8'b00010000
`define reg5_decoded 8'b00100000
`define reg6_decoded 8'b01000000
`define reg7_decoded 8'b10000000

module regfile_tb;

reg [15:0] data_in;            //data to write           
reg [2:0] writenum, readnum;   //address to write to / address to read from     
reg write, clk;                //write: (1) when we wish to save/write      
wire [15:0] data_out;          //data to read
reg err;


regfile DUT(data_in,writenum,write,readnum,clk,data_out);

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
        //write 42 to R3 test
        data_in =  16'b0000000000101010; //binary for 42
        writenum = 3'b011; //binary for 3
        write = 1'b1;  //indicate we want to write
	readnum = 3'b011;
        #10;  //rising edge
        if(regfile_tb.DUT.doutW !== `reg3_decoded) begin
            $display("ERROR, decoded value is %b, expected: %b", regfile_tb.DUT.doutW, `reg3_decoded);
            err = 1'b1;
        end

        if(regfile_tb.DUT.load3 !== 1'b1) begin 
            $display("ERROR, load value is %b, expected: %b", regfile_tb.DUT.load3, 1'b1);
            err = 1'b1; 
        end 

        if(regfile_tb.DUT.R3 !== 16'b0000000000101010) begin
            $display("ERROR, R3 data is %b, expected: %b", regfile_tb.DUT.R3, 16'b0000000000101010);
            err = 1'b1;             
        end
	
        if(regfile_tb.DUT.data_out !== 16'b0000000000101010) begin
            $display("ERROR, data out is %b, expected: %b", regfile_tb.DUT.data_out, 16'b0000000000101010);
            err = 1'b1;             
        end

        write = 1'b0;
	end
endmodule