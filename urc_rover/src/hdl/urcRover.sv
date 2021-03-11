//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 02/10/2021 04:36:39 PM
// Design Name: 
// Module Name: urcRover
// Project Name: urc_rover
// Target Devices: Artix 7 35T
// Tool Versions: Vivado 2020.2
// Description: Top level module for urc rover
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import roversPackage::*;

module urcRover #(
    parameter SYSCLK_FREQ = 100_000_000
)(
    input OSCCLK,
    input EXTRST,

    output UART_TX
);

wire clk_100M; //main system clock
wire sysRstn;

wire uartStart;
wire uartBusy;
wire uartReady;

wire [7:0] uartData;


//////////////////////////////////////////////////////////////////////////////////
// Top level Logic
//////////////////////////////////////////////////////////////////////////////////

assign sysRstn = !EXTRST;

//////////////////////////////////////////////////////////////////////////////////
// IP Modules
//////////////////////////////////////////////////////////////////////////////////

clk_wiz_0 clkgen(
    .clk_in1 (OSCCLK  ), //12MHz
    .resetn  (sysRstn ),
    .clk_out1(clk_100M)
);

`ifdef DEBUG
    ila_0 topLevel_ILA(
        .clk(clk_100M),
        .probe0(sysRstn)
    );
`endif

//////////////////////////////////////////////////////////////////////////////////
// Module Declarations
//////////////////////////////////////////////////////////////////////////////////

railSensors #(
    .SYSCLK_FREQ(SYSCLK_FREQ),
    .NUMADCS(5)
) sensing (
    .sclk(clk_100M),
    .rstn(sysRstn),
    .sdat(RAIL_SDAT),
    .cs(RAIL_CS),
    .mclk(RAIL_MCLK),
    .outData(railOutData)
);

serialController #(
    .CLKFREQ(SYSCLK_FREQ)
) serialFormat (
    .sclk(clk_100M),
    .rstn(sysRstn),

    .uartReady(uartReady),
        
    .dataReady(uartStart),
    .outByte(uartData)
);

uartBlaster #(
    .CLKFREQ(SYSCLK_FREQ),
    .BAUDRATE(115200)
) gottaBlast (
    .clk(clk_100M),
    .start(uartStart),
    .data(uartData),

    .uartTx(UART_TX),
    .busy(uartBusy),
    .ready(uartReady)
);


endmodule:urcRover