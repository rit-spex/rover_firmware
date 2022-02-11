//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 02/10/2022 10:07:42 PM
// Design Name: 
// Module Name: wheelEncoders
// Project Name: urc_rover
// Target Devices: Artix 7 35Txvlog
// Tool Versions: Vivado 2020.2
// Description: wrapper for GPS and encoder logic
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module wheelEncoders #(
    parameter SYSCLK_FREQ = 100_000_000,
    parameter ENC_CYCLES_PER_REV = 2048,
    parameter ENC_COUNTS_PER_REV = ENC_CYCLES_PER_REV * 4,
    parameter ENC_COUNT_SIZE = $clog2(ENC_COUNTS_PER_REV)
) (
    input sclk,
    input rstn,

    input [3:0] enc_a,
    input [3:0] enc_b,
    input [3:0] enc_i,

    input encHome,

    output logic [ENC_COUNT_SIZE-1:0] encCount [3:0],

    input GPSdata,
    
    output logic GPSfix,
    output logic GPSlatitude,
    output logic GPSlongitude,
    output logic GPSquality,
    output logic GPSspeed,
    output logic GPSnumSats
);

genvar i;
generate
    for (i = 0;i < 4;i = i + 1) begin
        quadratureEnc #(
            .COUNTS_PER_REV(ENC_COUNTS_PER_REV),
            .COUNT_SIZE(ENC_COUNT_SIZE)
        ) quad (
            .sclk(sclk),
            .rstn(rstn),
            .enc_a(enc_a[i]),
            .enc_b(enc_b[i]),
            .enc_i(enc_i[i]),
            .home(encHome),
            .count(encCount[i])
        );
    end
endgenerate
    
endmodule