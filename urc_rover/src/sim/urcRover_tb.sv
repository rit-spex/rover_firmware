//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 02/10/2021 04:36:39 PM
// Design Name: 
// Module Name: urcRover_tb
// Project Name: urc_rover
// Target Devices: N/A
// Tool Versions: Vivado 2020.2
// Description: Top level testbench for urc rover
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module urcRover_tb;
    timeunit      1ns;
    timeprecision 1ps;

    logic OSCCLK_tb = 0;
    logic SYSRST_tb = 1;

    logic adcCS;
    logic adcmclk;
    wire adcsdat;

    urcRover #(
        .NUM_ADCS(1)
    ) DUT (
        .OSCCLK(OSCCLK_tb),
        .EXTRST(SYSRST_tb),

        .ADC_CS(adcCS),
        .ADC_MCLK(adcmclk),
        .ADC_SDAT(adcsdat)
    );

    AD7478_tb adc (
        .SCLK(adcmclk),
        .CS(adcCS),
        .SDAT(adcsdat)
    );

    //12MHz oscillator
    initial begin
       forever begin
           #41.66666666666666666666666;
           OSCCLK_tb <= ~OSCCLK_tb;
       end 
    end

    initial begin
        adcmclk <= 0;
        adcCS <= 1;

        forever begin
            #50
            adcmclk = ~adcmclk;
        end
    end

    //wait 1us to disable reset - allows clock converter to start up properly in sim
    initial begin
        #1000;
        SYSRST_tb <= 0;
    end


endmodule:urcRover_tb