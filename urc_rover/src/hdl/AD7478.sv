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

(* fsm_encoding = "none" *) adcState currentState, nextState;

module AD7478 #(
    parameter SYSCLK_FREQ = 100_000_000
)(
    input logic sclk,
    input logic rstn,

    input logic sdat,
    
    output logic cs,
    output logic mclk,

    output bus08_t outData
);

    logic [6:0] idleTimeCounter = 7'b1100100; //1 us idle time, based off 100MHz sclk
    logic adcStart;
    logic [1:0] preDataCounter = 2'b11;     //pre dataparse zeroes counter
    logic [2:0] postDataCounter = 3'b100;   //post dataparse zeroes counter
    logic [2:0] clkCounter = 3'b101;        //mclk counter
    logic [2:0] dataCounter = 3'b111;       //8 bits of data
    logic [7:0] tempData = 0;
    
always_ff @( sclk ) begin : Serial
    if(!rstn) begin
        outData <= 0;
        cs <= 0;
        mclk <= 0;
    end 
    else begin
        currentState <= nextState;
        case( currentState )   
            adcIDLE : begin
                if( adcStart != 1'b1 ) begin
                    cs <= 1;
                    //latch output data
                   // outData <= tempData; //change this kater
                end
                else cs <= 0;
                
                if (adcStart == 1'b1) nextState <= PREZEROES;
                else nextState <= adcIDLE;
            end      
            PREZEROES : begin
                cs <= 0;
                
                preDataCounter <= preDataCounter - 1'b1;
                if( preDataCounter != 2'b00) nextState <= PREZEROES;
                else begin
                    nextState <= DATAPARSE;
                    preDataCounter <= 2'b11;
                end                
            end
            DATAPARSE : begin
                cs <= 0;
                tempData <= {tempData[6:0], sdat};

                dataCounter <= dataCounter - 1'b1;
                if( dataCounter >= 3'b000) nextState <= DATAPARSE;
                else begin
                    nextState <= POSTZEROES;
                    dataCounter <= 3'b111;
                end                    
            end 
            POSTZEROES : begin
                cs <= 0;
               
                postDataCounter <= postDataCounter - 1'b1;
                if( postDataCounter == 3'b000) begin
                    //nextState = adcIDLE;
                    nextState <= DATATRANSFER;
                end
                else nextState <= POSTZEROES;                
            end
            DATATRANSFER : begin
                cs <= 0;
                outData <= tempData;
                nextState <= adcIDLE;
            end
        endcase      
    end
end : Serial
    
always_ff @( sclk ) begin
    if( idleTimeCounter != 7'b0000000 ) begin
        adcStart <= 1'b0;
        idleTimeCounter <= idleTimeCounter - 1'b1;
    end
    else begin
        adcStart <= 1'b1;
        idleTimeCounter <= 7'b1100100;
    end  
end
    
/*always_comb begin
    case ( currentState )
        adcIDLE : begin
            if (adcStart == 1'b1) nextState = PREZEROES;
            else nextState = adcIDLE;
        end
        PREZEROES : begin
            preDataCounter = preDataCounter - 1'b1;
            if( preDataCounter != 2'b00) nextState = PREZEROES;
            else begin
                nextState = DATAPARSE;
                preDataCounter = 2'b11;
            end
        end 
        DATAPARSE : begin
            dataCounter = dataCounter - 1'b1;
            if( dataCounter >= 3'b000) nextState = DATAPARSE;
            else begin
                nextState = POSTZEROES;
                dataCounter = 3'b111;
            end
        end
        POSTZEROES : begin
            postDataCounter = postDataCounter - 1'b1;
            if( postDataCounter == 3'b000) begin
                nextState = adcIDLE;
            end
            else nextState = POSTZEROES;
        end  
    endcase 
end */  

always @( posedge sclk ) begin
    clkCounter <= clkCounter - 1'b1;
    if( clkCounter == 3'b000 ) begin
        mclk <= ~mclk;
        clkCounter <= 3'b101;
    end
end

endmodule