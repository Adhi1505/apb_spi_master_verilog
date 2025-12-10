`define APB_DATA_WIDTH 8
`define SPI_REG_WIDTH  8
`define APB_ADDR_WIDTH 3
module spi_master_top (
    input         PCLK,
    input         PRESETn,
    input  [`APB_ADDR_WIDTH -1 :0]  PADDR,
    input         PWRITE,
    input         PSEL,
    input         PENABLE,
    input  [`APB_DATA_WIDTH-1:0]  PWDATA,
    input         miso,

    output        ss,
    output        sclk,
    output        spi_interrupt_request,
    output        mosi,
    output [`APB_DATA_WIDTH-1:0]  PRDATA,
    output        PREADY,
    output        PSLVERR
);

    // Wires to interconnect internal blocks
    wire        mstr, spiswai, cpol, cpha, lsbfe;
    wire [2:0]  sppr, spr;
    wire [`APB_DATA_WIDTH-1:0]  mosi_data, data_miso;
    wire [1:0]  spi_mode;
    wire        send_data, receive_data, tip;

    wire        flag_low, flag_high;
    wire        flags_low, flags_high;
    wire [11:0]  BaudRateDivisor;

    // ===================== APB Slave Interface =====================
    apb_slave_interface u_apb_slave (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .ss(ss),
        .miso_data(data_miso),
        .receive_data(receive_data),
        .tip(tip),
        .PRDATA(PRDATA),
        .mstr(mstr),
        .cpol(cpol),
        .cpha(cpha),
        .lsbfe(lsbfe),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .spi_interrupt_request(spi_interrupt_request),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .send_data(send_data),
        .mosi_data(mosi_data),
        .spi_mode(spi_mode)
    );

    // ===================== Baud Rate Generator =====================
    baud_rate_generator u_baud_gen (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .spi_mode(spi_mode),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .cpol(cpol),
        .cpha(cpha),
        .ss(ss),
        .sclk(sclk),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .BaudRateDivisor(BaudRateDivisor)
    );

    // ===================== SPI Slave Control Select =====================
    spi_slave_control_select u_slave_control (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .mstr(mstr),
        .spiswai(spiswai),
        .spi_mode(spi_mode),
        .send_data(send_data),
        .BaudRateDivisor(BaudRateDivisor),
        .receive_data(receive_data),
        .ss(ss),
        .tip(tip)
    );

    // ===================== Shift Register =====================
    shift_register u_shift_reg (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .ss(ss),
        .send_data(send_data),
        .lsbfe(lsbfe),
        .cpha(cpha),
        .cpol(cpol),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .data_mosi(mosi_data),
        .miso(miso),
        .receive_data(receive_data),
        .mosi(mosi),
        .data_miso(data_miso)
    );

endmodule

