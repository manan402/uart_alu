module uart_tx #(
    parameter CLK_FREQ = 1250000000,    // 125 MHz
    parameter BAUD_RATE = 230400

)(
    input clk,
    input rst,
    input [7:0] data_in,
    input tx_start,
    output reg tx,
    output reg tx_busy
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam TOTAL_BITS = 10; // 1 start + 8 data + 1 stop

    reg [3:0] bit_index = 0;
    reg [15:0] clk_count = 0;
    reg [9:0] tx_shift = 10'b1111111111;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1'b1;  // idle line
            tx_busy <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            if (tx_start && !tx_busy) begin
                tx_shift <= {1'b1, data_in, 1'b0};  // [stop][data][start]
                tx_busy <= 1;
                bit_index <= 0;
                clk_count <= 0;
                tx <= 1'b0;  // start bit out immediately
            end else if (tx_busy) begin
                if (clk_count < CLKS_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    bit_index <= bit_index + 1;
                    if (bit_index < TOTAL_BITS - 1) begin
                        tx <= tx_shift[bit_index + 1];
                    end else begin
                        tx_busy <= 0;
                        tx <= 1'b1;  // back to idle
                    end
                end
            end
        end
    end
endmodule
