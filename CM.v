`include "package_fpga.v"

module control_module (
    input CLK,
    input rst,
    input start,
    output reg complete,
    output reg e_mem_addr_en,   
    output reg w_bram_addr_en,  
    output reg r_bram_addr_en,
    output reg W_A,
    output reg EN_A,
    output reg EN_B, 
    output reg SM_EN,  // to steer module
    output reg [(`SELECT-1):0] Sel // to muxes of steer module
);

    // State Encoding
    parameter IDLE           = 3'b000,
              INIT_WRITE     = 3'b001,
              ENABLE_READ    = 3'b010,
              STREAMING      = 3'b011,
              FINAL_READ     = 3'b100,
              COMPLETE_STATE = 3'b101;

    reg [2:0] state, next_state;

    reg [8:0] pixel_read;
    reg [8:0] sel_count;  
    reg [17:0] pixel_write;  // 0–262143

    // State register
    always @(posedge CLK) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next-State Logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: 
                if (start)
                    next_state = INIT_WRITE;

            INIT_WRITE:
                // 4 rows of 512 
                if (pixel_write == 18'd2047)  // 0-2047 = 2048 pixels
                    next_state = ENABLE_READ;

            ENABLE_READ:
                next_state = STREAMING;

            STREAMING:
                if (pixel_write >= 18'd262143)  // 512×512-1 = 262143
                    next_state = FINAL_READ;
                    
            FINAL_READ:
                if (pixel_read == 9'd511)  // last rows fully read
                    next_state = COMPLETE_STATE;

            COMPLETE_STATE:
                next_state = IDLE;
                
            default: next_state = IDLE;
        endcase
    end

    // Output Logic
    always @(posedge CLK) begin
        if (rst) begin
            // Reset all outputs
            e_mem_addr_en <= 1'b0;
            w_bram_addr_en <= 1'b0;
            r_bram_addr_en <= 1'b0;
            W_A <= 1'b0;
            EN_A <= 1'b0;
            EN_B <= 1'b0;
            SM_EN <= 1'b0;
            complete <= 1'b0;
            Sel <= 0;
            pixel_read <= 9'd0;
            sel_count <= 9'd0;
            pixel_write <= 18'd0;
        end else begin
            case (state)
                IDLE: begin
                    e_mem_addr_en <= 0;
                    w_bram_addr_en <= 0;
                    r_bram_addr_en <= 0;
                    W_A <= 0;
                    EN_A <= 0;
                    EN_B <= 0;
                    SM_EN <= 0;
                    complete <= 0;
                    Sel <= 0;
                    sel_count <= 0;
                    pixel_write <= 0;
                    pixel_read <= 0;
                end

                INIT_WRITE: begin
                    // Write first 2048 pixels to BRAM
                    e_mem_addr_en <= 1;   // Read from external memory
                    w_bram_addr_en <= 1;  // Enable write address counter
                    r_bram_addr_en <= 0;  // Disable read for now
                    W_A <= 1;             // Write enable BRAM
                    EN_A <= 1;            // Enable BRAM port A
                    EN_B <= 0;            // Disable BRAM port B
                    SM_EN <= 0;           // Disable steer module
                    complete <= 0;
                    Sel <= 0;
                    // Update counters
                    pixel_write <= pixel_write + 18'd1;
                end

                ENABLE_READ: begin
                    // One cycle to read first 4 pixels (0, 512, 1024, 1536)
                    e_mem_addr_en <= 1;   // Continue reading from external memory
                    w_bram_addr_en <= 0;  // Disable write address counter
                    r_bram_addr_en <= 1;  // Enable read address counter
                    W_A <= 0;             // Disable write
                    EN_A <= 0;            // Disable BRAM port A
                    EN_B <= 1;            // Enable BRAM port B for read
                    SM_EN <= 1;           // Enable steer module
                    complete <= 0;
                    Sel <= 2'b00;         // Select first set of pixels
                    
       
                end

                STREAMING: begin
                    // Simultaneous read and write
                    e_mem_addr_en <= 1;   // Continue external memory read
                    w_bram_addr_en <= 1;  // Enable write address counter
                    r_bram_addr_en <= 1;  // Enable read address counter
                    W_A <= 1;             // Write enable BRAM
                    EN_A <= 1;            // Enable BRAM port A for write
                    EN_B <= 1;            // Enable BRAM port B for read
                    SM_EN <= 1;           // Enable steer module
                    complete <= 0;
                    pixel_write <= pixel_write + 18'd1;

                    if (sel_count == 9'd511) begin
                        sel_count <= 9'd0;        // Reset counter after 511
                        Sel <= (Sel == 2'b11) ? 2'b00 : Sel + 1'b1;
                        end 
                    else begin
                    sel_count <= sel_count + 9'd1; 
                    end
                end
                
                FINAL_READ: begin
                    e_mem_addr_en <= 0;   // Stop external memory read
                    w_bram_addr_en <= 0;  
                    r_bram_addr_en <= 1;   
                    W_A <= 0;
                    EN_A <= 0;
                    EN_B <= 1;
                    SM_EN <= 1;
                    pixel_read <= pixel_read + 9'd1;
                end

                COMPLETE_STATE: begin
                    // All pixels processed
                    e_mem_addr_en <= 0;
                    w_bram_addr_en <= 0;
                    r_bram_addr_en <= 0;
                    W_A <= 0;
                    EN_A <= 0;
                    EN_B <= 0;
                    SM_EN <= 0;
                    Sel <= 0;
                    complete <= 1;
                    
                    // Reset counters for next image
                    sel_count <= 9'd0;
                    pixel_read <= 9'd0;
                    pixel_write <= 18'd0;
                end
                
                default: begin
                    // Default outputs
                    e_mem_addr_en <= 0;
                    w_bram_addr_en <= 0;
                    r_bram_addr_en <= 0;
                    W_A <= 0;
                    EN_A <= 0;
                    EN_B <= 0;
                    SM_EN <= 0;
                    complete <= 0;
                    Sel <= 0;
                end
            endcase
        end
    end
endmodule