//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer:
// 
// Create Date: 02/11/2022
// Design Name: 
// Module Name: NMEAparser
// Project Name: urc_rover
// Target Devices: Artix 7 35T
// Tool Versions: Vivado 2020.2
// Description: parses NMEA GPSPMC string from GPS
// 
//  Example of GPSPMC String:
//  
//  $GPGGA,hhmmss.ss,llll.ll,a,yyyyy.yy,a,x,xx,x.x,x.x,M,x.x,M,x.x,xxxx*hh
//              1       2    3     4    5 6  7  8   9  10 11 12 13  14  15
//  1    = UTC of Position
//  2    = Latitude
//  3    = N or S
//  4    = Longitude
//  5    = E or W
//  6    = GPS quality indicator (0=invalid; 1=GPS fix; 2=Diff. GPS fix)
//  7    = Number of satellites in use [not those in view]
//  8    = Horizontal dilution of position
//  9    = Antenna altitude above/below mean sea level (geoid)
//  10   = Meters  (Antenna height unit)
//  11   = Geoidal separation (Diff. between WGS-84 earth ellipsoid and
//         mean sea level.  -=geoid is below WGS-84 ellipsoid)
//  12   = Meters  (Units of geoidal separation)
//  13   = Age in seconds since last update from diff. reference station
//  14   = Diff. reference station ID#
//  15   = Checksum
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module NMEAparser #(
    parameter SYSCLK_FREQ = 100_000_000
) (
    input sclk,
    input rstn,

    input [559:0] dataString, //66 bytes (70 ASCII chars) 

    output values

);
    
endmodule