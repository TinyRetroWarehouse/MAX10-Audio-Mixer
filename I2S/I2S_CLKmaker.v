module I2S_CLKmaker (
	MCLK,RST,SCLK,LRCLK
);
	input MCLK;
	input RST;
	output SCLK;
	output LRCLK;
	//SCLK 1/8,LRCLK,256/1
	reg [2:0]cnt_SCLK;
	reg [8:0]cnt_LRCLK;
	assign SCLK = cnt_SCLK[1];
	assign LRCLK = cnt_LRCLK[7];

	always @(posedge MCLK) begin
		if(~RST) begin
			cnt_SCLK <= 3'b110;
		end else begin
			cnt_SCLK <= cnt_SCLK + 3'b1;
		end
	end
	always @(negedge MCLK) begin
		if(~RST) begin
			cnt_LRCLK <= 9'b110000000;
		end else begin
			cnt_LRCLK <= cnt_LRCLK + 9'b1;
		end
	end

endmodule