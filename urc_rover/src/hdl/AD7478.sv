//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 03/05/2021 8:07:42 PM
// Design Name: 
// Module Name: AD7478
// Project Name: urc_rover
// Target Devices: Artix 7 35T
// Tool Versions: Vivado 2020.2
// Description: AD7478 Driver & interpreter
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import roversPackage::*;
typedef enum logic[2:0] {adcIDLE, PREZEROES, DATAPARSE, POSTZEROES, DATATRANSFER} adcState;

//(* fsm_encoding = "none" *) adcState currentState, nextState = adcIDLE;

module AD7478 #(
    parameter SYSCLK_FREQ = 100_000_000
)(
    input logic sclk,
    input logic rstn,

    input logic sdat,
    
    output logic cs = 1,
    output logic mclk = 0,

    output bus08_t outData = 0
);

    logic adcStart;
    logic [31:0] preDataCounter = 3;     //pre dataparse zeroes counter
    logic [31:0] postDataCounter = 3;   //post dataparse zeroes counter
    logic [2:0] clkCounter = 3'b101;        //mclk counter
    logic [31:0] dataCounter = 7;       //8 bits of data
    logic [7:0] tempData = 0;
    (* fsm_encoding = "none" *) adcState currentState = adcIDLE;  
    localparam [31:0] countMax = (SYSCLK_FREQ/5) /1_000_000;
    logic [31:0] idleTimeCounter = countMax; //1 us idle time, based off 100MHz sclk
     
always_ff @( posedge mclk ) begin : Serial
    if(!rstn) begin
        outData <= 0;
        cs <= 1;
        mclk <= 0;
    end 
    else begin
        //currentState <= nextState;
        case( currentState )   
            adcIDLE : begin
                if( idleTimeCounter != 0 ) begin
                    cs <= 1;
                    idleTimeCounter <= idleTimeCounter - 1'b1;
                    currentState <= adcIDLE;
                end
                else begin
                    cs <= 0;
                    idleTimeCounter <= countMax;
                    currentState <= PREZEROES;
                end                        
            end      
            PREZEROES : begin
                cs <= 0;
                
                preDataCounter <= preDataCounter - 1'b1;
                if( preDataCounter != 2'b00) currentState <= PREZEROES;
                else begin
                    currentState <= DATAPARSE;
                    preDataCounter <= 3;
                end                
            end
            DATAPARSE : begin
                cs <= 0;
                tempData <= {tempData[6:0], sdat};

                
                if( dataCounter > 0) begin
                    currentState <= DATAPARSE;
                    dataCounter <= dataCounter - 1'b1;
                end
                else begin
                    currentState <= POSTZEROES;
                    dataCounter <= 7;
                end                    
            end 
            POSTZEROES : begin
                cs <= 0;
               
                if( postDataCounter == 3'b000) begin
                    currentState <= DATATRANSFER;
                    postDataCounter = 3;
                end
                else begin
                    currentState <= POSTZEROES;
                    postDataCounter <= postDataCounter - 1'b1;
                end                
            end
            DATATRANSFER : begin
                cs <= 0;
                outData <= tempData;
                currentState <= adcIDLE;
            end
        endcase      
    end
end : Serial
    
always @( posedge sclk ) begin
    clkCounter <= clkCounter - 1'b1;
    if( clkCounter == 3'b000 ) begin
        mclk <= ~mclk;
        clkCounter <= 3'b101;
    end
end

endmodule