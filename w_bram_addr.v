`include "package_fpga.v"

module w_bram_addr(
    input wire CLK,
    input wire rst,
    input wire w_bram_addr_en,
    output reg [10:0] ADDR_A
);

    always @(posedge CLK) begin
        if (rst) begin
            ADDR_A <= 11'd0;
        end
        else if (w_bram_addr_en) begin

            // Wrap after 2047 ? back to 0
            if (ADDR_A == 11'd2047)
                ADDR_A <= 11'd0;
            else
                ADDR_A <= ADDR_A + 1'b1;

        end
    end

endmodule
