`include "package_fpga.v"

module r_bram_addr(
    input wire CLK,
    input wire rst,
    input wire r_bram_addr_en,
    output reg [(`ADDR_WIDTH-3):0] ADDR_B
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
