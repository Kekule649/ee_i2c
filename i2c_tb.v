`timescale 1ns / 1ps

module i2c_tb;

	reg clk;
	reg rst;
	reg mode;
	reg [6:0] addr;
	reg [31:0] reg_read;
	reg enable;
	reg rw;

	wire [31:0] reg_write;
	wire ready;

i2c i2c_tb (
	.clk(clk), 
	.rst(rst),
	.enable(enable), 
	.rw(rw), 
	.ready(ready), 
	.addr(addr), 
	.mode(mode),
	.reg_read(reg_read),
	.reg_write(reg_write)
);


	initial begin
		clk = 0;
		forever begin
			clk = #1 ~clk;
		end		
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		mode = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst = 0;		
		addr = 7'b0101010;
		reg_read = 32'b10101010101111001100110000001111;
		rw = 0;	
		enable = 1;
		#10;
		enable = 0;
		
	end      
endmodule
