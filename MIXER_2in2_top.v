module MIXER_2in2_top(CLK48, RST, MCLK, SCLK, LRCLK, AD_DAT, DA_DAT, SPI_CLK, SPI_SS, SPI_MOSI, SPI_MISO);
	localparam bitNum = 24;
	localparam VOL_BIT = 8;
	localparam AD_NUM = 2;
	localparam DA_NUM = 2;

	//General
	input CLK48, RST;
	//AD/DA
	output MCLK, SCLK, LRCLK;
	input [AD_NUM-1:0] AD_DAT;
	output [DA_NUM-1:0] DA_DAT;
	//SPI
	input SPI_CLK, SPI_SS, SPI_MOSI;
	output SPI_MISO;


	wire MCLK, SCLK, LRCLK;

	PLL pll(.inclk0(CLK48), .c0(MCLK));

	I2S_CLKmaker clkmaker(.MCLK(MCLK), .RST(RST), .SCLK(SCLK), .LRCLK(LRCLK));

	wire [bitNum-1:0] AD_L [0:AD_NUM-1];
	wire [bitNum-1:0] AD_R [0:AD_NUM-1];
	wire [bitNum-1:0] DA_L [0:DA_NUM-1];
	wire [bitNum-1:0] DA_R [0:DA_NUM-1];
	wire [bitNum-1:0] Pool_L [0:DA_NUM-1][0:AD_NUM-1];
	wire [bitNum-1:0] Pool_R [0:DA_NUM-1][0:AD_NUM-1];
	wire [bitNum-1:0] DA_buf_L [0:DA_NUM-1];
	wire [bitNum-1:0] DA_buf_R [0:DA_NUM-1];


	wire [7:0] Vol [0:31];

	reg [4:0] cnt;
	always @(posedge CLK48) begin
		cnt <= cnt + 1;
	end
	wire sigclk = cnt[4];

	SPI_Slave spi_s (
		.CLK(sigclk),
		.SCK(SPI_CLK),
		.SS(SPI_SS),
		.MOSI(SPI_MOSI),
		.MISO(SPI_MISO),
		.V0(Vol[0]),
		.V1(Vol[1]),
		.V2(Vol[2]),
		.V3(Vol[3]),
		.V4(Vol[4]),
		.V5(Vol[5]),
		.V6(Vol[6]),
		.V7(Vol[7]),
		.V8(Vol[8]),
		.V9(Vol[9]),
		.V10(Vol[10]),
		.V11(Vol[11]),
		.V12(Vol[12]),
		.V13(Vol[13]),
		.V14(Vol[14]),
		.V15(Vol[15]),
		.V16(Vol[16]),
		.V17(Vol[17]),
		.V18(Vol[18]),
		.V19(Vol[19]),
		.V20(Vol[20]),
		.V21(Vol[21]),
		.V22(Vol[22]),
		.V23(Vol[23]),
		.V24(Vol[24]),
		.V25(Vol[25]),
		.V26(Vol[26]),
		.V27(Vol[27]),
		.V28(Vol[28]),
		.V29(Vol[29]),
		.V30(Vol[30]),
		.V31(Vol[31]),
	);

//AD
	genvar i, j, cnt_vol;
	generate
		for(i = 0; i < AD_NUM; i = i + 1) begin: GenAD
			I2S_ADC #(.bitNum(bitNum)) ad (.AD_DAT(AD_DAT[i]), .MCLK(MCLK), .LRCLK(LRCLK), .SCLK(SCLK), .DATA_L(AD_L[i]), .DATA_R(AD_R[i]));
		end
	endgenerate

//MatrixVol
	generate
		for(i = 0; i < AD_NUM; i = i + 1) begin: GenVOL_AD
			for(j = 0; j < DA_NUM; j = j + 1) begin: GenVol_DA
				AUDIOVOLUME #(.BIT(bitNum), .VOL_BIT(VOL_BIT)) vol_0_0 (.CLK(LRCLK), .in_L(AD_L[i]), .in_R(AD_R[i]), .Volume(Vol[DA_NUM*i+j]), .out_L(Pool_L[j][i]), .out_R(Pool_R[j][i]));
			end
		end
	endgenerate

//ADD
	generate
		for(i = 0; i < DA_NUM; i = i + 1) begin: GenVOL_ADD
			ADD2in1 #(.BIT(bitNum)) add0 (
				.CLK(LRCLK),
				.in1_L(Pool_L[i][0]),
				.in1_R(Pool_R[i][0]),
				.in2_L(Pool_L[i][1]),
				.in2_R(Pool_R[i][1]),
				.out_L(DA_buf_L[i]),
				.out_R(DA_buf_R[i])
			);
		end
	endgenerate


//DA_VOL
	generate
		for(i = 0; i < DA_NUM; i = i + 1) begin: GenDA_VOL
			AUDIOVOLUME #(.BIT(bitNum), .VOL_BIT(VOL_BIT)) vol_da (.CLK(LRCLK), .in_L(DA_buf_L[i]), .in_R(DA_buf_R[i]), .Volume(Vol[DA_NUM*AD_NUM+i]), .out_L(DA_L[i]), .out_R(DA_R[i]));
		end
	endgenerate

//DA
	generate
		for(i = 0; i < DA_NUM; i = i + 1) begin: GenDA
			I2S_DAC #(.bitNum(bitNum)) da (.DA_DAT(DA_DAT[i]), .MCLK(MCLK), .LRCLK(LRCLK), .SCLK(SCLK), .DATA_L(DA_L[i]), .DATA_R(DA_R[i]));
		end
	endgenerate


endmodule