`timescale 1ns / 1ps

module tb_top;

    // ===========================================
    // Clock / Reset / Start
    // ===========================================
    reg CLK;
    reg rst;
    reg start;
    wire complete;
    wire [7:0] out1, out2, out3, out4, out5;

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
        .complete(complete),
        .out1(out1),
        .out2(out2),
        .out3(out3),
        .out4(out4),
        .out5(out5)    
    );

    // ===========================================
    // INTERNAL PROBES
    // ===========================================
    wire SM_EN = uut.SM_EN;   // steer module enable

    // ===========================================
    // FILE LOGGING
    // ===========================================
    integer outfile;

    initial begin
        outfile = $fopen("pixel_outputs.txt", "w");
        if (outfile == 0) begin
            $display("ERROR: Could not open output file!");
            $stop;
        end
    end

    // Write one line per pixel when SM is active
    always @(posedge CLK) begin
        if (SM_EN) begin
            // Write pixel set in a single line
            $fwrite(outfile, "%0h %0h %0h %0h\n", out1, out2, out3, out4);
        end
    end

    // Close file at end of operation
    initial begin
        wait (complete == 1);
        #20;
        $fclose(outfile);
        $display("Pixel outputs written to pixel_outputs.txt");
    end

    // ===========================================
    // TEST SEQUENCE
    // ===========================================
    initial begin
        rst = 1;
        start = 0;
        #20;
        
        rst = 0;
        #10;
        
        start = 1;
        #10;
        start = 0;
       
        wait (complete == 1);
        #20;
        $stop;
    end

    // ===========================================
    // Waveform Dump
    // ===========================================
    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, tb_top);
    end

endmodule