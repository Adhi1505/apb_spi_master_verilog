`timescale 1ns / 1ps

module apb_slave_interface_tb;

    reg        PCLK, PRESETn, PWRITE, PSEL, PENABLE;
    reg [2:0]  PADDR;
    reg [7:0]  PWDATA;
    reg        ss, receive_data, tip;
    reg [7:0]  miso_data;

    wire [7:0] PRDATA;
    wire       mstr, cpol, cpha, lsbfe, spiswai;
    wire [2:0] sppr, spr;
    wire       spi_interrupt_request, PREADY, PSLVERR, send_data;
    wire [7:0] mosi_data;
    wire [1:0] spi_mode;

    apb_slave_interface uut (
        .PCLK(PCLK), .PRESETn(PRESETn), .PADDR(PADDR),
        .PWRITE(PWRITE), .PSEL(PSEL), .PENABLE(PENABLE),
        .PWDATA(PWDATA), .ss(ss), .miso_data(miso_data),
        .receive_data(receive_data), .tip(tip),

        .PRDATA(PRDATA), .mstr(mstr), .cpol(cpol),
        .cpha(cpha), .lsbfe(lsbfe), .spiswai(spiswai),
        .sppr(sppr), .spr(spr), .spi_interrupt_request(spi_interrupt_request),
        .PREADY(PREADY), .PSLVERR(PSLVERR),
        .send_data(send_data), .mosi_data(mosi_data), .spi_mode(spi_mode)
    );

    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    initial begin
        PRESETn = 0;
        PADDR = 0; PWRITE = 1; PSEL = 0; PENABLE = 0;
        PWDATA = 8'hA5; ss = 0; miso_data = 8'h3C;
        receive_data = 1; tip = 0;

        #20 PRESETn = 1;
        #10 PSEL = 1; PADDR = 4; PWDATA = 8'hAA; PWRITE = 1; PENABLE = 1; // Write TX
        #20 PENABLE = 0; PSEL = 0;

        #20 PADDR = 5; PWRITE = 0; PSEL = 1; PENABLE = 1; // Read RX
        #20 PENABLE = 0;

        #100 $finish;
    end

endmodule

