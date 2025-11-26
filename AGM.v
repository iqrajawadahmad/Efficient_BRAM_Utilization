`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2025 02:36:47 PM
// Design Name: 
// Module Name: AGM
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

module AGM(
    input wire CLK,
    input wire rst,
    input wire e_mem_addr_en,   
    input wire w_bram_addr_en,  
    input wire r_bram_addr_en,
    output wire [17:0] mem_address,
    output wire [10:0]ADDR_A,
    output wire [8:0]ADDR_B,
    input wire stall
);
    

    e_mem_addr enable_memaddress(
    .CLK(CLK),
    .rst(rst),
    .e_mem_addr_en(e_mem_addr_en),
    .mem_address(mem_address),
    .stall(stall)
     );
     
    w_bram_addr write_bram(
    .CLK(CLK),
    .rst(rst),
    .w_bram_addr_en(w_bram_addr_en),
    .ADDR_A(ADDR_A)
    );
    
    r_bram_addr read_rowbuffer(
    .CLK(CLK),
    .rst(rst),
    .r_bram_addr_en(r_bram_addr_en),
    .ADDR_B(ADDR_B));

endmodule

// Simple rule
// CLK=1 ? increment address
// CLK=0 ? memory read at current address