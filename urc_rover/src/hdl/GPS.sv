//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 02/10/2022
// Design Name: 
// Module Name: GPS
// Project Name: urc_rover
// Target Devices: Artix 7 35Txvlog
// Tool Versions: Vivado 2020.2
// Description: wrapper for GPS logic
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module GPS #(
    parameter SYSCLK_FREQ = 100_000_000
) (
    input sclk,
    input rstn,

    input GPSdata,
    
    output logic GPStime,
    output logic GPSlatitude,
    output logic GPSlongitude,
    output logic GPSquality,
    output logic GPSnumSats,
    output logic GPSspeed,
    output logic GPSaccuracy,
    output logic GPSaltitude,
    output logic GPSheight
);


NMEAparser #(
    .SYSCLK_FREQ(SYSCLK_FREQ)
) parser (
    .sclk(sclk),
    .rstn(rstn),
    .dataString(GPSdata)
);
endmodule