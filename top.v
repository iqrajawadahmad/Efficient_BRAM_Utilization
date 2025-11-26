`timescale 1ns / 1ps
`include "package_fpga.v"

module top (
    input  wire CLK,
    input  wire rst,
    input  wire start,
    output wire complete, 
    output wire [7:0] out1, out2, out3, out4, out5
);

    // ============================
    // Control signals
    // ============================
    wire e_mem_addr_en;//EXTERNAL MEM
    wire w_bram_addr_en;//PORT A
    wire r_bram_addr_en;
    wire W_A;
    wire EN_A;
    wire EN_B;
    wire SM_EN;
    wire [(`SELECT-1):0] Sel;
   

    // ============================
    // Address signals
    // ============================
    wire [17:0] mem_address;  
    wire [10:0] ADDR_A;       
    wire [8:0]  ADDR_B;

    // ============================
    // Data wires
    // ============================
    wire [7:0]  mem_data_out;
    wire [31:0] bram_dout;
    wire [7:0]  bram_din_a;
    wire stall; 


    // ============================
    // Control Module
    // ============================
    control_module control_module (
        .CLK(CLK),
        .rst(rst),
        .start(start),
        .complete(complete),
        .e_mem_addr_en(e_mem_addr_en),
        .w_bram_addr_en(w_bram_addr_en),
        .r_bram_addr_en(r_bram_addr_en),
        .W_A(W_A),
        .EN_A(EN_A),
        .EN_B(EN_B),
        .SM_EN(SM_EN),
        .Sel(Sel),
        .stall(stall)
    );

    // ============================
    // Address Generation Module
    // ============================
    AGM address_generation (
        .CLK(CLK),
        .rst(rst),
        .e_mem_addr_en(e_mem_addr_en),
        .w_bram_addr_en(w_bram_addr_en),
        .r_bram_addr_en(r_bram_addr_en),
        .mem_address(mem_address),
        .ADDR_A(ADDR_A),
        .ADDR_B(ADDR_B),
        .stall(stall)
    );

    // ============================
    // External Memory
    // ============================
    E_MEM external_memory (
        .mem_address(mem_address),
        .data_out(mem_data_out)
    );

    // ============================
    // True Dual-Port BRAM
    // ============================
    true_dual_port_BRAM18 bram_instance (
        .DIN_A(mem_data_out),
        .ADDR_A(ADDR_A),
        .W_A(W_A),
        .EN_A(EN_A),
        .CLK_A(CLK),
        .rst(rst),

        .ADDR_B(ADDR_B),
        .EN_B(EN_B),
        .CLK_B(CLK),
        .DOUT_B(bram_dout)
    );

    // ============================
    // Steer Module
    // ============================
    SM steer_module (
        .rst(rst),
        .SM_EN(SM_EN),
        .Sel(Sel),
        .DOUT_B(bram_dout),
        .Out1(out1),
        .Out2(out2),
        .Out3(out3),
        .Out4(out4)
        
    );
    assign out5 = mem_data_out;

endmodule