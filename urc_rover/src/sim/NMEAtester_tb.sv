interface GPSdata;
        logic [ 9:0] [7:0] timestamp;
        logic [ 9:0] [7:0] latitude ;
        logic [10:0] [7:0] longitude;
        logic        [7:0] quality  ;
        logic        [7:0] numSats  ;
        logic [ 3:0] [7:0] hdop     ;
        logic [ 3:0] [7:0] altMSL   ;
        logic [ 3:0] [7:0] geoid    ;
endinterface:GPSdata

module MMEAtester_tb;

timeunit 1ns;
timeprecision 1ps;

wire GPSuart;
wire NMEAready;
wire txdbusy;
wire txdstart;
wire gpsReady;
wire [7:0] NMEAbyte;

logic [7:0] NMEAin = 0;
logic clock = 0;
logic resetn = 0;

GPSdata GPSparsed;

//$GPGGA,111111.111,2222.2222,N,33333.3333,W,2,4,5.55,66.6,M,11.1,M,2.2,*hh<CR><LF> where hh is calculated checksum
logic [7:0] checksum = 8'h47^8'h50^8'h47^8'h47^8'h41^8'h2C^8'h31^8'h31^8'h31^8'h31^8'h31^8'h31^8'h2E^8'h31^8'h31^8'h31^8'h2C^8'h32^8'h32^8'h32^8'h32^8'h2E^8'h32^8'h32^8'h32^8'h32^8'h2C^8'h4E^8'h2C^8'h33^8'h33^8'h33^8'h33^8'h33^8'h2E^8'h33^8'h33^8'h33^8'h33^8'h2C^8'h57^8'h2C^8'h32^8'h2C^8'h34^8'h2C^8'h35^8'h2E^8'h35^8'h35^8'h2C^8'h36^8'h36^8'h2E^8'h36^8'h2C^8'h4D^8'h2C^8'h31^8'h31^8'h2E^8'h31^8'h2C^8'h4D^8'h2C^8'h32^8'h2E^8'h32^8'h2C^8'h2A;
logic [599:0] data = {568'h2447504747412C3131313131312E3131312C323232322E323232322C4E2C33333333332E333333332C572C322C342C352E35352C36362E362C4D2C31312E312C4D2C322E322C2A, checksum, 16'h0D0A};

GPS #(
    .SYSCLK_FREQ(100_000_000)
) DUT (
    .sclk(clock),
    .rstn(resetn),
    .dataByte(NMEAbyte),
    .dataReady(NMEAready),
    .gpsResults(GPSresults),
    .gpsReady(gpsReady)
);

async_transmitter #(
    .ClkFrequency(100_000_000),
    .Baud(9600)
) GPSrx (
    .clk(clock),
    .rst(resetn),
    .TxD(GPSuart),
    .TxD_data(NMEAin),
    .TxD_start(txdstart),
    .TxD_busy(txdbusy)
);

initial begin
    forever begin
        #500
        clock <= ~clock;
    end
end

initial begin
    #10_000
    resetn <= 1;
end

always begin
    
end


endmodule