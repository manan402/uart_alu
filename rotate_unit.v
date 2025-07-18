module rotate_operation #(parameter N = 16)(
    input  wire [N-1:0] data_in,
    input  wire [3:0]  rot_amt,
    input  wire  rotate_operation, // 1: left, 0: right
    output wire [N-1:0] data_out
);

    wire [N-1:0] left_rot, right_rot;

    assign left_rot  = (data_in << rot_amt) | (data_in >> (16 - rot_amt));
    assign right_rot = (data_in >> rot_amt) | (data_in << (16 - rot_amt));
    assign data_out = rotate_operation ? left_rot : right_rot;

endmodule


/*
module rotate_operation_tb;

    parameter N = 16;

    reg  [N-1:0] data_in;
    reg  [3:0]  rot_amt;
    reg  rotate_operation; // 1: left, 0: right
    wire [N-1:0] data_out;
    integer i;

    rotate_operation #(.N(N)) uut (.data_in(data_in),.rot_amt(rot_amt),.rotate_operation(rotate_operation),.data_out(data_out));
        
    
    initial begin
        for(i = 1; i < 5; i++)begin
            if ( i < 3 ) begin
                $display("___Left___"); rotate_operation = 1;
            end
            else begin
                $display("___right___"); rotate_operation = 0;
            end
            data_in = i << 3;
            rot_amt = i;
            #2;

            $display("time         = %0t", $time);
            $display("data_in      = %016b (%05d)", data_in, data_in);
            $display("roate_amount = %016b (%05d)", rot_amt, rot_amt);
            $display("Result       = %016b (%05d)", data_out, data_out);
            $display("--------------------------------------------------");
        end
    end

endmodule
*/