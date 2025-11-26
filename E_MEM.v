`include "package_fpga.v"

module E_MEM (
    input  wire [17:0] mem_address,  // 18-bit address (0..262143)//2^18 => 18 ADDRESS lines
    output reg  [7:0] data_out  // 8-bit data
);

    // 8-bit memory array
    reg [7:0] e_mem [0:(`MEM_SIZE-1)];

    initial begin
        // Use the simulator-accessible file path (copy image_file.txt into project sim folder),
        // or use the absolute path your simulator can reach.
        $readmemh("image.mem", e_mem); // or "sim_1/new/image_file.txt"

    end

    always @(*) begin
            data_out <= e_mem[mem_address];
    end

endmodule