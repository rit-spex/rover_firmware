module AMC1303Mx #(
    parameter SYSCLK_FREQ = 100_000_000
) (
    input logic mclk,      // the magical clock
    
    input logic resetn,    // active low reset, need to invert because
                           // dec256sinc24b is active high reset
    input logic sdat,
    
    output logic dec_filter_data_en,    // the data_en output for the decimation
                                        // filter, dec256sinc24b, after getting 
                                        // passed through the flipflops "CDC"
    
    output logic [15:0] out_data
);

`timescale 1ns/1ps

//===================================================================
// Parameters and regs
//===================================================================
    reg rst;       // inverted reset signal for the decimation filter
    
    reg cdc_data_en_input;   // data_en output for the decimation filter. It will
                             // go through CDC as the input for the first flipflop
          
    reg data_en_ff1;    // output of the first flipflop in CDC, as 
                        // well as the input for the second FF in the CDC
    
    reg [15:0] adcDat;    // connects the output of decimation filter 
                          // to the CDC, aka ghetto FIFO.
                          
    reg [15:0] cdc1;      // output of the first FF in CDC, as well as the 
                          // input of the second FF in CDC.

//===================================================================
// Signal Assignment
//===================================================================    
    assign rst = ~resetn;    // inverts the input reset low into a reset
                             // high the decimation filter uses

//===================================================================
// Architecture
//===================================================================

//===================================================================
// Decimation Filter
//===================================================================
dec256sinc24b #(
    .SYSCLK_FREQ(SYSCLK_FREQ)
) decimator (
    .mclk1(mclk),
    .reset(rst),
    .mdata1(sdat),
    .DATA(adcDat),
    .data_en(cdc_data_en_input)
);

//===================================================================
// FIFO from wish: 2 flipflops
//===================================================================
//  the register names are kind of confusing, below is a rough sketch:
//  both the "data_en" and "DATA" outputs need to propagate through CDC
//  dec256sinc24b output port -> FF0 -> FF1 -> AMC1303Mx output port
//  DATA port -> adcDat -> cdc1 -> out_data
//  data_en port -> cdc_data_en_input -> data_en_ff1 -> dec_filter_data_en

always_ff @( posedge mclk ) begin : CDC
    cdc1 <= adcDat;
    data_en_ff1 <= cdc_data_en_input;
    
    out_data <= cdc1;    // output
    dec_filter_data_en <= data_en_ff1;
end

endmodule