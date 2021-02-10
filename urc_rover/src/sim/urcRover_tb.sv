//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 02/10/2021 04:36:39 PM
// Design Name: 
// Module Name: urcRover_tb
// Project Name: urc_rover
// Target Devices: N/A
// Tool Versions: Vivado 2020.2
// Description: Top level testbench for urc rover
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module urcRover_tb;
    timeunit      1ns;
    timeprecision 1ps;

    logic OSCCLK_tb = 0;
    logic SYSRST_tb = 0;

    urcRover DUT (
        .OSCCLK(OSCCLK_tb),
        .SYSRST(SYSRST_tb)
    );


endmodule:urcRover_tb