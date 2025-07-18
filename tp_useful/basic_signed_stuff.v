module signed_vs_unsigned;
  // Declare one signed and one unsigned 4-bit value
  reg signed [3:0] a;        // signed
  reg         [3:0] b;       // unsigned

  reg signed [4:0] result_signed;
  reg [4:0] result_unsigned;

  initial begin
    // Assign values
    a = -3;      // binary: 1101
    b = 4'b0010; // 2 in unsigned

    // Mixing signed and unsigned directly (default promotion rules apply)
    result_unsigned = a + b;              // This may cause unintended behavior
    result_signed   = $signed(a) + $signed(b); // Explicitly treating both as signed

    // Display values
    $display("a (signed) = %0d (%b)", a, a);  // -3
    $display("b (unsigned) = %0d (%b)", b, b); // 2

    $display("a + b (mixed, default)     = %0d (%b)", result_unsigned, result_unsigned);
    $display("a + b (explicit signed)    = %0d (%b)", result_signed, result_signed);
  end
endmodule
