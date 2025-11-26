`timescale 1ns / 1ps
`include "package_fpga.v"

module CM (
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
    output reg SM_EN,
    output reg stall,
    output reg [(`SELECT-1):0] Sel
);

    //=====================================================
    // STATE ENCODING
    //=====================================================
    parameter IDLE           = 3'b000,
              INIT_WRITE     = 3'b001,
              ENABLE_READ    = 3'b010,
              STREAMING      = 3'b011,
              FINAL_READ     = 3'b100,
              COMPLETE_STATE = 3'b101;

    reg [2:0] state, next_state;

    // Counters
    reg [8:0]  pixel_read;
    reg [8:0]  sel_count;
    reg [17:0] pixel_write;  // up to 262143

    //=====================================================
    // STATE REGISTER
    //=====================================================
    always @(posedge CLK) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    //=====================================================
    // NEXT STATE LOGIC
    //=====================================================
    always @(*) begin
        next_state = state;

        case (state)

            IDLE:
                if (start)
                    next_state = INIT_WRITE;

            INIT_WRITE:
                if (pixel_write == 18'd2047)
                    next_state = ENABLE_READ;

            ENABLE_READ:
                next_state = STREAMING;

            STREAMING:
                if (pixel_write >= 18'd262143)
                    next_state = FINAL_READ;

            FINAL_READ:
                if (pixel_read == 9'd511)
                    next_state = COMPLETE_STATE;

            COMPLETE_STATE:
                next_state = IDLE;

        endcase
    end

    //=====================================================
    // OUTPUT + COUNTERS
    //=====================================================
    always @(posedge CLK) begin
        if (rst) begin

            stall <= 0;
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
            pixel_read <= 0;
            pixel_write <= 0;
        end 

        else begin
            case (state)

                //===============================================
                // IDLE
                //===============================================
                IDLE: begin
                    stall <= 0;

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
                    pixel_read <= 0;
                    pixel_write <= 0;
                end

                //===============================================
                // INIT_WRITE (Write first 2048 pixels)
                //===============================================
                INIT_WRITE: begin
                    
                    // LAST cycle ? stall assert ? hold external mem @2048
                    if (pixel_write == 18'd2047)
                        stall <= 1;
                    else
                        stall <= 0;
                    e_mem_addr_en <= 1;
                    w_bram_addr_en <= 1;
                    r_bram_addr_en <= 0;

                    W_A <= 1;
                    EN_A <= 1;
                    EN_B <= 0;

                    SM_EN <= 0;
                    complete <= 0;
                    Sel <= 0;

                    pixel_write <= pixel_write + 18'd1;
                end

                //===============================================
                // ENABLE_READ (One-cycle pause)
                //===============================================
                ENABLE_READ: begin
                    stall <= 1;
                    e_mem_addr_en <= 1;
                    w_bram_addr_en <= 0;
                    r_bram_addr_en <= 1;

                    W_A <= 0;
                    EN_A <= 0;
                    EN_B <= 1;

                    SM_EN <= 1;

                    Sel <= 2'b00;
                end

                //===============================================
                // STREAMING (Simultaneous read+write)
                //===============================================
                STREAMING: begin
                
                    stall <= 0;

                    e_mem_addr_en <= 1;
                    w_bram_addr_en <= 1;
                    r_bram_addr_en <= 1;

                    W_A <= 1;
                    EN_A <= 1;
                    EN_B <= 1;
                    SM_EN <= 1;

                    complete <= 0;

                    pixel_write <= pixel_write + 18'd1;

                    // 512 pixels per Sel
                    if (sel_count == 9'd511) begin
                        sel_count <= 0;
                        Sel <= (Sel == 2'b11) ? 2'b00 : Sel + 1'b1;
                    end
                    else begin
                        sel_count <= sel_count + 9'd1;
                    end
                end

                //===============================================
                // FINAL_READ (read last rows)
                //===============================================
                FINAL_READ: begin
                    stall <= 0;
                    e_mem_addr_en <= 1;
                    w_bram_addr_en <= 0;
                    r_bram_addr_en <= 1;

                    W_A <= 0;
                    EN_A <= 0;
                    EN_B <= 1;

                    SM_EN <= 1;

                    pixel_read <= pixel_read + 9'd1;
                end

                //===============================================
                // COMPLETE
                //===============================================
                COMPLETE_STATE: begin
                    stall <= 0;
                    e_mem_addr_en <= 0;
                    w_bram_addr_en <= 0;
                    r_bram_addr_en <= 0;

                    W_A <= 0;
                    EN_A <= 0;
                    EN_B <= 0;
                    SM_EN <= 0;

                    complete <= 1;
                    Sel <= 0;

                    pixel_read <= 0;
                    sel_count <= 0;
                    pixel_write <= 0;
                end

            endcase
        end
    end

endmodule
