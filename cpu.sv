module cpu(clk, reset, read_data, write_data, N, V, Z, mem_addr, mem_cmd);
input clk, reset;
input [15:0] read_data;
output [15:0] write_data;
output N, V, Z;
output reg [1:0] mem_cmd;
output reg [8:0] mem_addr;


wire [15:0] instreg_out; // from Instruction Register
wire [2:0] opcode;   //from Instruction Decoder
wire [1:0] op; 
wire [2:0] readnum;
wire [2:0] writenum;
wire [1:0] shift;
wire [15:0] sximm8;
wire [15:0] sximm5;
wire [1:0] ALUop;
wire [41:0] instdec_out;

reg w;
reg write;
reg asel;
reg bsel;
reg [1:0] vsel;
reg loada;
reg loadb;
reg loadc;
reg loads;
reg [1:0] nsel;
reg load_ir;
reg load_pc;
reg reset_pc;
reg addr_sel;
reg load_addr;


wire [8:0] next_pc;
wire [8:0] PC;
wire [8:0] adder_out; 
wire [8:0] data_addr_out;

assign ALUop = instdec_out[1:0];
assign readnum = instdec_out[38:36];
assign writenum = instdec_out[41:39];
assign shift = instdec_out[35:34];
assign sximm8 = instdec_out[33:18];
assign sximm5 = instdec_out[17:2];

assign adder_out = PC + 1;  //+1 block

reg[4:0] pres_state;  //for state machine


//Instantiating instruction decoder
instruction_decoder instdec(.C(instreg_out), .nsel(nsel), .opcode(opcode), .op(op), .out(instdec_out));


//Instantiating instruction register (load-enabled)
vDFFE instreg(.clk(clk), .en(load_ir), .in(read_data), .out(instreg_out) );

//PC (Program Counter)
vDFFE #(9) pc(.clk(clk), .en(load_pc), .in(next_pc), .out(PC));


