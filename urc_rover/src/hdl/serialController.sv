//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 02/11/2021 01:31:12 PM
// Design Name: 
// Module Name: serialController
// Project Name: urc_rover
// Target Devices: Artix 7 35T
// Tool Versions: Vivado 2020.2
// Description: Data formatter for driving the uartBlaster. Sends data to CPU
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import roversPackage::*;
typedef enum logic [7:0] { IDLE, LOADDATA, SENDBYTE, HOLD, WAIT, RESET } fsm_t;

module serialController #(
    parameter CLKFREQ  = 100_000_000
)(
    input wire sclk,
    input wire rstn,
    input wire uartReady,

    //data inputs

    //data output
    output bus08_t outByte   = 0,
    output logic   dataReady = 0
);

    logic transmitting   = 0;
    logic startTx        = 0;
    logic dataReadyDelay = 0;
    logic messageDone    = 0;

    bus32_t count  = 0;
    bus08_t offset = 0;

    (* FSM_ENCODING="ONE_HOT", SAFE_IMPLEMENTATION="NO" *)
    bus08_t serialState = IDLE;

//////////////////////////////////////////////////////////////////////////////////
// Combinational Logic
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Sequential Logic
//////////////////////////////////////////////////////////////////////////////////

    //sclk domain
    always_ff @( posedge sclk ) begin : behavioral
        if (!rstn) begin
            transmitting <= 0;
            startTx <= 0;
        end else begin
            //logic here
        end
    end : behavioral

    always_ff @( posedge sclk ) begin : FSM
        if (!rstn) begin
            serialState <= RESET;
        end else begin
            case (serialState)
                IDLE: begin
                    
                end

                LOADDATA: begin
                    
                end

                SENDBYTE: begin
                    
                end

                HOLD: begin
                    
                end

                WAIT: begin
                    
                end

                RESET: begin
                    
                end

                default: begin
                    serialState <= RESET;
                end
            endcase
        end
    end : FSM
    
endmodule