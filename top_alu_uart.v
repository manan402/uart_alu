`timescale 1ns / 1ps

module top_uart_alu (
    input clk,
    input rst,
    input rx,
    output tx
);

    // UART RX interface
    wire [7:0] rx_data;
    wire rx_valid;

    // ALU interface
    wire signed [15:0] alu_A;
    wire signed [15:0] alu_B;
    wire [2:0] alu_op;
    wire signed [15:0] alu_result;

    // UART TX interface
    wire [7:0] tx_data;
    wire tx_start;
    wire tx_busy;

    // Instantiate UART Receiver
    uart_rx #(
        .CLK_FREQ(125000000),   // Adjust as needed
        .BAUD_RATE(230400)
    ) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    // Instantiate ALU control FSM
    alu_uart_ctrl ctrl_inst (
        .clk(clk),
        .rst(rst),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .tx_busy(tx_busy),
        .alu_result(alu_result),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .alu_A(alu_A),
        .alu_B(alu_B),
        .alu_op(alu_op)
    );

    // Instantiate ALU Core
    top_alu #(.N(16)) alu_core (
        .a(alu_A),
        .b(alu_B),
        .opcode({1'b0, alu_op}),  // pad to 4 bits if needed
        .result(alu_result),
        .flags()  // Optional: not used in UART flow
    );

    // Instantiate UART Transmitter
    uart_tx #(
        .CLK_FREQ(125000000),  // Adjust as needed
        .BAUD_RATE(230400)
    ) uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .data_in(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

endmodule
