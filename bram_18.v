`include "package_fpga.v"

module true_dual_port_BRAM18 (
    parameter base_address = 512,  
    
    // PORT A (WRITE)
    input [(`DATA_WIDTH_A-1):0] DIN_A,
    input [(`ADDR_WIDTH-1):0] ADDR_A, 
    input W_A,
    input EN_A,
    input CLK_A,
    
    // PORT B (READ) 
    input [(`ADDR_WIDTH-3):0] ADDR_B,
    input EN_B,
    input CLK_B,
    output reg [(`DATA_WIDTH_B-1):0] DOUT_B
);   


    reg [17:0] bram_18 [0:(`DEPTH_A-1)];  
    
    // PORT A 
    always @(posedge CLK_A) begin
        if (EN_A && W_A) begin
            bram_18[ADDR_A] <= DIN_A[17:0];  
        end
    end
    
    // PORT B 
    always @(posedge CLK_B) begin
        if (EN_B) begin
  
            DOUT_B <= {bram_18[ADDR_B + 3*base_address],
                       bram_18[ADDR_B + 2*base_address], 
                       bram_18[ADDR_B + base_address],
                       bram_18[ADDR_B]};
        end
    end

endmodule