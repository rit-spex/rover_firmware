//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 02/10/2022 10:07:42 PM
// Design Name: 
// Module Name: CPUComms
// Project Name: urc_rover
// Target Devices: Artix 7 35T
// Tool Versions: Vivado 2020.2
// Description: Communications & memory stack for CPU comms
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import roversPackage::*;

module CPUComms #(
    parameter SYSCLK_FREQ = 100_000_000
) (
    input sclk, rstn,
    input SDA,
    inout SCL
);

I2CSlave #(
    .DEVICE_ADDR(7'h55)
) I2C (
    .SDA(SDA),
    .SCL(SCL)
);
    
endmodule