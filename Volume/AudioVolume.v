module AUDIOVOLUME #
	(
	parameter BIT=24,
	parameter VOL_BIT=8
	)(
		CLK,
		in_L,
		in_R,
		out_L,
		out_R,
		Volume
	);

	input signed [BIT-1:0] in_L, in_R;
	input [VOL_BIT-1:0] Volume;
	input CLK;
	output signed [BIT-1:0] out_L, out_R;

	wire signed [BIT-1:0] out_L, out_R;

	reg signed [BIT+VOL_BIT-1:0] temp_L, temp_R;
	assign out_L = temp_L[BIT+VOL_BIT-1:VOL_BIT-1];
	assign out_R = temp_R[BIT+VOL_BIT-1:VOL_BIT-1];

	always @(posedge CLK) begin
		temp_L <= ($signed({{VOL_BIT{in_L[BIT-1]}},in_L}) * $signed({1'b0,Volume}));
		temp_R <= ($signed({{VOL_BIT{in_R[BIT-1]}},in_R}) * $signed({1'b0,Volume}));
	end

endmodule