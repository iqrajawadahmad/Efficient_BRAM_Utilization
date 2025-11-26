module e_mem_addr (
    input wire CLK,
    input wire rst,
    input wire stall,
    input wire e_mem_addr_en,
    output reg [17:0] mem_address
);

    always @(posedge CLK) begin
        if (rst)
            mem_address <= 18'd0;
        else if (e_mem_addr_en) begin
            
            // Stall exactly at address = 2048
            if (stall && mem_address == 18'd2048)
                mem_address <= 18'd2048;
            // Wrap condition (your original)
            else if (mem_address == 18'd262143) 
                mem_address <= 18'd259072;

            // Normal increment
            else
                mem_address <= mem_address + 1'b1;
        end
    end

endmodule
