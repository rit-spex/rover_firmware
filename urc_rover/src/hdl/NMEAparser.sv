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

    input [7:0] dataByte, 
    input       dataReady,

    GPSdata gpsResults,

    output logic GPSReady //goes high when all data is valid
);

    logic [ 5:0] [7:0] gpgga    ; //0
    logic [10:0] [7:0] utc      ; //1
    logic [ 9:0] [7:0] latitude ; //2
    logic [ 1:0] [7:0] ns       ; //3
    logic [10:0] [7:0] longitude; //4
    logic [ 1:0] [7:0] ew       ; //5
    logic [ 1:0] [7:0] quality  ; //6
    logic [ 1:0] [7:0] numSats  ; //7
    logic [ 4:0] [7:0] hdop     ; //8
    logic [ 4:0] [7:0] geoid    ; //9
    logic [ 1:0] [7:0] metersH  ; //10
    logic [ 4:0] [7:0] geoidal  ; //11
    logic [ 1:0] [7:0] metersG  ; //12
    logic [ 3:0] [7:0] age      ; //13
    logic [ 1:0] [7:0] checksum ; //14
    logic [ 1:0] [7:0] cSum     ; //15
    //logic [ 3:0] altMSL      [7:0]; //14
    logic olst, st;

    logic [4:0] index;

    enum logic[15:0] { IDLE, FORMAT, TIMESTAMP, LATITUDE, NS, LONGITUDE } dataBlock;

    always_ff @(posedge sclk ) begin : parser
        case (dataBlock)
            IDLE: begin
                
            end

            FORMAT: begin
                if (dataReady) begin //ONLY WORKS IF DATAREADY IS HIGH FOR ONLY 1 CLOCK CYCLE
                    if (index >= 5) begin
                        if (gpgga == /*gpgga ASCII*/1) begin
                            if (dataByte == /*comma ASCII*/1) begin
                                index <= 0;
                                dataBlock <= TIMESTAMP;
                            end else begin
                                index <= 0;
                                dataBlock <= IDLE;
                            end
                        end else begin
                            index <= 0;
                            dataBlock <= IDLE;
                        end
                    end
                    gpgga <= {gpgga[4:0], dataByte};
                    index <= index + 1;

                end else begin
                    dataBlock <= FORMAT;
                end
            end

            TIMESTAMP: begin
                
            end

            LONGITUDE: begin
                
            end

            NS: begin
                
            end

            LATITUDE: begin
                
            end
            default: begin
                datablock <= FORMAT;
            end
        endcase

    end

    // always_ff @(posedge sclk ) begin : parser
    //     //check if reset (active low)
    //     if ((!rstn) || (st == 99)) begin
    //         GPSReady <= 0;
    //         gpgga <= 0;
    //         utc <= 0;
    //         latitude <= 0;
    //         ns <= 0;
    //         longitude <= 0;
    //         ew <= 0;
    //         quality <= 0;
    //         numSats <= 0;
    //         hdop <= 0;
    //         geoid <= 0;
    //         metersH <= 0;
    //         geoidal <= 0;
    //         metersG <= 0;
    //         age <= 0;
    //         cSum <= 0;
    //         st <= 1;
    //     end 
    //     //check for $
    //     else if (!(dataByte ^ 8'b00100100)) begin
    //         GPSReady <= 0;
    //         st <= 2;
    //     end 
    //     //validate GPGGA after $
    //     else if ((st >= 2) && (st < 7)) begin
    //         if ((st == 2) && (!(dataByte ^ 8'b01000111))) begin
    //             gpgga[5] <= dataByte;
    //             st <= 3;
    //         end else if ((st == 3) && (!(dataByte ^ 8'b01010000))) begin
    //             gpgga[4] <= dataByte;
    //             st <= 4;
    //         end else if ((st == 4) && (!(dataByte ^ 8'b01000111))) begin
    //             gpgga[3] <= dataByte;
    //             st <= 5;
    //         end else if ((st == 5) && (!(dataByte ^ 8'b01000111))) begin
    //             gpgga[2] <= dataByte;
    //             st <= 6;
    //         end else if ((st == 6) && (!(dataByte ^ 8'b01000001))) begin
    //             gpgga[1] <= dataByte;
    //             st <= 7;
    //         end else begin
    //             st <= 99;
    //         end
    //     end
    //     //Parse
    //     else if (st >= 7) begin
    //         //validate ,'s are where expected
    //         if ((st == 7) || (st == 18) || (st == 28) || (st == 30) || (st == 41) || (st == 43) || (st == 45) || (st == 47) || (st == 52) || (st == 57) || (st == 59) || (st == 64) || (st == 66) || (st == 70)) begin
    //             if (!(dataByte ^ 8'b00101100)) begin
    //                 olst = st;
    //                 st++;
    //                 if (st == 7) begin
    //                     gpgga[0] = dataByte;
    //                 end
    //             end else begin
    //                 st = 99;
    //             end
    //         //fill arrays with values
    //         end else if (st < 82) begin
    //             if ((st >= 8) && (st < 18)) begin
    //                 utc[17-st] = dataByte;
    //             end else if ((st >= 19) && (st < 28)) begin
    //                 latitude[27-st] = dataByte;
    //             end else if ((st >= 29) && (st < 30)) begin
    //                 ns[29-st] = dataByte;
    //             end else if ((st >= 31) && (st < 41)) begin
    //                 longitude[40-st] = dataByte;
    //             end else if ((st >= 42) && (st < 43)) begin
    //                 ew[42-st] = dataByte;
    //             end else if ((st >= 44) && (st < 45)) begin
    //                 quality[44-st] = dataByte;
    //             end else if ((st >= 46) && (st < 47)) begin
    //                 numSats[46-st] = dataByte;
    //             end else if ((st >= 48) && (st < 52)) begin
    //                 hdop[51-st] = dataByte;
    //             end else if ((st >= 53) && (st < 57)) begin
    //                 geoid[56-st] = dataByte;
    //             end else if ((st >= 58) && (st < 59)) begin
    //                 metersH[58-st] = dataByte;
    //             end else if ((st >= 60) && (st < 64)) begin
    //                 geoidal[63-st] = dataByte;
    //             end else if ((st >= 65) && (st < 66)) begin
    //                 metersG[65-st] = dataByte;
    //             end else if ((st >= 67) && (st < 70)) begin
    //                 age[69-st] = dataByte;
    //             end else if ((st >= 71) && (st < 81)) begin
    //                 checksum[80-st] = dataByte;
    //             st++;
    //             //Checksum
    //             end else begin
    //                 cSum = gpgga ^ utc ^ latitude ^ ns ^ longitude ^ ew ^ quality ^ numSats ^ dilution ^ altitude ^ metersH ^ geoidal ^ metersG ^ age;
    //                 //data ready
    //                 if (!(cSum ^ checksum)) begin
    //                     GPSReady <= 1;
    //                 end else begin
    //                     GPSReady <= 0;
    //                     st <= 99;
    //                 end
    //             end
    //         end
    //     end
    // end

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