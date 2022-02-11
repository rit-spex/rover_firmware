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
    parameter SYSCLK_FREQ = 100_000_000,
    parameter NUM_ADCS = 5,
    parameter NUM_ENC = 4,

    parameter ENC_CYCLES_PER_REV = 2048,
    parameter ENC_COUNTS_PER_REV = ENC_CYCLES_PER_REV * 4,
    parameter ENC_COUNT_SIZE = $clog2(ENC_COUNTS_PER_REV)
)(
    input OSCCLK,
    input EXTRST,

    inout SDA,
    input SCL,

    input [NUM_ADCS-1:0] ADC_SDAT,
    input [NUM_ADCS-1:0] ADC_MCLK,

    input [NUM_ENC-1:0] ENC_ABS,
    input [NUM_ENC-1:0] ENC_A,
    input [NUM_ENC-1:0] ENC_B,
    input [NUM_ENC-1:0] ENC_I
    
);

wire clk_100M; //main system clock
wire sysRstn;

wire uartStart;
wire uartBusy;
wire uartReady;

wire encHome;
wire [ENC_COUNT_SIZE-1:0] encCount [NUM_ENC-1:0];
wire [10:-5] pcSpeed [NUM_ENC-1:0];
wire [10:-5] ptSpeed [NUM_ENC-1:0];

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

//railSensors #(
//    .SYSCLK_FREQ(SYSCLK_FREQ),
//    .NUMADCS(NUM_ADCS)
//) sensing (
//    .sclk(clk_100M),
//    .rstn(sysRstn),
//    .sdat(ADC_SDAT),
//    .cs(ADC_CS),
//    .mclk(ADC_MCLK),
//    .outData(railOutData)
//);

GPS #(
    .SYSCLK_FREQ(SYSCLK_FREQ)
) jeeps (
    .sclk(clk_100M)
);

CPUComms #(
    .SYSCLK_FREQ(SYSCLK_FREQ)
) comms (
    .sclk(clk_100M),
    .rstn(sysRstn),
    .SDA(SDA),
    .SCL(SCL)
);

genvar i;
generate
    for (i = 0;i < NUM_ENC;i = i + 1) begin
        quadratureEnc #(
            .SYSCLK_FREQ(SYSCLK_FREQ)
        ) quad (
            .sclk(clk_100M),
            .rstn(sysRstn),
            .enc_a(ENC_A[i]),
            .enc_b(ENC_A[i]),
            .enc_i(ENC_I[i]),
            .home(encHome),
            .count(encCount[i]),
            .pcSpeed(pcSpeed[i]),
            .ptSpeed(ptSpeed[i])
        );
    end
endgenerate

// serialController #(
//     .CLKFREQ(SYSCLK_FREQ)
// ) serialFormat (
//     .sclk(clk_100M),
//     .rstn(sysRstn),

//     .uartReady(uartReady),
        
//     .dataReady(uartStart),
//     .outByte(uartData)
// );

// uartBlaster #(
//     .CLKFREQ(SYSCLK_FREQ),
//     .BAUDRATE(115200)
// ) gottaBlast (
//     .clk(clk_100M),
//     .start(uartStart),
//     .data(uartData),

//     .uartTx(UART_TX),
//     .busy(uartBusy),
//     .ready(uartReady)
// );


endmodule:urcRover