//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 03/05/2021 7:53:42 PM
// Design Name: 
// Module Name: railSensors
// Project Name: urc_rover
// Target Devices: Artix 7 35T
// Tool Versions: Vivado 2020.2
// Description: AD7478 controller to control rail sensing
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import roversPackage::*;

module railSensors #(
    parameter SYSCLK_FREQ = 100_000_000;
    parameter NUMADCS = 5 //number of AD7478s to control
) (
    input logic sclk,
    input logic rstn,

    //ADC data line
    input logic [NUMADCS-1:0] sdat,
    
    //ADC control lines
    output logic cs = 0,
    output logic mclk = 0,

    //output 2D vector of 8bit data values
    output logic [NUMADCS-1:0] outData bus08_t = 0
);

genvar i;

//generate instantiations of ADC modules
generate 
    for (i = 0; i < NUMADCS; i = i + 1;) begin
        AD7478 eightBitADC (
            .sclk(sclk),
            .rstn(rstn),
            .sdat(sdat[i]),
            .cs(cs),
            .mclk(mclk),
            .outData(outData[i])
        );
    end
endgenerate

endmodule