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

module AD7478_tb(
    input CS,
    input SCLK,
    output logic SDAT = 1'bz
);

timeunit 1ns;
timeprecision 1ns;

logic mclk;
logic CSlast;
int count;
logic [7:0] value = 0;
logic [7:0] valueHold = 0;

enum logic[15:0] { LEAD, DATA, FOLLOW, WAIT } state, nextState = WAIT;

initial begin
    forever begin
        value <= value + 1;
        #10000;
    end
end

always begin
    forever begin
        if (!CS) begin
            mclk <= SCLK;
        end else if (CS) begin
            mclk <= 1;
        end
        #1;
    end
end

always begin
    forever begin
        CSlast <= CS;
        #1;
    end
end

always begin
    forever begin
        state <= nextState;

        if (CSlast && !CS) begin
            state <= LEAD;
            valueHold <= value;
        end else if (!CSlast && CS) begin
            state <= WAIT;
            nextState <= WAIT;
            SDAT <= 1'bz;
            count <= 0;
        end

        #1;
    end
end

always @(negedge mclk) begin
    case (state)
        LEAD: begin

            SDAT <= 0;

            if (count >= 3) begin
                nextState <= DATA;
                count <= 0;
            end else begin
                nextState <= state;
                count <= count + 1;
            end
        end

        DATA: begin
            
            SDAT <= valueHold[count];

            if (count >= 7) begin
                nextState <= FOLLOW;
                count <= 0;
            end else begin
                state <= state;
                count = count + 1;
            end
        end

        FOLLOW: begin
            
            SDAT <= 0;

            if (count >= 3) begin
                nextState <= WAIT;
                count <= 0;
            end else begin
                state <= state;
                count <= count + 1;
            end
        end

        WAIT: begin
            SDAT <= 1'bz;
        end

        default: begin
            nextState <= WAIT;
        end
    endcase
end
    
endmodule