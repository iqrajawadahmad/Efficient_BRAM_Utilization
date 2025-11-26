//=====================================================
// File: package_fpga.v
// Description: Common parameters for True Dual Port BRAM18
//=====================================================
`ifndef PACKAGE_FPGA_V
`define PACKAGE_FPGA_V
//GENERALIZATION OF INSTANCES
`define K 5   // Number of BRAM & SM Instances

// BRAM Port A (Write)
`define DATA_WIDTH_A 8
`define DEPTH_A      2048
`define ADDR_WIDTH_A 11

// BRAM Port B (Read)
`define DATA_WIDTH_B 32
`define DEPTH_B      512
`define ADDR_WIDTH_B 9

// ROW BUFFER
`define DATA_WIDTH    8
`define ROW_LENGTH    512

// Steering Module Select
`define SELECT 2

// External Memory
`define REG_SIZE 18
`define MEM_SIZE 262144  // 512 x 512 pixels

`endif
 