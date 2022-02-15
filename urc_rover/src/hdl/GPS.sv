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

    input GPSuart,
    
    GPSdata GPSresults
);

wire       dataReady;
wire [7:0] GPSdata;


async_receiver #(
    .ClkFrequency(SYSCLK_FREQ),
    .Baud(9600)
) GPSrx (
    .clk(clk_100M),
    .rst(~rstn),
    .RxD(GPSuart),
    .RxD_data(GPSdata),
    .RxD_data_ready(dataReady)
);

NMEAparser #(
    .SYSCLK_FREQ(SYSCLK_FREQ)
) parser (
    .sclk(sclk),
    .rstn(rstn),
    .dataReady(dataReady),
    .dataString(GPSdata),
    .GPSresults(gpsResults)
);

endmodule