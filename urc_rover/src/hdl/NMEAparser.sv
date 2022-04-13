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
//  14   = Checksum (bitwise XOR of all codes(bytes) between $ and *, not inclusive)
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

    logic [ 5:0] gpgga       [7:0]; //0
    logic [10:0] utc         [7:0]; //1
    logic [ 9:0] latitude    [7:0]; //2
    logic [ 1:0] ns          [7:0]; //3
    logic [10:0] longitude   [7:0]; //4
    logic [ 1:0] ew          [7:0]; //5
    logic [ 1:0] quality     [7:0]; //6
    logic [ 1:0] numSats     [7:0]; //7
    logic [ 4:0] hdop        [7:0]; //8
    logic [ 4:0] geoid       [7:0]; //9
    logic [ 1:0] metersH     [7:0]; //10
    logic [ 4:0] geoidal     [7:0]; //11
    logic [ 1:0] metersG     [7:0]; //12
    logic [ 3:0] age         [7:0]; //13
    logic [ 1:0] cSum        [7:0]; //11
    //logic [ 3:0] altMSL      [7:0]; //14
    int olst, st;

    always_ff @(posedge sclk ) begin : parser
        //check if reset (active low)
        if ((!rstn) || (st == 99)) begin
            dataReady <= 0;
            gpgga <= 0;
            utc <= 0;
            latitude <= 0;
            ns <= 0;
            longitude <= 0;
            ew <= 0;
            quality <= 0;
            numSats <= 0;
            hdop <= 0;
            geoid <= 0;
            metersH <= 0;
            geoidal <= 0;
            metersG <= 0;
            age <= 0;
            cSum <= 0;
            st <= 1;
        end 
        //check for $
        else if (!(dataString ^ 8'b00100100)) begin
            dataReady <= 0
            st <= 2;
        end 
        //validate GPGGA after $
        else if ((st >= 2) && (st < 7)) begin
            if ((st == 2) && (!(dataString ^ 8'b01000111)) begin
                gpgga[5] <= dataString;
                st <= 3;
            end else if ((st == 3) && (!(dataString ^ 8'b01010000)) begin
                gpgga[4] <= dataString;
                st <= 4;
            end else if ((st == 4) && (!(dataString ^ 8'b01000111)) begin
                gpgga[3] <= dataString;
                st <= 5;
            end else if ((st == 5) && (!(dataString ^ 8'b01000111)) begin
                gpgga[2] <= dataString;
                st <= 6;
            end else if ((st == 6) && (!(dataString ^ 8'b01000001)) begin
                gpgga[1] <= dataString;
                st <= 7;
            end else begin
                st <= 99;
            end
        end
        //Parse
        else if (st >= 7) begin
            //validate ,'s are where expected
            if ((st == 7) || (st == 18) || (st == 28) || (st == 30) || (st == 41) || (st == 43) || (st == 45) || (st == 47) || (st == 52) || (st == 57) || (st == 59) || (st == 64) || (st == 66) || (st == 70)) begin
                if (!(dataString ^ 8'b00101100)) begin
                    olst = st;
                    st++;
                    if (st == 7) begin
                        gpgga[0] = dataString;
                    end
                end else begin
                    st = 99;
                end
            //fill arrays with values
            end else if (st < 82) begin
                if ((st >= 8) && (st < 18) begin
                    utc[17-st] = dataString;
                end else if ((st >= 19) && (st < 28) begin
                    latitude[27-st] = dataString;
                end else if ((st >= 29) && (st < 30) begin
                    ns[29-st] = dataString;
                end else if ((st >= 31) && (st < 41) begin
                    longitude[40-st] = dataString;
                end else if ((st >= 42) && (st < 43) begin
                    ew[42-st] = dataString;
                end else if ((st >= 44) && (st < 45) begin
                    quality[44-st] = dataString;
                end else if ((st >= 46) && (st < 47) begin
                    numSats[46-st] = dataString;
                end else if ((st >= 48) && (st < 52) begin
                    hdop[51-st] = dataString;
                end else if ((st >= 53) && (st < 57) begin
                    geoid[56-st] = dataString;
                end else if ((st >= 58) && (st < 59) begin
                    metersH[58-st] = dataString;
                end else if ((st >= 60) && (st < 64) begin
                    geoidal[63-st] = dataString;
                end else if ((st >= 65) && (st < 66) begin
                    metersG[65-st] = dataString;
                end else if ((st >= 67) && (st < 70) begin
                    age[69-st] = dataString;
                end else if ((st >= 71) && (st < 81) begin
                    checksum[80-st] = dataString;
                //Checksum
                end else begin
                    cSum = gpgga ^ utc ^ latitude ^ ns ^ longitude ^ ew ^ quality ^ satellites ^ dilution ^ altitude ^ metersH ^ geoidal ^ metersG ^ age;
                    //data ready
                    if (!(cSum ^ checksum)) begin
                        dataReady = 1;
                    end else begin
                        dataReady <= 0;
                        st <= 99;
                    end
                end
            end
        end
    end

/////////////////////////////////////////////////////////////////////
//use state machine to track which register to write to
//use enum for state machine variable
//use case statement to get enum to work
//will recieve data 'backwards' ie most significant bit to leaset significant bit
//therefore must fill registers from top to bottom
//take in (byte at a time (ascii character at a time)) store them under some register associated with the name
//use commas with size index(how large each data is (5 chars, 10 chars, etc.)) to varafy the location in the string
//send a big string, one byte at a time, set TXD_start high whenever its outputing some byte
//link txd in testbench, to GPSuart in GPS.sv
//copy/paste GPS interface from URCrover into testbench

//should i include the commas in the output? (gpgga or gpgga, ?)
//how to enum?
//if statments showing lots of errors?
//what data to output? only whats in the GPSdata interface or all incoming data?
/////////////////////////////////////////////////////////////////////
    
endmodule