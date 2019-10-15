`define WAIT 0
`define ADDR 1
`define ADDR_FIN 2
`define WAIT_DATA 3
`define DATA 4
`define DATA_FIN 5

module SPI_Slave(CLK, SCK, SS, MOSI, MISO,
	V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15,
	V16, V17, V18, V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, V29, V30, V31); 
	input CLK, SCK, SS, MOSI;
	output MISO;
	output [7:0]	V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15,
						V16, V17, V18, V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, V29, V30, V31; 
	
	wire MISO;

	reg [2:0] SCKr;
	always @(posedge CLK) SCKr <= {SCKr[1:0], SCK};
	wire SCK_rise = (SCKr[2:1]==2'b01);
	wire SCK_fall = (SCKr[2:1]==2'b10);

	reg [2:0] SSr;
	always @(posedge CLK) SSr <= {SSr[1:0], SS};
	wire SS_active = ~SSr[1];
	wire SS_start = (SSr[2:1]==2'b10);
	wire SS_end = (SSr[2:1]==2'b01);

	reg [2:0] state;
	reg [3:0] cnt;

	reg rw;
	reg [5:0] address;

	reg [7:0] mem [0:63];
	wire [7:0] V0 = mem[0];
	wire [7:0] V1 = mem[1];
	wire [7:0] V2 = mem[2];
	wire [7:0] V3 = mem[3];
	wire [7:0] V4 = mem[4];
	wire [7:0] V5 = mem[5];
	wire [7:0] V6 = mem[6];
	wire [7:0] V7 = mem[7];
	wire [7:0] V8 = mem[8];
	wire [7:0] V9 = mem[9];
	wire [7:0] V10 = mem[10];
	wire [7:0] V11 = mem[11];
	wire [7:0] V12 = mem[12];
	wire [7:0] V13 = mem[13];
	wire [7:0] V14 = mem[14];
	wire [7:0] V15 = mem[15];

	wire [7:0]check = mem[3];

	reg [7:0] byte_data_received, rev_data;
	reg [7:0] byte_data_sent, sent_data;
	
	always @(posedge CLK)begin
		if(SS_start)begin
			state <= `WAIT;
		end else if(SS_active)
		case (state)
			`WAIT: begin
				if(SCK_rise) begin
					cnt <= 4'b0000;
					byte_data_sent <= 8'b0;
					state <= `ADDR;
				end
			end
			`ADDR: begin
				if(SCK_rise) begin
					cnt <= cnt + 1;
					byte_data_sent <= {byte_data_sent[6:0], 1'b0};
				end else if(SCK_fall) begin
					byte_data_received <= {byte_data_received[6:0], MOSI};
					if(cnt == 4'b0111)
						state <= `ADDR_FIN;
				end
			end
			`ADDR_FIN: begin
				cnt <= 4'b0000;
				state <= `WAIT_DATA;
				rw <= byte_data_received[7];
				address <= byte_data_received[5:0];
				byte_data_sent <= (byte_data_received[7])?8'b0:mem[byte_data_received[5:0]];
			end
			`WAIT_DATA: begin
				if(SCK_rise) begin
					cnt <= 4'b0000;
					state <= `DATA;
				end
			end
			`DATA: begin
				if(SCK_rise) begin
					cnt <= cnt + 1;
					byte_data_sent <= {byte_data_sent[6:0], 1'b0};
				end else if(SCK_fall) begin
					byte_data_received <= {byte_data_received[6:0], MOSI};
					if(cnt == 4'b0111)
						state <= `DATA_FIN;
				end
			end
			`DATA_FIN: begin
				cnt <= 4'b0000;
				state <= `WAIT;
				if(rw)//write
					mem[address] <= byte_data_received;
			end
			default: ;
		endcase
	end

	assign MISO = (SS_active)?byte_data_sent[7]:1'b0;
endmodule