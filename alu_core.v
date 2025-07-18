module top_alu #(parameter N = 16)(
    input  signed [N-1:0] a,
    input  signed [N-1:0] b,
    input  [3:0] opcode,
    output reg signed [N-1:0] result,
    output reg [3:0] flags  // {V, N, Z, P}
);

    // === Internal Wires ===
    wire signed [N-1:0] logic_out, add_out, sub_out, shift_out, rotate_out;
    wire [3:0] add_flags, sub_flags;

    // === Logical Operations ===
    logical_operation #(.N(N)) u_logical (
        .a(a), .b(b), .opcode(opcode),
        .out(logic_out)
    );

    // === Adder ===
    cla_adder #(.N(N)) u_adder (
        .a(a), .b(b),
        .result(add_out),
        .flags(add_flags)
    );

    // === Subtractor ===
    signed_sub_with_flags #(.N(N)) u_sub (
        .a(a), .b(b),
        .result(sub_out),
        .flags(sub_flags)
    );

    // === Shift ===
    shift_operation #(.N(N)) u_shift (
        .data_in(a),
        .shift_amount(b[3:0]),
        .shift_operation(opcode[0]), //1 = left, 0 = right
        .out(shift_out)
    );

    // === Rotate ===
    rotate_operation #(.N(N)) u_rotate (
        .data_in(a),
        .rot_amt(b[3:0]),
        .rotate_operation(opcode[0]), // 1 for left, 0=right
        .data_out(rotate_out)
    );

    // === Internal Registers ===
    reg signed [N-1:0] mul_out, div_out;
    reg [3:0] mul_flags, div_flags;

    // === ALU Operation Selector ===
    always @(*) begin
        // Default
        result = {N{1'bx}};
        flags  = 4'b0000;

        case (opcode)
            // 0 = AND, 1 = OR, 2 = XOR, 3 = NAND, 4 = NOR, 5 = XNOR, 6 = NOT
            4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd6: begin
                result = logic_out;
                flags  = {1'b0, logic_out[N-1], (logic_out == 0), ~^logic_out};
            end

            // Addition
            4'd7: begin
                result = add_out;
                flags  = add_flags;
            end

            // Subtraction
            4'd8: begin
                result = sub_out;
                flags  = sub_flags;
            end

            // Multiplication
            4'd9: begin
                mul_out   = a * b;
                result    = mul_out;
                mul_flags = {1'b0, mul_out[N-1], (mul_out == 0), ~^mul_out};
                flags     = mul_flags;
            end

            // Division
            4'd10: begin
                if (b != 0) begin
                    div_out   = a / b;
                    result    = div_out;
                    div_flags = {1'b0, div_out[N-1], (div_out == 0), ~^div_out};
                    flags     = div_flags;
                end else begin
                    result = {N{1'bx}};
                    flags  = 4'b1000; // overflov divide-by-zero
                end
            end

            // Shifting (Right = 12, Left = 13)
            4'd12, 4'd13: begin
                result = shift_out;
                flags  = {1'b0, shift_out[N-1], (shift_out == 0), ~^shift_out};
            end

            // Rotating (Right = 14, Left = 15)
            4'd14, 4'd15: begin
                result = rotate_out;
                flags  = {1'b0, rotate_out[N-1], (rotate_out == 0), ~^rotate_out};
            end

            default: begin
                result = {N{1'bx}};
                flags  = 4'bxxxx;
            end
        endcase
    end

endmodule


`timescale 1ns/1ps

module top_alu_tb;
    parameter N = 16;

    reg signed [N-1:0] a, b;
    reg [3:0] opcode;
    wire signed [N-1:0] result;
    wire [3:0] flags;

    // Instantiate the ALU
    top_alu #(.N(N)) uut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .flags(flags)
    );

    // Task to display results neatly
    task display_result;
        input [3:0] op;
        begin
            $display("Opcode = %0d", op);
            $display("time  = %0t", $time);
            $display("a     = %016b (%05d)", a, a);
            $display("b     = %016b (%05d)", b, b);
            $display("result = %016b (%05d)", result, result);
            $display("Flags = {V=%b, N=%b, Z=%b, P=%b}", 
                flags[3], flags[2], flags[1], flags[0]);
            $display("--------------------------------------------------");
        end
    endtask

    initial begin
        $display("Starting ALU Testbench...\n");

        // Test logical ops (0 to 6)
        for (opcode = 0; opcode <= 6; opcode = opcode + 1) begin
            a = 16'hAAAA;  // 1010101010101010
            b = 16'h5555;  // 0101010101010101
            #10;
            display_result(opcode);
        end

        // Test Addition (7)
        opcode = 7; a = 1234; b = 4321; #10;
        display_result(opcode);

        opcode = 7; a = 16'hffff; b = 4321; #10;
        display_result(opcode);

        // Test Subtraction (8)
        opcode = 8; a = 5000; b = 1234; #10;
        display_result(opcode);

        opcode = 8; a = 5000; b = 5000; #10;
        display_result(opcode);

        opcode = 8; a = 20_200; b = -20_200; #10;
        display_result(opcode);
        
        // Test Multiplication (9)
        opcode = 9; a = 100; b = 20; #10;
        display_result(opcode);

        // Test Division (10)
        opcode = 10; a = 100; b = 20; #10;
        display_result(opcode);

        // Division by zero
        opcode = 10; a = 100; b = 0; #10;
        display_result(opcode);

        // Shift Right (12)
        opcode = 12; a = 16'h8000; b = 4'd3; #10;
        display_result(opcode);

        // Shift Left (13)
        opcode = 13; a = 16'h0001; b = 4'd3; #10;
        display_result(opcode);

        // Rotate Right (14)
        opcode = 14; a = 16'h8001; b = 4'd4; #10;
        display_result(opcode);

        // Rotate Left (15)
        opcode = 15; a = 16'h0001; b = 4'd4; #10;
        display_result(opcode);

        $display("\nTestbench completed.");
        $finish;
    end
endmodule
