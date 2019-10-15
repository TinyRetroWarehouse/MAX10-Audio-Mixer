`ifdef SIMULATION
    `define POR_MAX 16'h000f // period of power on reset
`else  // Real FPGA
    `define POR_MAX 16'hffff  // period of power on reset
`endif

module I2S_ADC
    #(parameter bitNum = 24)
	(
		AD_DAT,MCLK,LRCLK,SCLK,DATA_L,DATA_R
	);

	//ADC PCM1808PWR SlaveMode
	input MCLK;		//PIN_132
	input LRCLK;	//PIN_130
	input SCLK;		//PIN_131
	input AD_DAT;	//PIN_124
	output signed [bitNum-1:0]DATA_L;
	output signed [bitNum-1:0]DATA_R;


	//--------------------------
	// Internal Power on Reset
	//--------------------------
	wire res_n;            // Internal Reset Signal
	reg  por_n;            // should be power-up level = Low
	reg  [15:0] por_count; // should be power-up level = Low
	//
	always @(posedge MCLK)
	begin
		if (por_count != `POR_MAX)
		begin
			por_n <= 1'b0;
			por_count <= por_count + 16'h0001;
		end
		else
		begin
			por_n <= 1'b1;
			por_count <= por_count;
		end
	end
	//
	assign res_n = por_n;


	/* MCLK 12.288MHz
	 * SCK 3.072MHz	MCLK/4
	 * LRLCK 48KHz	MCLK/256
	 */
	wire signed [bitNum-1:0]DATA_L;
	wire signed [bitNum-1:0]DATA_R;

	i2s_s2p #(.bitNum(bitNum)) ADC  (
	//clock_bit, clock_lr, data_in, data_l,data_r
		.clock_bit(SCLK), .data_in(AD_DAT), .clock_lr(LRCLK), .data_l(DATA_L), .data_r(DATA_R)
	);

endmodule