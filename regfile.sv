module regfile(data_in,writenum,write,readnum,clk,data_out);

input [15:0] data_in;            //data to write           
input [2:0] writenum, readnum;   //address to write to / address to read from     
input write, clk;                //write: (1) when we wish to save/write      
output [15:0] data_out;          //data to read
     

reg [15:0] data_out;
reg [15:0] R0, R1, R2, R3, R4, R5, R6, R7;     //registers outputs of load enables
reg [7:0] doutW;        //output of upper decoder
                        //output of 8 AND gates
reg load0, load1, load2, load3, load4, load5, load6, load7;   

 // fill out the rest      

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


//Does writenum need to be used here?
always @(*) begin    //3:8 decoder for writenum (upper decoder)
        case(writenum)
        `reg0: begin 
            doutW <= `reg0_decoded;
        end
        `reg1: begin 
            doutW <= `reg1_decoded;
        end        
        `reg2: begin 
            doutW <= `reg2_decoded;
        end
        `reg3: begin 
            doutW <= `reg3_decoded;
        end
        `reg4: begin 
            doutW <= `reg4_decoded;
        end
        `reg5: begin 
            doutW <= `reg5_decoded;
        end
        `reg6: begin 
            doutW <= `reg6_decoded;
        end
        `reg7: begin 
            doutW <= `reg7_decoded;
        end    
        default: doutW <= 8'bxxxxxxxx;                                    
        endcase

 load0 <= doutW[0] & write;
 load1 <= doutW[1] & write;
 load2 <= doutW[2] & write;
 load3 <= doutW[3] & write;
 load4 <= doutW[4] & write;
 load5 <= doutW[5] & write; 
 load6 <= doutW[6] & write;
 load7 <= doutW[7] & write;

end

            vDFFE #(16) R0load(clk, load0, data_in, R0);
            vDFFE #(16) R1load(clk, load1, data_in, R1);
            vDFFE #(16) R2load(clk, load2, data_in, R2);
            vDFFE #(16) R3load(clk, load3, data_in, R3);
            vDFFE #(16) R4load(clk, load4, data_in, R4);
            vDFFE #(16) R5load(clk, load5, data_in, R5);
            vDFFE #(16) R6load(clk, load6, data_in, R6);
            vDFFE #(16) R7load(clk, load7, data_in, R7);

always @(*) begin    //3:8 decoder for readnum (lower decoder)
    
    case(readnum)
    `reg0: begin 
        data_out = R0;
    end
    `reg1: begin 
        data_out = R1;
    end
    `reg2: begin 
        data_out = R2;
    end
    `reg3: begin 
        data_out = R3;
    end
    `reg4: begin 
        data_out = R4;
    end
    `reg5: begin 
        data_out = R5;
    end
    `reg6: begin 
        data_out = R6;
    end
    `reg7: begin 
        data_out = R7;
    end
    default: data_out = 16'bxxxxxxxxxxxxxxxx;            
    endcase 
end
endmodule


