module logical_operation #(parameter N = 16)(
    input  signed [N-1:0] a,
    input  signed [N-1:0] b,
    input  [3:0] opcode,
    output reg signed [N-1:0] wout
);

    localparam AND_OP  = 3'd0;
    localparam OR_OP   = 3'd1;
    localparam XOR_OP  = 3'd2;
    localparam NAND_OP = 3'd3;
    localparam NOR_OP  = 3'd4;
    localparam XNOR_OP = 3'd5;
    localparam NOT_OP  = 3'd6;      

    always @(*) begin
        case (opcode)
            AND_OP:  out = a & b;
            OR_OP:   out = a | b;
            XOR_OP:  out = a ^ b;
            NAND_OP: out = ~(a & b);
            NOR_OP:  out = ~(a | b);
            XNOR_OP: out = ~(a ^ b);
            NOT_OP:  out = ~a;
            default: out = {N{1'bx}};
        endcase
    end
endmodule


module logical_operation_tb;
    parameter N = 16;
    integer i;
    reg signed [N-1:0]a,b;
    reg  [3:0] opcode;
    wire signed [N-1:0]out;

    logical_operation  #(.N(N)) uut (.a(a), .b(b), .opcode(opcode), .out(out));


    initial begin
        #2;
        $display("0 = &, 1 = |, 2 = ^, 3 = ~&, 4 = ~|, 5 = ~^, 6 = ~");

        for(i = 0; i < 7; i = i+1)begin
            $display("----------------------------");
            opcode = i;
            $display("operation no = %0d", i);
            repeat(2) begin
                a = $random % 2322;
                b = -($urandom);
                #2;

                $display("time = %0t", $time);
                $display("a    = %016b, (%05d)", a, a);
                $display("a    = %016b, (%05d)", b, b);
                $display("out  = %016b  (%05d)\n", out, out);
            end
        end
    end

    initial begin

    end
endmodule