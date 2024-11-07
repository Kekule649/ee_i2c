`timescale 1ns / 1ps

module i2c(
    input wire clk,
    input wire rst,
    input wire [6:0] addr,       // Slave address
    input wire [7:0] data_in,    // Data to send (master)
    input wire enable,            // Enable communication
    input wire rw,                // 0 for write, 1 for read
    input wire mode,              // 0 for master, 1 for slave

    output reg [7:0] data_out,    // Data received (master)
    output wire ready,             // Indicates I2C is ready for a new operation
    output reg sda,               // SDA line
    output reg scl,               // SCL line
    input wire sda_in             // SDA input from slave
);

// State Definitions for Master
localparam IDLE = 3'b000;
localparam START = 3'b001;
localparam ADDRESS = 3'b010;
localparam WRITE_DATA = 3'b011;
localparam WRITE_ACK = 3'b100;
localparam READ_ACK = 3'b101;
localparam READ_DATA = 3'b110;
localparam STOP = 3'b111;

// State Definitions for Slave
localparam SLAVE_IDLE = 3'b000;
localparam SLAVE_ACK = 3'b001;
localparam SLAVE_RECEIVE = 3'b010;
localparam SLAVE_SEND = 3'b011;
localparam SLAVE_ACK_SEND = 3'b100;

reg [2:0] master_state;
reg [2:0] slave_state;
reg [2:0] counter;              // Bit counter for data transmission
reg [7:0] saved_data;           // Data to send/received
reg sda_out;                    // Internal SDA control line
reg scl_enable;                 // SCL control signal

assign ready = (master_state == IDLE || slave_state == SLAVE_IDLE);
assign sda = (mode == 0) ? sda_out : sda_in; // Output SDA based on master mode
assign scl = scl_enable ? clk : 1'b1; // Control SCL line

// Master Logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        master_state <= IDLE;
        counter <= 0;
        sda_out <= 1'b1; // High for idle state
        scl_enable <= 0;
    end else if (mode == 0) begin // Master Mode
        case (master_state)
            IDLE: begin
                if (enable) begin
                    master_state <= START;
                    saved_data <= {addr, rw}; // Save address and rw bit
                    counter <= 7; // 7 bits to send for address
                end
            end
            START: begin
                sda_out <= 1'b0; // Start condition
                scl_enable <= 1; // Enable SCL
                master_state <= ADDRESS;
            end
            ADDRESS: begin
                sda_out <= saved_data[counter]; // Send address bit
                if (counter == 0) begin
                    master_state <= WRITE_ACK; // Move to ACK state
                end else begin
                    counter <= counter - 1; // Decrease counter
                end
            end
            WRITE_ACK: begin
                if (sda_in == 1'b0) begin // Check for ACK
                    if (rw == 0) begin
                        counter <= 7; // Prepare to send data
                        master_state <= WRITE_DATA;
                    end else begin
                        counter <= 0; // Prepare to read data
                        master_state <= READ_ACK;
                    end
                end else begin
                    master_state <= STOP; // Stop if no ACK
                end
            end
            WRITE_DATA: begin
                sda_out <= data_in[counter]; // Send data bit
                if (counter == 0) begin
                    master_state <= STOP; // Done sending data
                end else begin
                    counter <= counter - 1; // Decrease counter
                end
            end
            READ_ACK: begin
                sda_out <= 1'b1; // Release SDA for read
                if (counter < 8) begin
                    master_state <= READ_DATA; // Prepare to read data
                end else begin
                    master_state <= STOP; // No data to read
                end
            end
            READ_DATA: begin
                data_out[counter] <= sda_in; // Read data bit
                if (counter == 7) begin
                    sda_out <= 1'b0; // Send ACK after read
                    master_state <= STOP;
                end else begin
                    counter <= counter + 1; // Increase counter
                end
            end
            STOP: begin
                sda_out <= 1'b1; // Stop condition
                master_state <= IDLE; // Back to idle
            end
        endcase
    end
end

// Slave Logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        slave_state <= SLAVE_IDLE;
        saved_data <= 0;
        sda_out <= 1'b1; // SDA high for idle
    end else if (mode == 1) begin // Slave Mode
        case (slave_state)
            SLAVE_IDLE: begin
                if (sda_in == 0) begin // Detect start condition
                    slave_state <= SLAVE_ACK;
                end
            end
            SLAVE_ACK: begin
                saved_data <= {sda_in, saved_data[6:0]}; // Receive address bit
                if (saved_data[6:0] == addr) begin
                    sda_out <= 1'b0; // Send ACK
                    slave_state <= SLAVE_RECEIVE; // Move to receive data state
                end else begin
                    sda_out <= 1'b1; // No ACK, wait for next
                end
            end
            SLAVE_RECEIVE: begin
                saved_data <= {sda_in, saved_data[6:0]}; // Receive data bit
                if (saved_data[7:0] == 8'hFF) begin // Example condition to stop receiving
                    sda_out <= 1'b0; // Send ACK
                    slave_state <= SLAVE_SEND; // Prepare to send data
                end
            end
            SLAVE_SEND: begin
                sda_out <= saved_data; // Send stored data to master
                slave_state <= SLAVE_ACK_SEND;
            end
            SLAVE_ACK_SEND: begin
                if (sda_in == 1'b0) begin // Wait for ACK from master
                    slave_state <= SLAVE_IDLE; // Go back to idle
                end
            end
        endcase
    end
end

endmodule
