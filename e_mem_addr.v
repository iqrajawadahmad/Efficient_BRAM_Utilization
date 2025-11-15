`include "package_fpga.v"

module e_mem_addr (
    input wire CLK,
    input wire rst,
    input wire e_mem_addr_en,
    output reg [$clog2(`MEM_SIZE)-1:0] mem_address
);

    always @(posedge CLK) begin
        if (rst)
            mem_address <= 0;
        else if (e_mem_addr_en)begin
            if (mem_address == 18'd262143)
                mem_address <= 0;
            else
                mem_address <= mem_address + 1'b1;
        end
    end

endmodule
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         