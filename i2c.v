module i2c(
	input clk,
	input rst,
	input mode,
	input wire [6:0] addr,
	input wire [31:0] reg_read,
	input wire enable,
	input wire rw,

	output wire [31:0] reg_write,
	output wire ready
);

wire i2c_sda;
wire i2c_scl;

wire [31:0] data_in =0;
wire [31:0] data_send =0;

i2c_controller mm_master (
		.clk(clk), 
		.rst(rst), 
		.addr(addr), 
		.data_in(data_in), 
		.enable(enable), 
		.rw(rw), 
		.data_out(reg_read), 
		.ready(ready), 
		.i2c_sda(i2c_sda), 
		.i2c_scl(i2c_scl)
	);

i2c_slave_controller mm_slave (
    .sda(i2c_sda), 
    .scl(i2c_scl)
    );


i2c_device_master sm_master (
		.clk(clk), 
		.rst(rst),
		.enable(enable), 
		.rw(rw), 
		.ready(ready), 
		.i2c_sda(i2c_sda), 
		.i2c_scl(i2c_scl)
	);

i2c_slave sm_slave (
    .sda(i2c_sda), 
    .scl(i2c_scl),
    .data_fetch(reg_read),
    .data_send(data_send)
    );

mux mode_selection(data_send,data_in,mode,reg_write);

endmodule
