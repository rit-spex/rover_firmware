//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 03/05/2021 8:07:42 PM
// Design Name: 
// Module Name: AD7478
// Project Name: urc_rover
// Target Devices: Artix 7 35T
// Tool Versions: Vivado 2020.2
// Description: AD7478 Driver & interpreter
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import roversPackage::*;

module AD7478 #(
    parameter SYSCLK_FREQ = 100_000_000;
)(
    input logic sclk,
    input logic rstn,

    input logic sdat,
    
    output logic cs= 0,
    output logic mclk = 0,

    output bus08_t outData = 0,
);

always_ff @( sclk ) begin : Serial
    if(!rstn) begin
        outData = 0;
        cs = 0;
        mclk = 0;
    end else begin
        //TODO: write serial control logic as per AD7478 datasheet p18
    end
end : Serial
    
endmodule