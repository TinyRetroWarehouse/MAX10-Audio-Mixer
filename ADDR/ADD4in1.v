module ADD4in1#
	(
	parameter BIT=24
	)(
		CLK,
		in1_L,
		in1_R,
		in2_L,
		in2_R,
		in3_L,
		in3_R,
		in4_L,
		in4_R,
		out_L,
		out_R
	);

	input CLK;
	input signed [BIT-1:0] in1_L, in1_R, in2_L, in2_R, in3_L, in3_R, in4_L, in4_R;
	output signed [BIT-1:0] out_L, out_R;

	reg signed [BIT-1:0] out_L, out_R;

	always @(posedge CLK) begin
		out_L <= $signed(in1_L) + $signed(in2_L) + $signed(in3_L) + $signed(in4_L);
		out_R <= $signed(in1_R) + $signed(in2_R) + $signed(in3_R) + $signed(in4_R);
	end
endmodule