module datapath(
    input clk,
    input [2:0] readnum,
    input [1:0] vsel,  //becomes 2 bit for 4to1 mux
    input loada,
    input loadb,
    input [1:0] shift,
    input asel,
    input bsel,
    input [1:0] ALUop,
    input loadc,
    input loads,
    input [2:0] writenum,
    input write,
    // input [15:0] datapath_in,
    input [15:0] mdata,   //0 to mdata for lab 6  (input or wire?)
    input [15:0] sximm8,  //(input or wire?)
    input [7:0] PC,       //0 for PC for lab 6  (input or wire?)
    input [15:0] sximm5, //(input or wire?)
    output [2:0] stat,
    output [15:0] datapath_out
);

    wire [15:0] data_in;
    wire [15:0] data_out;
    wire [15:0] loada_out;
    wire [15:0] loadb_out;
    wire [15:0] Ain;
    wire [15:0] sout;
    wire [15:0] Bin;
    wire [15:0] ALU_out;
    wire [2:0] NVZ;


    mux4_to1 TOP_MUX(.sel(vsel), .A(mdata), .B(sximm8), .C({8'b0, PC}), .D(datapath_out), .out(data_in));

    regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);

    vDFFE #(16) blockA(clk, loada, data_out, loada_out);
    
    vDFFE #(16) blockB(clk, loadb, data_out, loadb_out);
    
    mux MUXA(asel, 16'b0, loada_out, Ain);
    
    shifter SHIFTER(loadb_out, shift, sout);
    
    mux MUXB(bsel, sximm5, sout, Bin);

    ALU alu(Ain, Bin, ALUop, ALU_out, NVZ);
    
    vDFFE #(16) blockC(clk, loadc, ALU_out, datapath_out);

    vDFFE #(3) status(clk, loads, NVZ, stat);   //Status register updated to 3 
                                                //Still have to update each bit to represent flag

endmodule
