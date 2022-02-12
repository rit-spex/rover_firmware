//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 02/10/2022 10:07:42 PM
// Design Name: 
// Module Name: quadratureEnc
// Project Name: urc_rover
// Target Devices: Artix 7 35Txvlog
// Tool Versions: Vivado 2020.2
// Description: Quadrature encoder interface, 4X decoding
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module quadratureEnc #(
    parameter SYSCLK_FREQ = 100_000_000,
    parameter ENC_CYCLES_PER_REV = 2048,
    parameter ENC_COUNTS_PER_REV = ENC_CYCLES_PER_REV * 4,
    parameter ENC_COUNT_SIZE = $clog2(ENC_COUNTS_PER_REV),
    parameter SAMPLETIME = 1_000, //sample time, microseconds
    parameter MAXCOUNT = SYSCLK_FREQ / (SAMPLETIME * 1_000_000) // counts = (counts/second) / ((microseconds * 1,000,000)))
) (
    input sclk,
    input rstn,

    input enc_a,
    input enc_b,
    input enc_i,

    input home,

    output logic [ENC_COUNT_SIZE-1:0] count,

    output logic signed [10:-5] pcSpeed, //11 bits integer, 5 bits fractional
    output logic signed [10:-5] ptSpeed  //11 bits integer, 5 bits fractional
);

    wire [31:0] pcSpeedBig, pcSpeedDenom, pcSpeedNumer;
    wire [31:0] ptSpeedBig, ptSpeedDenom, ptSpeedNumer;

    logic [31:0] intervalCount, pulses, pulseCount, clocks, clockCount;

    logic [2:0] a_delayed, b_delayed;

    always_ff @( negedge sclk ) begin : outputLatch
        pcSpeed <= pcSpeedBig;
        ptSpeed <= ptSpeedBig;
    end

/////////////////////////////////////////////////////////////////////
//SYNCHRO
/////////////////////////////////////////////////////////////////////

    always_ff @(posedge sclk ) begin : synchro
        if (!rstn) begin
            a_delayed <= 0;
            b_delayed <= 0;
        end else begin
            a_delayed <= {a_delayed[1:0], enc_a};
            b_delayed <= {b_delayed[1:0], enc_b};
        end
    end

/////////////////////////////////////////////////////////////////////
//DECODING
/////////////////////////////////////////////////////////////////////

    wire countEnable = a_delayed[1] ^ a_delayed[2] ^ b_delayed[1] ^ b_delayed[2];
    wire countDir = a_delayed[1] ^ b_delayed[2];

/////////////////////////////////////////////////////////////////////
//COUNTER
/////////////////////////////////////////////////////////////////////

    always_ff @(posedge sclk ) begin : encCounter
        if (!rstn) begin
            count <= 0;
        end else if (home) begin
            count <= 0;
        end else begin
            if (countEnable) begin
                if (countDir) begin
                    count <= count + 1;
                end else begin
                    count <= count - 1;
                end
            end
        end
    end

/////////////////////////////////////////////////////////////////////
//PULSE COUNTING SPEED
/////////////////////////////////////////////////////////////////////

    //less accurate at low speeds
    always_ff @( posedge sclk ) begin : pulseCounter
        if (!rstn) begin
            pulses <= 0;
            pulseCount <= 0;
        end else if (home) begin
            pulses <= 0;
            pulseCount <= 0;
        end else begin
            if (intervalCount == (MAXCOUNT - 1)) begin
                intervalCount <= 0;
                pulses <= 0;
                pulseCount <= pulses;
            end else begin
                intervalCount <= intervalCount + 1;
                if (countEnable) begin
                    pulses <= pulses + 1;
                end
            end
        end
    end

    // gives pcSpeed in pi*radians/second
    assign pcSpeedDenom = (ENC_CYCLES_PER_REV * SAMPLETIME) << 5;
    assign pcSpeedNumer = (2 * pulseCount) << 5;
    assign pcSpeedBig = pcSpeedNumer / pcSpeedDenom; //TODO: Check this math

/////////////////////////////////////////////////////////////////////
//PULSE TIMING SPEED
/////////////////////////////////////////////////////////////////////

    //less accurate at high speeds
    always_ff @( posedge sclk ) begin : pulseTimer
        if (!rstn) begin
            clocks <= 0;
        end else if (home) begin
            clocks <= 0;
        end else begin
            if (countEnable) begin
                clocks <= 0;
                clockCount <= clocks;
            end else begin
                clocks <= clocks + 1;
            end
        end
    end

    //gives ptSpeed in pi*radians/second
    assign ptSpeedDenom = (ENC_COUNTS_PER_REV * clockCount) << 5;
    assign ptSpeedNumer = (2 * SYSCLK_FREQ) << 5;
    assign ptSpeedBig = ptSpeedNumer / ptSpeedDenom; //TODO: check this math


endmodule