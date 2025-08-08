`timescale 1ns / 1ps

module uart_rx #(
    parameter CLK_FREQ = 1250000000,    // 125 MHz
    parameter BAUD_RATE = 230400
)(
    input rx,
    input rst,
    input clk,
    output reg [7:0] data_out,
    output reg data_valid
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE; // == 543
    localparam IDLE  = 3'b000, START = 3'b001, DATA = 3'b010, STOP = 3'b011, DONE = 3'b100;

    reg [2:0] state = IDLE;
    reg [2:0] bit_index = 0;
    reg [7:0] rx_shift = 0;
    reg [15:0] clk_count = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            data_out <= 0;
            data_valid <= 0;
            rx_shift <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_valid <= 0;
                    if (rx == 0) begin  // start bit detected
                        state <= START;
                        clk_count <= 0;
                    end
                end

                START: begin
                    if (clk_count == (CLKS_PER_BIT / 2)) begin
                        if (rx == 0) begin
                            clk_count <= 0;
                            state <= DATA;
                            bit_index <= 0;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_shift[bit_index] <= rx;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else
                            state <= STOP;
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        state <= DONE;
                        data_out <= rx_shift;
                        data_valid <= 1;
                        clk_count <= 0;
                    end
                end

                DONE: begin
                    state <= IDLE;
                    data_valid <= 0;
                end
            endcase
        end
    end
endmodule