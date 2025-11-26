`timescale 1ns / 1ps
`include "package_fpga.v"

module true_dual_port_BRAM18  (

    // PORT A (WRITE)
    input  wire [7:0] DIN_A,         // 8-bit input
    input  wire [10:0]    ADDR_A,      // 11-bit address (0..2047)
    input  wire                        W_A,
    input  wire                        EN_A,
    input  wire                        CLK_A,
    input  wire                        rst,         // soft reset input

    // PORT B (READ)
    input  wire [8:0]    ADDR_B,      // 9-bit address (0..511)
    input  wire                        EN_B,
    input  wire                        CLK_B,
    output reg  [31:0]  DOUT_B      // 32-bit packed 4 pixels
);

    // BRAM = 8-bit wide � DEPTH_A depth
    reg [7:0] bram_18 [0:(`DEPTH_A-1)];

    // WRITE PORT: synchronous write at CLK_A
    always @(posedge CLK_A) begin
        if (EN_A && W_A) begin
            bram_18[ADDR_A] <= DIN_A;
        end
    end

    // READ PORT: synchronous read at CLK_B; pack 4 pixels (offsets)
    always @(posedge CLK_B) begin
        if (rst) begin
            DOUT_B <= 32'b0;  // 32'b0
        end else if (EN_B) begin
            // Make sure ADDR_B + offsets stay within bounds [0..DEPTH_A-1]
            // ADDR_B is 0..511; offsets add up to 1536 (which is within DEPTH_A=2048)
            DOUT_B <= { bram_18[ADDR_B + 1536],
                        bram_18[ADDR_B + 1024],
                        bram_18[ADDR_B + 512],
                        bram_18[ADDR_B] };
        end
    end

endmodule
