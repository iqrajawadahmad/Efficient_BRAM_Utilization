`include "package_fpga.v"

module top #(
    parameter X = (`K-1)/4  // Number of BRAM + SM instances
)(
    input  wire CLK,
    input  wire rst,
    input  wire start,
    output wire complete, 

    // Each BRAM+SM instance produces 4 outputs
    output wire [7:0] out1 [X],
    output wire [7:0] out2 [X],
    output wire [7:0] out3 [X],
    output wire [7:0] out4 [X],

    // Only ONE out5 → directly from single external memory
    output wire [7:0] out5
);

    // ============================
    // Control signals (shared)
    // ============================
    wire e_mem_addr_en;
    wire w_bram_addr_en;
    wire r_bram_addr_en;
    wire W_A;
    wire EN_A;
    wire EN_B;
    wire SM_EN;
    wire [(`SELECT-1):0] Sel;
    wire stall;

    // ============================
    // Address & data arrays for BRAM
    // ============================
    wire [10:0] ADDR_A       [X];
    wire [8:0]  ADDR_B       [X];
    wire [31:0] bram_dout    [X];

    // ============================
    // Single external memory signals
    // ============================
    wire [17:0] mem_address;  
    wire [7:0]  mem_data_out;

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
        .ADDR_A(ADDR_A[0]), // Use first BRAM port for addr, or replicate as needed
        .ADDR_B(ADDR_B[0]),
        .stall(stall)
    );

    // ============================
    // Single External Memory
    // ============================
    E_MEM external_memory (
        .mem_address(mem_address),
        .data_out(mem_data_out)
    );

    // ============================
    // Generate X BRAM + Steer modules
    // ============================
    genvar i;
    generate
        for (i = 0; i < X; i = i + 1) begin : GEN_INST

            // BRAM Instance
            true_dual_port_BRAM18 bram_inst (
                .DIN_A(mem_data_out),   // All BRAMs read same external memory output
                .ADDR_A(ADDR_A[i]),
                .W_A(W_A),
                .EN_A(EN_A),
                .CLK_A(CLK),
                .rst(rst),

                .ADDR_B(ADDR_B[i]),
                .EN_B(EN_B),
                .CLK_B(CLK),
                .DOUT_B(bram_dout[i])
            );

            // Steer Module Instance
            SM steer_module_inst (
                .rst(rst),
                .SM_EN(SM_EN),
                .Sel(Sel),
                .DOUT_B(bram_dout[i]),
                .Out1(out1[i]),
                .Out2(out2[i]),
                .Out3(out3[i]),
                .Out4(out4[i])
            );

        end
    endgenerate

    // ============================
    // out5 directly from external memory
    // ============================
    assign out5 = mem_data_out;

endmodule
