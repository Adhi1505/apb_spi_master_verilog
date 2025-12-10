`timescale 1ns / 1ps

module baud_rate_generator_tb;

    reg        PCLK, PRESETn;
    reg [1:0]  spi_mode;
    reg        spiswai;
    reg [2:0]  sppr, spr;
    reg        cpol, cpha, ss;

    wire       sclk, flag_low, flag_high, flags_low, flags_high;
    wire [7:0] BaudRateDivisor;

    baud_rate_generator uut (
        .PCLK(PCLK), .PRESETn(PRESETn),
        .spi_mode(spi_mode), .spiswai(spiswai),
        .sppr(sppr), .spr(spr),
        .cpol(cpol), .cpha(cpha), .ss(ss),
        .sclk(sclk), .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .BaudRateDivisor(BaudRateDivisor)
    );

    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    initial begin
        PRESETn = 0; ss = 1;
        spi_mode = 2'b00; spiswai = 0;
        sppr = 3'd1; spr = 3'd2; // Example: divisor = (1+1)*2^(2+1) = 2*8 = 16
        cpol = 0; cpha = 0;

        #20 PRESETn = 1;
        #20 ss = 0;

        #200 $finish;
    end

endmodule

