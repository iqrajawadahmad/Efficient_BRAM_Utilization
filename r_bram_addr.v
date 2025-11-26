`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2025 02:39:19 PM
// Design Name: 
// Module Name: r_bram_addr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "package_fpga.v"

module r_bram_addr(
    input wire CLK,
    input wire rst,
    input wire r_bram_addr_en,
    output reg [8:0] ADDR_B
);

    always @(posedge CLK) begin
        if (rst)
            ADDR_B <= 0; 
        else if (r_bram_addr_en) begin
            if (ADDR_B == 9'd511)
                ADDR_B <= 0;  
            else
                ADDR_B <= ADDR_B + 1'b1;
        end
    end

endmodule
