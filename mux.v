`include "package_fpga.v"
module mux(
    input wire [(`SELECT-1):0]Sel,
    input  wire [7:0] dout0,
    input  wire [7:0] dout1,
    input  wire [7:0] dout2,
    input  wire [7:0] dout3,
    output reg  [7:0] out

);
    always @(*)begin
        case(Sel)
        
            2'b00:out=dout0;
            2'b01:out=dout1;
            2'b10:out=dout2;
            2'b11:out=dout3;
            default:
            out=8'd0;
        
        endcase
    end
endmodule