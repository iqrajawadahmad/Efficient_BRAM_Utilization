`timescale 1ns / 1ps

module tb_top;

    // ===========================================
    // Clock / Reset / Start
    // ===========================================
    reg CLK;
    reg rst;
    reg start;
    wire complete;

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;   // 100 MHz clock
    end

    // ===========================================
    // DUT
    // ===========================================
    top uut (
        .CLK(CLK),
        .rst(rst),
        .start(start),
        .complete(complete)
    );

    // ===========================================
    // INTERNAL PROBES
    // ===========================================
    wire [2:0]  state        = uut.control_module.state;
    wire [17:0] pixel_write  = uut.control_module.pixel_write;
    wire [8:0]  pixel_read   = uut.control_module.pixel_read;
    wire [1:0]  sel   = uut.control_module.Sel;
    wire [8:0]  sel_count    = uut.control_module.sel_count;

    wire [17:0] mem_addr     = uut.address_generation.mem_address;
    wire [10:0] addr_a  = uut.address_generation.ADDR_A;
    wire [8:0]  addr_b  = uut.address_generation.ADDR_B;

    wire [7:0]  mem_data_out = uut.external_memory.data_out;
    wire [31:0] bram_dout  = uut.bram_instance.DOUT_B;

    wire [7:0] out1 = uut.steer_module.Out1;
    wire [7:0] out2 = uut.steer_module.Out2;
    wire [7:0] out3 = uut.steer_module.Out3;
    wire [7:0] out4 = uut.steer_module.Out4;

    // ===========================================
    // TEST SEQUENCE
    // ===========================================
    initial begin
        $display("\n======================================");
        $display("        IMAGE PROCESSOR TESTBENCH");
        $display("======================================");

        rst = 1;
        start = 0;
        #50;

        rst = 0;
        $display("[TB] Reset released");

        #50;

        $display("[TB] Start pulse");
        start = 1;
        #10;
        start = 0;

        wait(complete == 1);

        $display("\n=========== PROCESS COMPLETED ==========");
        $display("Final State        = %0d", state);
        $display("Pixel Write Count  = %0d", pixel_write);
        $display("Pixel Read Count   = %0d", pixel_read);
        $display("Final SEL Value    = %0d", sel);

        #100;
        $finish;
    end

    // ===========================================
    // MONITORS
    // ===========================================

    // BRAM Write Monitor
    always @(posedge CLK) begin
        if (uut.control_module.EN_A && uut.control_module.W_A)
            $display("[WRITE] EXT[%0d] -> BRAM_A[%0d] : %h",
                     mem_addr, addr_a, mem_data_out);
    end

    // BRAM Read Monitor
    always @(posedge CLK) begin
        if (uut.control_module.EN_B)
            $display("[READ ] BRAM_B[%0d] -> %h",
                     addr_b, bram_dout);
    end

    // STEER Output Monitor
    always @(posedge CLK) begin
        if (uut.control_module.SM_EN && state == 3)
            $display("[STEER] %h %h %h %h",
                     out1, out2, out3, out4);
    end
    wire [39:0] final_data = uut.final_data;
    
    always @(posedge CLK) begin
        if (state == 3)
            $display("[FINAL OUT] %h", final_data);
    end

    // ===========================================
    // Waveform Dump
    // ===========================================
    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, tb_top);
    end

endmodule