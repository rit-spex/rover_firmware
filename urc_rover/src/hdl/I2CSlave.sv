//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 02/10/2022 10:07:42 PM
// Design Name: 
// Module Name: I2CSlave
// Project Name: urc_rover
// Target Devices: Artix 7 35T
// Tool Versions: Vivado 2020.2
// Description: I2C communications bus slave module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import roversPackage::*;

module I2CSlave #(
    parameter [6:0]     DEVICE_ADDR = 7'h55,
    parameter bus08_t   HI_WR = 8'h0F,
    parameter bus08_t   HI_RD = 8'h0F
) (
    //I2C
    input wire SCL;
    inout tri SDA;

    //FPGA
    input rstn;

    //8-bit read/write registers
    input   bus08_t readReg [HI_RD-1:0];
    output  bus08_t writeReg [HI_WR-1:0];
);

/////////////////////////////////////////////////////////////////////
//DECLARATIONS
/////////////////////////////////////////////////////////////////////

logic   startDetect;    //a START code has been received
logic   startResetter;  //resets the START code detector
logic   stopDetect;     //a STOP code has been received
logic   stopResetter;   //resets the STOP code detector
logic   masterAck;      //master acknowledge
logic   outputControl;  //control tri-state outputs

wire    rst             = ~rstn;
wire    startRst        = rst | startResetter;
wire    stopRst         = rst | stopResetter;
wire    lsbBit          = (bitCounter == 4'h7) && !startDetect;
wire    ackBit          = (bitCounter == 4'h8) && !stopDetect;
wire    writeStrobe     = (state == WRITE) && ackBit;
wire    addressDetect   = (inputShift[7:1] == DEVICE_ADDR);
wire    readWriteBit    = inputShift[0];

bus04_t bitCounter;

bus08_t             inputShift;
bus08_t             outputShift;
bus08_t             indexPointer;

enum logic [4:0] { IDLE, DEV_ADDR, READ, IDX_PTR, WRITE } state;

genvar i,j;

/////////////////////////////////////////////////////////////////////
//START DETECTION
/////////////////////////////////////////////////////////////////////


always_ff @ (posedge startRst, negedge SDA) begin : startDetector1
    if (startRst)
        startDetect <= 0;
    else
        startDetect <= SCL;
end

always_ff @ (posedge rstn, posedge SCL) begin : startDetector2
    if (rstn)
        startResetter <= 0;
    else
        startResetter <= startDetect;
end

/////////////////////////////////////////////////////////////////////
//STOP DETECTION
/////////////////////////////////////////////////////////////////////

always_ff @(posedge stopRst, posedge SDA ) begin : stopDetector1
    if (stopRst)
        stopDetect <= 1;
    else
        stopDetect <= SCL;
end

always_ff @(posedge rstn, posedge SCL ) begin : stopDetector2
    if (rstn)
        stopResetter <= 1;
    else
        stopResetter <= stopDetect;
end

/////////////////////////////////////////////////////////////////////
//INPUT LATCH
/////////////////////////////////////////////////////////////////////

always_ff @( negedge SCL ) begin : bitCounting
    if (ackBit || startDetect)
        bitCounter <= 0;
    else
        bitCounter <= bitCounter + 1;
end

always_ff @( posedge SCL ) begin : inputShifter
    if (!ackBit)
        inputShift <= {inputShift[6:0], SDA};
        //complete data byte holds for two falling edges of SCL
end

always_ff @( posedge SCL ) begin : masterAcknowledge
    if (ackBit)
        masterAck <= ~SDA;  
end

/////////////////////////////////////////////////////////////////////
//FSM
/////////////////////////////////////////////////////////////////////

always_ff @( posedge rst, negedge SCL ) begin : FSM
    if (rst) begin
        state <= IDLE;
    end else if (startDetect) begin
        state <= DEV_ADDR;
    end else if (ackBit) begin
        case (state)
            IDLE: begin
                state <= IDLE;
            end

            DEV_ADDR: begin
                if (!addressDetect) begin
                    state <= IDLE;
                end else if (readWriteBit) begin
                    state <= READ;
                end else begin
                    state <= IDX_PTR;
                end
            end

            READ: begin
                if (masterAck) begin
                    state <= READ;
                end else begin
                    state <= IDLE;
                end
            end

            IDX_PTR: begin
                state <= WRITE;
            end

            WRITE: begin
                state <= WRITE;
            end

            default: state <= IDLE;
        endcase
    end
end

/////////////////////////////////////////////////////////////////////
//REG TRANSFERS
/////////////////////////////////////////////////////////////////////

//index pointer is loaded by the first transfer in a write transaction,
//incremented every other transfer, and reset on a START condition
//(but not RESTART).
always_ff @( posedge rst, negedge SCL) begin : indexPointerXfer
    if (rst) begin
        indexPointer <= 0;
    end else if (stopDetect) begin
        indexPointer <= 0;
    end else if (ackBit) begin
        if (state == IDX_PTR) begin
            indexPointer <= inputShift;
        end else begin
            indexPointer <= indexPointer + 1;
        end
    end
end

//For each register, once per transfer, we check to see if it’s being
//addressed for writing, and if so, we latch the value in the input
//shift register.
generate
    for (i = 0; i <= HI_WR; i = i+1) begin : registerWritesGen
        always_ff @( posedge rst, negedge SCL ) begin : regWrites
            if (rst) begin
                writeReg[i] <= 0;
            end else if (writeStrobe && (indexPointer == 8'h03)) begin
                writeReg[i] <= inputShift;
            end
        end
    end
endgenerate


//output shift register must be loaded before ADK bit
generate
    for (j = 0;j <= HI_RD; j = j+1) begin : registerReadsGen

        always_ff @( negedge SCL ) begin : regReads
            if (lsbBit) begin
                if (indexPointer == j) begin
                    outputShift <= readReg[j];
                end
            end else begin
                outputShift <= {outputShift[6:0], 1'b0};
            end
        end
    end
endgenerate

/////////////////////////////////////////////////////////////////////
//OUTPUT DRIVER
/////////////////////////////////////////////////////////////////////

assign SDA = outputControl ? 1'bz : 1'b0;

//This logic is a little subtle, because we have to set the state for
//the next SCL clock cycle, taking into account that the state
//machine’s state for the next cycle may not be the same as what it
//is for the current cycle
always_ff @( posedge rst, negedge SCL ) begin : outputDriver
    if (rst) begin
        outputControl <= 1'b1;
    end else if (startDetect) begin
        outputControl <= 1'b1;
    end else if (lsbBit) begin
        outputControl <=
            !(((state == DEV_ADDR) && addressDetect) ||
              (state == IDX_PTR) ||
              (state == WRITE));
    end else if (ackBit) begin
        //deliver first bit of next slave-to-master transfer if needed
        if (((state == READ) && masterAck) || ((state == DEV_ADDR) && addressDetect && readWriteBit)) begin
            outputControl <= outputShift[7];
        end else begin
            outputControl <= 1'b1;
        end
    end else if (state == READ) begin
        outputControl <= outputShift[7];
    end else begin
        outputControl <= 1'b1;
    end
end

endmodule