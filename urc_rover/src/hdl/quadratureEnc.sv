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
    parameter COUNTS_PER_REV = 8192,
    parameter COUNT_SIZE = 11
) (
    input sclk,
    input rstn,

    input enc_a,
    input enc_b,
    input enc_i,

    input home,

    output logic [COUNT_SIZE-1:0] count
);
    logic [2:0] a_delayed, b_delayed;

    //synchro
    always_ff @(posedge sclk ) begin : synchro
        if (!rstn) begin
            a_delayed <= 0;
            b_delayed <= 0;
        end else begin
            a_delayed <= {a_delayed[1:0], enc_a};
            b_delayed <= {b_delayed[1:0], enc_b};
        end
    end

    //quad decoding, direction finding
    wire countEnable = a_delayed[1] ^ a_delayed[2] ^ b_delayed[1] ^ b_delayed[2];
    wire countDir = a_delayed[1] ^ b_delayed[2];

    //counter
    always_ff @(posedge sclk ) begin : counter
        if (!rstn) begin
            count <= 0;
        end else if (home) begin
            count <= 0;
        end else begin
            if (countEnable) begin
                if (countDir) begin
                    if (count == (COUNTS_PER_REV)) begin
                        count <= 0;
                    end else begin
                    count <= count + 1;
                    end
                end else begin
                    if (count == 0) begin
                        count <= COUNTS_PER_REV;
                    end else begin
                    count <= count - 1;
                    end
                end
            end
        end
    end
endmodule