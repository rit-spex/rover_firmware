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
    parameter SYSCLK_FREQ = 100_000_000,
    parameter NUMADCS = 5 //number of AD7478s to control
) (
    input logic sclk,
    input logic rstn,

    //ADC data line
    input [NUMADCS-1:0] sdat,
    input [NUMADCS-1:0] mclk,
    //ADC control lines
    //output logic cs,
    //output logic mclk,

    //output 2D vector of 8bit data values
    output logic [15:0] outData [NUMADCS-1:0], 
    
    // the decimation filter outputs a data_en signal,
    // outputs said signal downstream
    output logic [NUMADCS-1:0] data_ready
);


        AMC1303Mx #(
            .SYSCLK_FREQ(SYSCLK_FREQ)
        ) eightBitADC [NUMADCS-1:0] (
            .mclk(mclk[NUMADCS-1:0]),
            .resetn(rstn),
            .sdat(sdat[NUMADCS-1:0]),
            .dec_filter_data_en(data_ready[NUMADCS-1:0]),
            .out_data(outData[NUMADCS-1:0])
        );

//    for (i = 0; i < NUMADCS; i = i + 1) begin
//        AD7478 eightBitADC (
//            .sclk(sclk),
//           .rstn(rstn),
//            .sdat(sdat[i]),
//            .cs(cs),
//           .mclk(mclk),
//            .outData(outData[i])
//        );
//    end

endmodule