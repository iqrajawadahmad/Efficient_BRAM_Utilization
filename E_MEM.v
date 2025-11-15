`include "package_fpga.v"

module E_MEM (
    input wire clk,
    input wire rst,
    input wire [(`REG_SIZE-1):0] mem_address,
    output reg [(`REG_SIZE-1):0] data_out
);


    reg [(`REG_SIZE-1):0] e_mem [0:(`MEM_SIZE-1)];

    integer i;


    initial begin
        $readmemh("image_data.mem", e_mem);  
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < `MEM_SIZE; i = i + 1) begin
                e_mem[i] <= {(`REG_SIZE){1'b0}};
            end
            data_out <= {(`REG_SIZE){1'b0}};
        end else begin
            data_out <= e_mem[mem_address];
        end
    end

endmodule
