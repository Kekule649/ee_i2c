`timescale 1ns / 1ps

module i2c_controlled_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] data_fetch;
	reg enable;
	reg rw;

	// Outputs
	wire [31:0] data_send;
	wire ready;

	// Bidirs
	wire i2c_sda;
	wire i2c_scl;

	// Instantiate the Unit Under Test (UUT)
	i2c_device_master master (
		.clk(clk), 
		.rst(rst),
		.enable(enable), 
		.rw(rw), 
		.ready(ready), 
		.i2c_sda(i2c_sda), 
		.i2c_scl(i2c_scl)
	);
	
		
	i2c_slave slave (
    .sda(i2c_sda), 
    .scl(i2c_scl),
    .data_fetch(data_fetch),
    .data_send(data_send)
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

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst = 0;		
		data_fetch = 32'b10101010101111001100110000001111;
		rw = 0;	
		enable = 1;
		#10;
		enable = 0;
		
	end      
endmodule
