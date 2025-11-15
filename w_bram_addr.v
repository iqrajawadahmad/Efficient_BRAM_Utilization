`include "package_fpga.v"
module w_bram_addr(
    input wire CLK,
    input wire rst,
    input wire w_bram_addr_en,  
    output reg [(`ADDR_WIDTH-1):0]ADDR_A
);

    always @(posedge CLK)
    begin
    if (rst)
            
             ADDR_A<=11'd0;
        
    else if (w_bram_addr_en)
        begin
        if (ADDR_A == 11'd2047)
                ADDR_A <= 0;             
            else
                ADDR_A <= ADDR_A + 1'b1;
        end

    end
endmodule