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
// Description: parses NMEA GPSGGA string from GPS
// 
//  Example of GPSGGA String:
//  
//  $GPGGA,hhmmss.sss,ddmm.mmmm,a,dddmm.mmmm,a,x,x,x.xx,xx.x,M,xx.x,M,x.x,*hh<CR><LF>
//              1         2     3      4     5 6 7  8    9   10 11  12 13  14  
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
//  14   = Checksum (bitwise XOR of all codes between $ and *, not inclusive)
//  <CR><LF> end of message 
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

    input [7:0] dataString, 
    input       dataReady,

    GPSdata gpsResults,

    output logic GPSReady //goes high when all data is valid
);



/////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////
    
endmodule