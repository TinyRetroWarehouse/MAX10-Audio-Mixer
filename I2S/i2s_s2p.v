module i2s_s2p
    #(parameter bitNum = 16)
    (clock_bit, clock_lr, data_in, data_l,data_r);
    input clock_bit;
    input clock_lr;
    input data_in;

    output [bitNum-1:0]data_l;
    output [bitNum-1:0]data_r;
    reg signed [bitNum-1:0]data_l;
    reg signed [bitNum-1:0]data_r;

    reg [64:0]data64_tmp;

    reg previous_clock_lr;

    always @ (posedge clock_bit)
    begin
        data64_tmp = data64_tmp << 1;
        data64_tmp[0] = data_in;
        if (previous_clock_lr == 1 && clock_lr == 0)
            begin
                data_l[bitNum-1:0] <= data64_tmp[63:63-bitNum+1];
                data_r[bitNum-1:0] <= data64_tmp[31:31-bitNum+1];
            end
        previous_clock_lr = clock_lr;
    end
endmodule