`timescale 1ns / 1ps
`include "package_fpga.v"

module SM(
    input wire rst, 
    input wire SM_EN,
    input wire [(`SELECT-1):0] Sel,
    input wire [31:0] DOUT_B,
    output reg [7:0] Out1,
    output reg [7:0] Out2,
    output reg [7:0] Out3,
    output reg [7:0] Out4
);

    wire [7:0] mux1, mux2, mux3, mux4;

    mux m1(.Sel(Sel),
           .dout0(DOUT_B[7:0]),
           .dout1(DOUT_B[15:8]),
           .dout2(DOUT_B[23:16]),
           .dout3(DOUT_B[31:24]),
           .out(mux1));

    mux m2(.Sel(Sel),
           .dout0(DOUT_B[15:8]),
           .dout1(DOUT_B[23:16]),
           .dout2(DOUT_B[31:24]),
           .dout3(DOUT_B[7:0]),
           .out(mux2));

    mux m3(.Sel(Sel),
           .dout0(DOUT_B[23:16]),
           .dout1(DOUT_B[31:24]),
           .dout2(DOUT_B[7:0]),
           .dout3(DOUT_B[15:8]),
           .out(mux3));

    mux m4(.Sel(Sel),
           .dout0(DOUT_B[31:24]),
           .dout1(DOUT_B[7:0]),
           .dout2(DOUT_B[15:8]),
           .dout3(DOUT_B[23:16]),
           .out(mux4));

    // ---------- ZERO LATENCY LOGIC ----------
    always @(*) begin
        if (rst || !SM_EN) begin
            Out1 = 8'd0;
            Out2 = 8'd0;
            Out3 = 8'd0;
            Out4 = 8'd0;
        end else begin
            Out1 = mux1;
            Out2 = mux2;
            Out3 = mux3;
            Out4 = mux4;
        end
    end

endmodule
