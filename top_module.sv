module top_module(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5); 
       input[3:0] KEY;    //   ~KEY[0] : clk, ~KEY[1] : reset
       input[9:0] SW;      
       output[9:0] LEDR;
       output[6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

        wire [1:0] mem_cmd;
        wire [8:0] mem_addr;
        reg [15:0] read_data;  //goes to instruction reg
	//reg [15:0] read_data_1;
	//reg [15:0] read_data_0;
        wire write;
        wire [15:0] write_data;
        wire msel;
        wire MWRITE_eq;
        wire MREAD_eq;
        wire MWRITE_and;
        wire MREAD_and;
        reg [15:0] dout;
    
        cpu CPU(.clk(~KEY[0]), .reset(~KEY[1]), .read_data(read_data), .write_data(write_data),
                 .mem_addr(mem_addr), .mem_cmd(mem_cmd), .N(N), .V(V), .Z(Z));

        
        assign MWRITE_eq = (`MWRITE == mem_cmd) ? 1 : 0;
        assign MREAD_eq = (`MREAD == mem_cmd) ? 1 : 0;
        assign msel = (mem_addr[8] == 1'b0) ? 1 : 0;
        assign MWRITE_and = MWRITE_eq && msel;
        assign MREAD_and = MREAD_eq && msel;


        RAM #(16, 8) MEM(.clk(~KEY[0]),.read_address(mem_addr[7:0]),.write_address(mem_addr[7:0])
                ,.write(MWRITE_and),.din(write_data),.dout(dout));

        /* always@(*) begin 
             read_data_0 = MREAD_and ? dout : {16{1'bz}};   //16 bit tri state driver
         end */
         
         //tri-state driver for switch input
         reg enable_sw;

          always @(*) begin
             if(mem_cmd == `MREAD && mem_addr == 9'h140) begin
                 enable_sw = 1;
             end else begin
                 enable_sw = 0;
             end
//             read_data_1[15:8] = enable_sw ? 8'h00 : {8{1'bz}};
            // read_data_1[7:0] = enable_sw ? SW[7:0] : {8{1'bz}};
          end 
	
	always @(*) begin
		if(enable_sw == 1) begin
		    read_data[15:8] = enable_sw ? 8'h00 : {8{1'bz}};
            read_data[7:0] = enable_sw ? SW[7:0] : {8{1'bz}};		
		end else begin
		if(MREAD_and == 1) begin
			read_data = dout;	
		end else begin
    		read_data = {16{1'bz}};
		end 		
	end	
end 

        //load-enabled LED (DE1 output)
        reg load_led;
        
        vDFFE #(8) LED(.clk(~KEY[0]), .en(load_led), .in(write_data[7:0]), .out(LEDR[7:0]));


         always@(*) begin
            if(mem_cmd == `MWRITE && mem_addr == 9'h100) begin
                load_led = 1'b1;
            end else begin
                load_led = 1'b0;
            end            
         end 
         

    endmodule



