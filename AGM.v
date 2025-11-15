`include "package_fpga.v"

module AGM(
    input wire CLK,
    input wire rst,
    input wire e_mem_addr_en,   
    input wire w_bram_addr_en,  
    input wire r_bram_addr_en,
    output wire [$clog2(`MEM_SIZE)-1:0] mem_address,
    output wire [(`ADDR_WIDTH-1):0]ADDR_A,
    output wire [(`ADDR_WIDTH-3):0]ADDR_B
);
    

    e_mem_addr enable_memaddress(
    .CLK(CLK),
    .rst(rst),
    .e_mem_addr_en(e_mem_addr_en),
    .mem_address(mem_address));
    w_bram_addr write_bram(
    .CLK(CLK),
    .rst(rst),
    .w_bram_addr_en(w_bram_addr_en),
    .ADDR_A(ADDR_A));
    r_bram_addr read_rowbuffer(
    .CLK(CLK),
    .rst(rst),
    .r_bram_addr_en(r_bram_addr_en),
    .ADDR_B(ADDR_B));

endmodule

// Simple rule
// CLK=1 → increment address
// CLK=0 → memory read at current address