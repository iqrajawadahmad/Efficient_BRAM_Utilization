//=====================================================
// File: package_fpga.v
// Description: Common parameters for True Dual Port BRAM18
//=====================================================
`ifndef PACKAGE_FPGA_V
`define PACKAGE_FPGA_V

`define ADDR_WIDTH 11

// Port A (Write)
`define DATA_WIDTH_A 8
`define DEPTH_A      2048

// Port B (Read)
`define DATA_WIDTH_B 32
`define DEPTH_B      512

// ROW BUFFER
`define DATA_WIDTH 8
`define ROW_LENGTH 512

//select SM
`define SELECT 2
//E_MEM
`define REG_SIZE 9
`define MEM_SIZE  262144

`endif
