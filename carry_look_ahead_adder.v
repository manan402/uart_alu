module cla_adder #(parameter N = 16)(
    input  signed [N-1:0] a, b,
    output signed [N-1:0] sum,
    output [4:0] flags  // {V, C, N, Z, P}
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
            assign sum[i] = p[i] ^ carry[i];
        end
    endgenerate


    wire zero_flag  = (sum == 0);
    wire negative_flag = (sum[15] == 1);
    wire carry_flag    = carry[N];

    // Overflow if: operands have same sign, result has opposite sign
    wire overflow_flag = (~a[N-1] & ~b[N-1] & sum[N-1]) | 
                         ( a[N-1] &  b[N-1] & ~sum[N-1]);

    // Parity Flag: 1 if even parity (even number of 1s)
    wire parity_flag = ~^sum;  

    assign flags = {overflow_flag, carry_flag, negative_flag, zero_flag, parity_flag};

endmodule

module cla_tb;
    parameter N = 16;

    reg  signed [N-1:0] a, b;
    wire signed [N-1:0] sum;
    wire [4:0] flags; // {V, C, N, Z, P}

    integer i;

    cla_adder #(.N(N)) uut (.a(a), .b(b), .sum(sum), .flags(flags));

    initial begin
        for (i = 0; i < 6; i = i + 1) begin
            if (i < 3) begin
                a = $random; //$urandom_range(0, 32767);   
                b = $random; 
            end else begin
                a = -$random;  
                b = -$random; 
            end

            #5; 

            $display("Test %0d: a = %0d, b = %0d -> sum = %0d, sum = %016b | Flags = {V=%b, C=%b, N=%b, Z=%b, P=%b}",
            i+1, a, b, sum, sum,
            flags[4], flags[3], flags[2], flags[1], flags[0]);
        end

        $finish;
    end
endmodule
