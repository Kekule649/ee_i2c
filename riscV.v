module riscV(clk,reset,immsrc,resultsrc,memwrite,alusrc,regwrite,pcsrc);
input clk,reset;
output resultsrc,memwrite,alusrc,regwrite,pcsrc;
output [1:0] immsrc;
wire [31:0] pcnext,pc;                    //pc
wire [31:0] pcplus4;                      //adder
wire [31:0] pctarget;                     //adder
wire [31:0] instr;                        //instructionmemory
wire [31:0] rd1,rd2,result;               //registerfile
wire [31:0] imm_ext;                      //immediatextender
wire [31:0] srcb,aluresult;               //alu
wire [2:0] alucontrol;                    //alu              
wire [31:0] read_data;                    //datamemory
wire zero;                                //controlunit
                 
//clk_div clkd(clk,clk_d);

mux pc_next(pctarget,pcplus4,pcsrc,pcnext);

pc ProgC(clk,reset,pcnext,pc);

adder pc_plus4(pc,32'b100,pcplus4);

instmem IM(pc,instr);

register_file RF(instr[19:15],instr[24:20],instr[11:7],result,regwrite,rd1,rd2,clk);

immext ImmExt(instr,immsrc,imm_ext);

mux src_b(imm_ext,rd2,alusrc,srcb);

alu ALU(rd1,srcb,alucontrol,zero,aluresult);

datamem DM(aluresult,rd2,clk,memwrite,read_data);

mux result_0(read_data,aluresult,resultsrc,result);

adder pc_target(pc,imm_ext,pctarget);

controlunit CU(instr[6:0],zero,instr[14:12],instr[30],alusrc,resultsrc,immsrc,regwrite,memwrite,pcsrc,alucontrol);

endmodule 


module tb_risc();
reg clk,reset;
  
riscV dut(clk,reset);
  
always #5 clk=~clk;
  
initial 
begin
 clk =0; reset = 1;
 #10;
 reset = 0;
 #200 $stop;
end
  
endmodule 
