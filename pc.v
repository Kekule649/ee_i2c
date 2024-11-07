module pc(clk,rst,pc_in,pc_out);
input clk,rst;
input [31:0] pc_in;
output [31:0] pc_out;
reg [31:0] pc_out;

initial pc_out = 0;

always@(posedge clk)
begin 
if (rst)
pc_out = 0;
else
pc_out = pc_in;
end
endmodule


module tb_pc();
reg clk, rst;
reg [31:0] pc_in;
wire [31:0] pc_out; 

pc tb(.clk(clk), .rst(rst), .pc_in(pc_in), .pc_out(pc_out));

initial begin
clk=0; rst=0;
pc_in = 32'b00000000000000000000000000010111;
end

initial begin
#500 clk=~clk;
pc_in = 32'b00000000000000000000000000000001;
#500 clk=~clk;
pc_in = 32'b00000000000000000000000000000101;
#500 clk=~clk;
pc_in = 32'b00000000000000000000000000000111;
#500 clk=~clk;
pc_in = 32'b00000000000000000000000000010101;
#500 clk=~clk;
pc_in = 32'b00000000000000000000000000001101;
#500 clk=~clk;
pc_in = 32'b00000000000000000000000000000100;
#500 clk=~clk; rst=1;
pc_in = 32'b00000000000000000000000000000101;
#500 clk=~clk;
pc_in = 32'b00000000000000000000000000001101;
#500 clk=~clk; 
pc_in = 32'b00000000000000000000000001000111;
#500 clk=~clk;
pc_in = 32'b00000000000000000000000000000101;
#500 clk=~clk;
pc_in = 32'b00000000000000000000000000001101;
#500 clk=~clk;
pc_in = 32'b00000000000000000000000000001001;
end
endmodule
