module immext(instr,immsrc,imm_data);
input [31:0] instr;
input [1:0] immsrc;
output [31:0] imm_data;
reg [31:0] imm_data;
always @(instr or immsrc)
begin
  case(immsrc)
 2'b00: imm_data = {{20{instr[31]}},instr[31:20]};
 2'b01: imm_data = {{20{instr[31]}},instr[31:25],instr[11:7]};
 2'b10: imm_data = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
 default: imm_data = 32'bx;
 endcase
end
endmodule
