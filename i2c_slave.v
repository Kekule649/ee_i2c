module i2c_slave(
	inout sda,
	inout scl,
	input reg [31:0] data_fetch,
	output reg [31:0] data_send
	);
	
	localparam ADDRESS = 7'b0101010;
	
	localparam READ_ADDR = 0;
	localparam SEND_ACK = 1;
	localparam READ_DATA = 2;
	localparam WRITE_DATA = 3;
	localparam SEND_ACK2 = 4;
	localparam ACK = 5;
	
	reg [7:0] addr;
	reg [7:0] counter;
	reg [7:0] state = 0;
	//reg [31:0] data_out = 32'b11001100101010101111000011110000;
	reg sda_out = 0;
	reg sda_in = 0;
	reg start = 0;
	reg write_enable = 0;
	
	assign sda = (write_enable == 1) ? sda_out : 'bz;
	
	always @(negedge sda) begin
		if ((start == 0) && (scl == 1)) begin
			start <= 1;	
			counter <= 7;
		end
	end
	
	always @(posedge sda) begin
		if ((start == 1) && (scl == 1)) begin
			state <= READ_ADDR;
			start <= 0;
			write_enable <= 0;
		end
	end
	
	always @(posedge scl) begin
		if (start == 1) begin
			case(state)
				READ_ADDR: begin
					addr[counter] <= sda;
					if(counter == 0) state <= SEND_ACK;
					else counter <= counter - 1;					
				end
				
				SEND_ACK: begin
					if(addr[7:1] == ADDRESS) begin
						counter <= 31;
						if(addr[0] == 0) begin 
							state <= READ_DATA;
						end
						else state <= WRITE_DATA;
					end
				end
				
				READ_DATA: begin
					data_send[counter] <= sda;
					if(counter == 0) begin
						state <= SEND_ACK2;
					end
					else if((counter == 7) || (counter == 15) || (counter == 23)) begin
						state <= ACK;
						counter <= counter - 1;
					end else counter <= counter - 1;
				end

				ACK: begin
					if(addr[0] == 0) begin 
						state <= READ_DATA;
					end
					else state <= WRITE_DATA;
				end
				
				SEND_ACK2: begin
					state <= READ_ADDR;					
				end
				
				WRITE_DATA: begin
					if(counter == 0) state <= READ_ADDR;
					else if((counter == 7) || (counter == 15) || (counter == 23)) begin
						state <= ACK;
						counter <= counter - 1;
					end else counter <= counter - 1;		
				end
				
			endcase
		end
	end
	
	always @(negedge scl) begin
		case(state)
			
			READ_ADDR: begin
				write_enable <= 0;			
			end
			
			SEND_ACK: begin
				sda_out <= 0;
				write_enable <= 1;	
			end
			
			READ_DATA: begin
				write_enable <= 0;
			end
			
			WRITE_DATA: begin
				sda_out <= data_fetch[counter];
				write_enable <= 1;
			end
			
			SEND_ACK2: begin
				sda_out <= 0;
				write_enable <= 1;
			end

			ACK: begin
				sda_out <= 0;
			end
		endcase
	end
endmodule