//2-to-1 Mux before PC
mux_9bit PC_mux(.sel(reset_pc), .A(9'b0), .B(adder_out), .out(next_pc));


//Data Address
vDFFE #(9) DataAddress(.clk(clk), .en(load_addr), .in(write_data[8:0]), .out(data_addr_out));

mux_9bit Data_Addr(.sel(addr_sel), .A(PC), .B(data_addr_out), .out(mem_addr));

//States for controller 

`define Reset_state 5'b00000
`define Decode_state 5'b00001
`define GetRn_state 5'b00010
`define GetRm_state 5'b00011
`define MOV_state 5'b00100
`define CMP_state 5'b00101
`define WriteStatus_state 5'b00110
`define ALU_state 5'b00111
`define WriteReg_state 5'b01000
`define WriteImm_state 5'b01001
`define Load_state 5'b01100
`define IF1_state 5'b01010
`define IF2_state 5'b01101
`define Halt_state 5'b01111
`define LDRAddr_state 5'b10000
`define LDRDataAddr_state 5'b10001 
`define MEMRead_state 5'b10010
`define MEMReadDone_state 5'b11110
`define LDRRegWrite_state 5'b10100
`define UpdatePC_state 5'b11000
`define STRDataAddr_state 5'b11001
`define STRRegRead_state 5'b11010
`define STRRegReadDone_state 5'b11111
`define STRAddr_state 5'b11100
`define MEMWrite_state 5'b11101



`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

`define Rn 2'b00
`define Rm 2'b10
`define Rd 2'b01

//Moore State machine controller for datapath

always @(posedge clk) begin
    if(reset == 1'b1) begin
        w = 1'b1;
        pres_state = `Reset_state  ; 
        end
    else begin
        w = 1'b0;
        case(pres_state)
        `Reset_state: begin 
            pres_state = `IF1_state;
        end

        `IF1_state: begin
            pres_state = `IF2_state;
        end

        `IF2_state: begin
            pres_state = `UpdatePC_state;
        end

        `UpdatePC_state: begin
            pres_state = `Decode_state;
        end

        `Decode_state: begin 
            if(op == 2'b00 && opcode == 3'b011) begin
                pres_state = `LDRAddr_state; 
            end
            else if(op == 2'b00 && opcode == 3'b100) begin
                pres_state = `STRAddr_state; 
            end
            else if(op == 2'b10 && opcode == 3'b110) begin
                pres_state = `WriteImm_state; 
            end
            else if(opcode == 3'b111) begin
                pres_state = `Halt_state; 
            end
            else begin
                pres_state = `GetRn_state;
            end
        end

        `LDRAddr_state: begin //calc effective addr
            pres_state = `LDRDataAddr_state; 
        end

        `LDRDataAddr_state: begin //store address in data address register
            pres_state = `MEMRead_state; 
        end

        `MEMRead_state: begin //addr_sel MEMREAD
            pres_state = `MEMReadDone_state; 
        end

        `MEMReadDone_state: begin //wait for mem to update
            pres_state = `LDRRegWrite_state; 
        end

        `LDRRegWrite_state: begin
            pres_state = `IF1_state;
        end

        `STRAddr_state: begin // calc effective address
            pres_state = `STRDataAddr_state;
        end

        `STRDataAddr_state: begin //store address in data address register
            pres_state = `STRRegRead_state; 
        end
        
        `STRRegRead_state: begin // Read Rd and send to DP out
            pres_state = `STRRegReadDone_state;
        end

        `STRRegReadDone_state: begin // Send din to mem
            pres_state = `MEMWrite_state;
        end

        `MEMWrite_state: begin // write to mem
            pres_state = `IF1_state;
        end

        `WriteImm_state: begin
            pres_state = `IF1_state;
        end

        `GetRn_state: begin 
            pres_state = `GetRm_state;
        end

        `GetRm_state: begin 
            if(opcode == 3'b110 && op == 2'b00) begin
                pres_state = `MOV_state;
            end
            else if(opcode == 3'b101 && op == 2'b01) begin
                pres_state = `CMP_state;
            end
            else begin
            pres_state = `ALU_state;
            end
        end 

        `ALU_state: begin 
            pres_state = `Load_state;
        end

        `CMP_state: begin 
            pres_state = `WriteStatus_state;
        end

        `MOV_state: begin 
            pres_state = `Load_state;
        end

        `WriteStatus_state: begin 
            pres_state = `IF1_state;
        end
        
        `Load_state: begin
            pres_state = `WriteReg_state;
        end

        `WriteReg_state: begin
            pres_state = `IF1_state;
        end

        `Halt_state: begin
            pres_state = `Halt_state;
        end

        default: begin
            pres_state = `Reset_state;
        end
        endcase
    end
end

always @(*) begin
        case(pres_state)
                       
            `GetRn_state: {nsel, loada, loadb} = {2'b00, 1'b1, 1'b0};
            `GetRm_state: {nsel, loadb, loada} = {2'b10, 1'b1, 1'b0};
            `ALU_state: {asel, bsel} = {1'b0, 1'b0};
            `MOV_state: {asel, bsel} = {1'b1, 1'b0};
            `CMP_state: {asel, bsel} = {1'b0, 1'b0};
            `Load_state: {loadc} = {1'b1};
            `WriteReg_state: {loadc, vsel, nsel, write} = {1'b1, 2'b11, 2'b01, 1'b1};
            `WriteStatus_state: {loads} = {1'b1};
            `WriteImm_state: {vsel, nsel, write} = {2'b01, 2'b00, 1'b1};
            `IF1_state: begin
                {addr_sel, mem_cmd, load_pc, reset_pc, write} = {1'b1, `MREAD, 1'b0, 1'b0, 1'b0};
                {loada, loadb, loadc, loads, asel, bsel} = 6'b0;
            end
            `IF2_state: {addr_sel, load_ir, mem_cmd, load_addr} = {1'b1, 1'b1, `MREAD, 1'b1};
            `LDRAddr_state: {nsel, loada, loadb, asel, bsel, loadc} = {`Rn, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1};
            `LDRDataAddr_state: {load_addr} = 1'b1;
            `MEMRead_state: {mem_cmd, addr_sel} = {`MREAD, 1'b0};
            `MEMReadDone_state: {mem_cmd, addr_sel, load_addr} = {`MREAD, 1'b0, 1'b0};
            `LDRRegWrite_state: {vsel, write, nsel} = {2'b00, 1'b1, `Rd};
            `UpdatePC_state: {load_ir, load_pc, mem_cmd, load_addr} = {1'b0, 1'b1, `MNONE, 1'b0};
            `STRAddr_state: {nsel, loada, loadb, asel, bsel, loadc} = {`Rn, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1};
            `STRDataAddr_state: {load_addr, loadc} = {1'b1, 1'b0};
            `STRRegRead_state: {nsel, asel, bsel, loada, loadb, loadc} = {`Rd, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1};
            `STRRegReadDone_state: {load_addr} = {1'b1};
            `MEMWrite_state: {mem_cmd, addr_sel, load_addr} = {`MWRITE, 1'b0, 1'b0};
            `Reset_state: {load_pc, reset_pc} = {1'b1, 1'b1};
            default: begin 
                load_pc = 1'b0;

            end
        endcase         
end




//Instantiating datapath
datapath DP(.clk(clk), 
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
            .mdata(read_data),
            .sximm8(sximm8),
            .PC(8'b0),
            .sximm5(sximm5),
            .stat({N,V,Z}),
            .datapath_out(write_data)
        );

endmodule



// //Instruction Decoder using output from Instruction Register
// module instdec(in, opcode, op, nsel, readnum, writenum, 
//                 shift, sximm8, sximm5, ALUop);

// input [15:0] in;
// input [1:0] nsel       //correct size of nsel?

// output [2:0] opcode;
// output [1:0] op; 
// output [2:0] readnum;
// output [2:0] writenum;
// output [1:0] shift;
// output [15:0] sximm8;
// output [15:0] sximm5;
// output [1:0] ALUop;


// //To controller FSM
// assign opcode = in[15:13];     
// assign op = in[12:11];


// //From controller FSM to datapath
// assign writenum =   (nsel == 3'b100) ? in[2:0] :    //Rm = 3'b100
//                     (nsel == 3'b010) ? in[7:5]:     //Rd = 3'b010
//                     (nsel == 3'b001) ? in[10:8] :   //Rn = 3'b001
//                     3'bxxx;

// assign readnum =   (nsel == 3'b100) ? in[2:0] :    //Rm = 3'b100
//                     (nsel == 3'b010) ? in[7:5]:     //Rd = 3'b010
//                     (nsel == 3'b001) ? in[10:8] :   //Rn = 3'b001    
//                     3'bxxx;                
                    
// //Shift output to datapath
// assign shift = in[4:3];

// // Sign extend: out = { {OutputWidth-InputWidth{in[InputWidth-1]}}, in };
// assign sximm8 = { {8{in[7]}}, in[7:0]};
// assign sximm5 = { {11{in[4]}}, in[4:0]};

// //ALUop output to datapath / same as op
// assign ALUop = in[12:11];


// endmodule


