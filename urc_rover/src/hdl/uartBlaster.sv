
module uartBlaster #(
    parameter CLKFREQ = 100_000_000,    //100 MHz
    parameter BAUDRATE = 9600,
    parameter CLKS_PER_BIT = CLKFREQ/BAUDRATE
)(
    input wire       clk  ,
    input wire       start,
    input wire [7:0] data ,

    output logic uartTx  = 0,
    output wire  busy     ,
    output wire  ready
);

    logic BaudTick;
    logic [31:0] baudCounter;
    always_ff @(posedge clk) begin 
        if(busy) begin
            baudCounter <= baudCounter + 1;

            `ifdef SIMULATION
                if (baudCounter == 1000) begin //run much faster in sim to keep simtimes down
            `else
                if (baudCounter == (CLKS_PER_BIT-1)) begin
            `endif
                baudCounter <= 0;
                BaudTick <= 1;
            end else begin
                BaudTick <= 0;
            end
        end else begin
            baudCounter <= 0;
        end
    end
    // Transmitter state machine
    logic [3:0] state = 0;//5 bits if parity
    assign ready = (state==0);
    assign busy = ~ready;

    logic [7:0] TxD_datalogic;
    always @(posedge clk) if(ready & start) TxD_datalogic <= data;


    always_ff @(posedge clk)
    case(state)
    //    //parity
    //    5'b00000: if(start) state <= 5'b00001;
    //    5'b00001: if(BaudTick) state <= 5'b00100;
    //    5'b00100: if(BaudTick) state <= 5'b10000;  // start
    //    5'b10000: if(BaudTick) state <= 5'b10001;  // bit 0
    //    5'b10001: if(BaudTick) state <= 5'b10010;  // bit 1
    //    5'b10010: if(BaudTick) state <= 5'b10011;  // bit 2
    //    5'b10011: if(BaudTick) state <= 5'b10100;  // bit 3
    //    5'b10100: if(BaudTick) state <= 5'b10101;  // bit 4
    //    5'b10101: if(BaudTick) state <= 5'b10110;  // bit 5
    //    5'b10110: if(BaudTick) state <= 5'b10111;  // bit 6
    //    5'b10111: if(BaudTick) state <= 5'b11000;  // bit 7
    //    5'b11000: if(BaudTick) state <= 5'b00010;  // parity bit
    //    5'b00010: if(BaudTick) state <= 5'b00011;  // stop1
    //    5'b00011: if(BaudTick) state <= 5'b00000;  // stop2
    //    default: if(BaudTick) state <= 5'b00000;
    //    4'b0000: if(start) state <= 4'b0100;
    //    4'b0100: if(BaudTick) state <= 4'b1000;  // start bit
    //    4'b1000: if(BaudTick) state <= 4'b1001;  // bit 0
    //    4'b1001: if(BaudTick) state <= 4'b1010;  // bit 1
    //    4'b1010: if(BaudTick) state <= 4'b1011;  // bit 2
    //    4'b1011: if(BaudTick) state <= 4'b1100;  // bit 3
    //    4'b1100: if(BaudTick) state <= 4'b1101;  // bit 4
    //    4'b1101: if(BaudTick) state <= 4'b1110;  // bit 5
    //    4'b1110: if(BaudTick) state <= 4'b1111;  // bit 6
    //    4'b1111: if(BaudTick) state <= 4'b0011;  // bit 7 //10 for 2 stop bits
    //    //4'b0010: if(BaudTick) state <= 4'b0011;  // stop1
    //    4'b0011: if(BaudTick) state <= 4'b0000;  // stop2
    //    default: if(BaudTick) state <= 4'b0000;

        4'b0000: if(start) state <= 4'b0001;
        4'b0001: if(BaudTick) state <= 4'b0100;
        4'b0100: if(BaudTick) state <= 4'b1000;  // start
        4'b1000: if(BaudTick) state <= 4'b1001;  // bit 0
        4'b1001: if(BaudTick) state <= 4'b1010;  // bit 1
        4'b1010: if(BaudTick) state <= 4'b1011;  // bit 2
        4'b1011: if(BaudTick) state <= 4'b1100;  // bit 3
        4'b1100: if(BaudTick) state <= 4'b1101;  // bit 4
        4'b1101: if(BaudTick) state <= 4'b1110;  // bit 5
        4'b1110: if(BaudTick) state <= 4'b1111;  // bit 6
        4'b1111: if(BaudTick) state <= 4'b0010;  // bit 7
        4'b0010: if(BaudTick) state <= 4'b0011;  // stop1
        4'b0011: if(BaudTick) state <= 4'b0000;  // stop2
        default: if(BaudTick) state <= 4'b0000;

    endcase

    // Output mux
    logic muxbit;
    always_ff @( * )
        case(state[2:0])
            3'd0: muxbit <= TxD_datalogic[0];
            3'd1: muxbit <= TxD_datalogic[1];
            3'd2: muxbit <= TxD_datalogic[2];
            3'd3: muxbit <= TxD_datalogic[3];
            3'd4: muxbit <= TxD_datalogic[4];
            3'd5: muxbit <= TxD_datalogic[5];
            3'd6: muxbit <= TxD_datalogic[6];
            3'd7: muxbit <= TxD_datalogic[7];
            default: muxbit <= 1'b0;
        endcase

    // Put together the start, data and stop bits
    always_ff @(posedge clk) uartTx <= (state<4) | (state[3] & muxbit);  // logicister the output to make it glitch free

    // ifdef DEBUG
    //     ila_uart ILA (
    //         .clk    (clk         ),
    //         .probe0 (BaudTick    ),
    //         .probe1 (uartTx         ),
    //         .probe2 (TxD_datalogic )
    //     );
    // endif

endmodule