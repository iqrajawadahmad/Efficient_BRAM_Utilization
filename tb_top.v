`timescale 1ns / 1ps
`include "package_fpga.v";
module tb_top;

    // ===========================================
    // Parameters
    // ===========================================
    parameter X = (`K-1)/4;  // must match top module

    // ===========================================
    // Clock / Reset / Start
    // ===========================================
    reg CLK;
    reg rst;
    reg start;
    wire complete;

    // ===========================================
    // DUT Outputs (arrays for X instances)
    // ===========================================
    wire [7:0] out1 [X-1:0];
    wire [7:0] out2 [X-1:0];
    wire [7:0] out3 [X-1:0];
    wire [7:0] out4 [X-1:0];
    wire [7:0] out5;  // single external memory output

    // ===========================================
    // Clock generation (100 MHz)
    // ===========================================
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    // ===========================================
    // Instantiate DUT
    // ===========================================
    top #(.X(X)) uut (
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
    // File Logging
    // ===========================================
    integer outfile;
    integer i;

    initial begin
        outfile = $fopen("pixel_outputs.txt", "w");
        if (outfile == 0) begin
            $display("ERROR: Could not open output file!");
            $stop;
        end
    end

    // Write all pixels when SM_EN is high
    always @(posedge CLK) begin
        if (uut.SM_EN) begin
            @(posedge CLK); // ensure data is valid
            for (i = 0; i < X; i = i + 1) begin
                $fwrite(outfile, "Instance %0d: %0h %0h %0h %0h\n", i, out1[i], out2[i], out3[i], out4[i]);
            end
            $fwrite(outfile, "Out5: %0h\n", out5);
        end
    end

    // Close file at end of operation
    initial begin
        wait (complete == 1);
        #20;
        $fclose(outfile);
        $display("Pixel outputs written to pixel_outputs.txt");
        $stop;
    end

    // ===========================================
    // Test sequence
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
    end

    // ===========================================
    // Waveform Dump (for simulation)
    // ===========================================
    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, tb_top);
    end

endmodule
