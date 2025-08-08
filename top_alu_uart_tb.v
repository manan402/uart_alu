`timescale 1ns / 1ps

module top_uart_alu_tb;

    reg clk;
    reg rst;
    reg rx;
    wire tx;

    top_uart_alu uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx)
    );

    // Clock generation: 50MHz
    always #10 clk = ~clk;

    // UART byte sender task
    task uart_send_byte;
        input [7:0] data;
        integer i;
        begin
            rx = 0; // Start bit
            #(104160); // 1 bit duration @ 9600 bps

            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(104160);
            end

            rx = 1; // Stop bit
            #(104160);
        end
    endtask

    // Stimulus
    initial begin
        // Initial states
        clk = 0;
        rx = 1; // UART idle high
        rst = 1;
        #100;
        rst = 0;

        #500;

        // Test ADD (opcode 0000): 25 + 17 = 42
        uart_send_byte(8'b0000_0000);  // opcode
        uart_send_byte(8'd25);         // A
        uart_send_byte(8'd17);         // B
        #2000000;

        // Test SUB (opcode 0001): 60 - 20 = 40
        uart_send_byte(8'b0000_0001);  // opcode
        uart_send_byte(8'd60);         // A
        uart_send_byte(8'd20);         // B
        #2000000;

        // Test AND (opcode 0010): 12 & 5 = 4
        uart_send_byte(8'b0000_0010);  // opcode
        uart_send_byte(8'd12);         // A
        uart_send_byte(8'd5);          // B
        #2000000;

        // Test OR (opcode 0011): 12 | 5 = 13
        uart_send_byte(8'b0000_0011);  // opcode
        uart_send_byte(8'd12);         // A
        uart_send_byte(8'd5);          // B
        #2000000;

        // Test XOR (opcode 0100): 12 ^ 5 = 9
        uart_send_byte(8'b0000_0100);  // opcode
        uart_send_byte(8'd12);         // A
        uart_send_byte(8'd5);          // B
        #2000000;

        // Test SHL (opcode 0101): 8 << 2 = 32
        uart_send_byte(8'b0000_0101);  // opcode
        uart_send_byte(8'd8);          // A
        uart_send_byte(8'd2);          // B
        #2000000;

        // Test SHR (opcode 0110): 32 >> 2 = 8
        uart_send_byte(8'b0000_0110);  // opcode
        uart_send_byte(8'd32);         // A
        uart_send_byte(8'd2);          // B
        #2000000;

        // Test ROTATE LEFT (opcode 0111): rotl(8'h81,1) = 0x03
        uart_send_byte(8'b0000_0111);  // opcode
        uart_send_byte(8'h81);         // A (10000001)
        uart_send_byte(8'd1);          // rotate amount
        #2000000;

        // Test ROTATE RIGHT (opcode 1000): rotr(8'h81,1) = 0xC0
        uart_send_byte(8'b0000_1000);  // opcode
        uart_send_byte(8'h81);         // A
        uart_send_byte(8'd1);          // rotate amount
        #2000000;

        $finish;
    end

endmodule
