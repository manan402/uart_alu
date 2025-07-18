module cla_adder #(parameter N = 16)(
    input  signed [N-1:0] a, b,
    output signed [N-1:0] result,
    output [3:0] flags  // {V, N, Z, P}
);

    wire [N-1:0] g, p;
    wire [N:0] carry;

    assign carry[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign g[i] = a[i] & b[i];
            assign p[i] = a[i] ^ b[i];
            assign carry[i+1] = g[i] | (p[i] & carry[i]);
            assign result[i] = p[i] ^ carry[i];
        end
    endgenerate

    wire zero_flag     = (result == 0);
    wire negative_flag = result[N-1];
    wire overflow_flag = (a[N-1] & b[N-1] & ~result[N-1]) |
                         (~a[N-1] & ~b[N-1] & result[N-1]);
    wire parity_flag   = ~^result; //even parity

    assign flags = {overflow_flag, negative_flag, zero_flag, parity_flag};

endmodule


module cla_tb;
    parameter N = 16;

    reg  signed [N-1:0] a, b;
    wire signed [N-1:0] result;
    wire [3:0] flags; // {V, N, Z, P}

    integer i;

    cla_adder #(.N(N)) uut (.a(a), .b(b), .result(result), .flags(flags));

    initial begin
        for (i = 0; i < 6; i = i + 1) begin
            a = $random; 
            b = $random; 
            #5;

            $display("time  = %0t", $time);
            $display("a     = %016b (%05d)", a, a);
            $display("b     = %016b (%05d)", b, b);
            $display("a + b = %016b (%05d)", result, result);
            $display("Flags = {V=%b, N=%b, Z=%b, P=%b}", 
                flags[3], flags[2], flags[1], flags[0]);
            $display("--------------------------------------------------");
       
        end

        $finish;
    end
endmodule
