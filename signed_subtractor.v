module signed_sub_with_flags #(parameter N = 16)(
    input  signed [N-1:0] A,
    input  signed [N-1:0] B,
    output signed [N-1:0] result,
    output [4:0] flags    // {V, C, N, Z, P}
);

    wire signed [N:0] full_result; // 1 extra bit for overflow
    wire signed [N-1:0] negB;
    wire [4:0] flag;

    assign full_result = A + ((~B) + 1);   // A - B = A + (-B)
    assign result = full_result[N-1:0];   // Truncate result to N bits

    // Overflow (V): signed overflow if A and B have opposite signs, and result flips sign
    assign flag[4] = (A[N-1] != B[N-1]) && (result[N-1] != A[N-1]);

    // Carry/Borrow (C): unsigned borrow → A < B
    assign flag[3] = A < B;

    // Negative (N): result is negative
    assign flag[2] = result[N-1];

    // Zero (Z): result is zero
    assign flag[1] = (result == 0);

    // Parity (P): even number of 1s → parity = 1
    assign flag[0] = ~^result; 

    assign flags = flag;

endmodule


`timescale 1ns/1ps

module tb_signed_sub_with_flags;

    parameter N = 16;

    reg  signed [N-1:0] A, B;
    wire signed [N-1:0] result;
    wire [4:0] flags; // {V, C, N, Z, P}

    integer i;

    signed_sub_with_flags #(.N(N)) uut (
        .A(A),
        .B(B),
        .result(result),
        .flags(flags)
    );

    initial begin
        $display("Format: A - B = Result | Flags = {V, C, N, Z, P}\n");


        for (i = 0; i < 2; i = i + 1) begin
            if (i < 3) begin
                // Positive inputs (simulate safe range: 0 to 32767)
                A = $urandom_range(0, 32767);
                B = $urandom_range(0, 32767);
            end else begin
                // Negative inputs (simulate signed: -32768 to -1)
                A = -$urandom_range(0, 32767);
                B = -$urandom_range(0, 32767);
            end
            
            //just to check for overflow
            A = 20000;
            B = -20000;
            
            #5; 
            $display("Test %0d:", i+1);
            $display("  A = %0d (%b)", A, A);
            $display("  B = %0d (%b)", B, B);
            $display("  A - B = %0d (%b)", result, result);
            $display("  Flags = {V=%b, C=%b, N=%b, Z=%b, P=%b}", 
                flags[4], flags[3], flags[2], flags[1], flags[0]);
            $display("--------------------------------------------------");
        end

        $finish;
    end

endmodule
