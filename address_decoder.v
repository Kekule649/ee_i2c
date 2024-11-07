module address_decoder(
input memWrite,
input [31:0] Addr,

output reg WEM,
output reg WEId, WEIc,WEIs,
output reg Rd_sel);

localparam I2C_slave_address = 60;  //TX data reg
                                    //control reg addr = 61  
                                    //status reg addr = 62   
												//RX data reg = 63
												
always @ (*)
begin
if (I2C_slave_address == Addr && memWrite ==1)
begin
WEM=0; WEId=1; WEIc=0; WEIs=0; Rd_sel=1;
end

else if (I2C_slave_address+1 == Addr && memWrite ==1)
begin
WEM=0; WEId=0; WEIc=1; WEIs=0; Rd_sel=1;
end

else if (I2C_slave_address+2 == Addr && memWrite ==0)
begin
WEM=0; WEId=0; WEIc=0; WEIs=1; Rd_sel=1;
end

else if(I2C_slave_address +3 == Addr && memWrite ==0)
begin
WEM=0; WEId=0; WEIc=0; WEIs=0; Rd_sel=1;
end

else if(I2C_slave_address != Addr && memWrite ==1)
begin
WEM=1; WEId=0; WEIc=0; WEIs=0; Rd_sel=0;
end

else if(I2C_slave_address != Addr && memWrite ==0)
begin
WEM=0; WEId=0; WEIc=0; WEIs=0; Rd_sel=0;
end

end

endmodule
