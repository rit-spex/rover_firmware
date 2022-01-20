module AMC1303Mx #(
    parameter SYSCLK_FREQ = 100_000_000
) (
    
);

dec256sinc24b #(
    .SYSCLK_FREQ(SYSCLK_FREQ)
) decimator (
    .
);

always_ff @( sysclk ) begin : CDC
    cdc1 <= adcDat
    outData <= cdc1
end
    
endmodule