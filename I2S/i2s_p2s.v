module i2s_p2s
    #(parameter bitNum = 16)
    (clock_in, clock_bit, clock_lr, data_out, data_l, data_r);
    input clock_in;
    input clock_bit;
    input clock_lr;
    output reg data_out;
    input [bitNum-1:0] data_l;
    input [bitNum-1:0] data_r;

    reg [64:0]data_lr65_tmp;
    reg prev_clock_lr;
    reg prev_clock_bit;


    always@(negedge clock_in)
    begin
        if (prev_clock_bit == 1 && clock_bit == 0) begin
            data_out = data_lr65_tmp[64];
            data_lr65_tmp = data_lr65_tmp << 1;
            end
        else if (prev_clock_bit == 0 && clock_bit == 1) begin
            if (prev_clock_lr == 1 && clock_lr == 0) begin
                data_lr65_tmp = 65'b0;
                begin
                    data_lr65_tmp[64:64-bitNum+1] <= data_l[bitNum-1:0];
                    data_lr65_tmp[32:32-bitNum+1] <= data_r[bitNum-1:0];
                end
            end
            prev_clock_lr = clock_lr;
            end
        prev_clock_bit = clock_bit;
    end

endmodule