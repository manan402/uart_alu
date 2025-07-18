module shift_operation #(parameter N = 16)(
    input signed [N-1:0] data_in,
    input  [3:0] shift_amount,
    input shift_operation, //1 = left, 0 = right
    output signed [N-1:0] out
);

    assign out = (shift_operation) ? data_in << shift_amount : data_in >>> shift_amount;

endmodule

/*
module shift_operation_tb;
    parameter N = 16;
    reg shift_operation; 
    reg  signed [N-1:0] data_in;
    reg   [3:0] shift_amount;
    wire signed [N-1:0] result;
    integer i;

    shift_operation #(.N(N)) uut (.data_in(data_in),.shift_amount(shift_amount),.shift_operation(shift_operation),.out(result));
    
    
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            if ( i < 3 ) begin
                $display("___Left___"); shift_operation = 1;
            end
            else begin
                $display("___right___"); shift_operation = 0;
            end
            data_in = $random;  
            shift_amount = $urandom & 4'b1111;
            #5; 
            $display("time         = %0t", $time);
            $display("data_in      = %016b (%05d)", data_in, data_in);
            $display("shift_amount = %016b (%05d)", shift_amount, shift_amount);
            $display("Result       = %016b (%05d)", result, result);
            $display("--------------------------------------------------");
        end

        $finish;
    end

endmodule
*/