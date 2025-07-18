module signed_sub_with_flags #(parameter N = 16)(
    input  signed [N-1:0] a,
    input  signed [N-1:0] b,
    output signed [N-1:0] result,
    output [3:0] flags    // {V, N, Z, P}
);

    assign result = a + (~b + 1);

    wire zero_flag     = (result == 0);
    wire negative_flag = result[N-1];
    wire overflow_flag =  (a[N-1] != b[N-1]) && (result[N-1] != a[N-1]);
    wire parity_flag   = ~^result; //even parity

    assign flags = {overflow_flag, negative_flag, zero_flag, parity_flag};

endmodule


module tb_signed_sub_with_flags;
    parameter N = 16;

    reg  signed [N-1:0] a, b;
    wire signed [N-1:0] result;
    wire [3:0] flags; // {V, N, Z, P}

    integer i;

    signed_sub_with_flags #(.N(N)) uut ( .a(a), .b(b), .result(result), .flags(flags));
    

    initial begin
        $display("Format: a - b = Result | Flags = {V, N, Z, P}\n");

        for (i = 0; i < 8; i = i + 1) begin
            a = $random; 
            b = $random; 

            if (i == 3) begin
                a =  20_200;
                b = -20_200;
            end
            
            if (i == 2) begin
                a =  20_200;
                b = a;
            end
            
            #5; 
            $display("time  = %0t", $time);
            $display("a     = %016b (%05d)", a, a);
            $display("b     = %016b (%05d)", b, b);
            $display("a - b = %016b (%05d)", result, result);
            $display("Flags = {V=%b, N=%b, Z=%b, P=%b}", 
                flags[3], flags[2], flags[1], flags[0]);
            $display("--------------------------------------------------");
        end

        $finish;
    end

endmodule
