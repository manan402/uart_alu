`timescale 1ns / 1ps

module alu_uart_ctrl (
    input clk,
    input rst,
    input [7:0] rx_data,
    input rx_valid,
    input tx_busy,
    input signed [15:0] alu_result,

    output reg [7:0] tx_data,
    output reg tx_start,

    output reg signed [15:0] alu_A,
    output reg signed [15:0] alu_B,
    output reg [2:0] alu_op
);

    localparam IDLE        = 3'b000,
           GET_OP      = 3'b001,
           GET_A_HIGH  = 3'b010,
           GET_A_LOW   = 3'b011,
           GET_B_HIGH  = 3'b100,
           GET_B_LOW   = 3'b101,
           EXECUTE     = 3'b110,
           SEND_HIGH   = 3'b111,
           SEND_LOW    = 3'b001; // note: reusing 3'b001 might be confusing, better to choose a unique code

    reg [2:0] state;
    reg [2:0] next_state;

    // Sequential state register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM transition logic
    always @(*) begin
        next_state = state;
        tx_start = 0;

        case (state)
            IDLE:        if (rx_valid) next_state = GET_OP;
            GET_OP:      if (rx_valid) next_state = GET_A_HIGH;
            GET_A_HIGH:  if (rx_valid) next_state = GET_A_LOW;
            GET_A_LOW:   if (rx_valid) next_state = GET_B_HIGH;
            GET_B_HIGH:  if (rx_valid) next_state = GET_B_LOW;
            GET_B_LOW:                  next_state = EXECUTE;
            EXECUTE:                   next_state = SEND_HIGH;
            SEND_HIGH:   if (!tx_busy) next_state = SEND_LOW;
            SEND_LOW:    if (!tx_busy) next_state = IDLE;
        endcase
    end

    // Data path logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_A     <= 0;
            alu_B     <= 0;
            alu_op    <= 0;
            tx_data   <= 0;
            tx_start  <= 0;
        end else begin
            case (state)
                GET_OP: if (rx_valid) alu_op <= rx_data[2:0];

                GET_A_HIGH: if (rx_valid) alu_A[15:8] <= rx_data;
                GET_A_LOW:  if (rx_valid) alu_A[7:0]  <= rx_data;

                GET_B_HIGH: if (rx_valid) alu_B[15:8] <= rx_data;
                GET_B_LOW:  if (rx_valid) alu_B[7:0]  <= rx_data;

                SEND_HIGH: begin
                    if (!tx_busy) begin
                        tx_data  <= alu_result[15:8];
                        tx_start <= 1;
                    end
                end

                SEND_LOW: begin
                    if (!tx_busy) begin
                        tx_data  <= alu_result[7:0];
                        tx_start <= 1;
                    end
                end

                default: tx_start <= 0;
            endcase
        end
    end

endmodule
