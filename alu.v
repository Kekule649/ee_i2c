module alu(a,b,op,zero,result);
input [31:0] a,b;
input [2:0] op;
output reg zero;
output reg [31:0] result;

always @(a or b or op)
begin
case(op)
 3'b000: result=a+b;
 3'b001: result=a-b;
 3'b101: result=a<b;
 3'b011: result=a|b;
 3'b010: result=a&b;
 3'b100: result=a==b;
 default: result=3'b0;
 endcase
end

always @ (result)
begin
zero = result?0:1;
end
endmodule

module tb_alu();
reg [31:0] a,b;
reg [2:0] op;
wire zero;
wire [31:0] result;

alu tb(.a(a),.b(b),.op(op),.zero(zero),.result(result));

initial begin
a=32'b00000000000000000000000000010111; b=32'b00000000000000000000000000000101;
end

initial begin
op = 3'b000;
$display("ADD: %b + %b = %b",a,b,result);
#500 op = 3'b001;
$display("SUB: %b - %b = %b",a,b,result);
#500 op = 3'b010;
$display("AND: %b & %b = %b",a,b,result);
#500 op = 3'b011;
$display("OR: %b | %b = %b",a,b,result);
#500 op = 3'b100;
$display("EQU: %b == %b = %b",a,b,result);
#500 op = 3'b101;
$display("LESS: %b < %b = %b",a,b,result);
#500 a=32'b00000000000000000000000000000101; b=32'b00000000000000000000000000010111;
#30;
end
endmodule
