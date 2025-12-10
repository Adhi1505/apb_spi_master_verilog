`timescale 1ns / 1ps

module spi_slave_control_select_tb;

  // Inputs
  reg PCLK;
  reg PRESETn;
  reg mstr;
  reg spiswai;
  reg [1:0] spi_mode;
  reg send_data;
  reg [11:0] BaudRateDivisor;

  // Outputs
  wire receive_data;
  wire ss;
  wire tip;

  // Instantiate the Unit Under Test (UUT)
  spi_slave_control_select DUT (
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

  // Clock generation
  always #5 PCLK = ~PCLK;

  initial begin
    // Initialize inputs
    PCLK = 0;
    PRESETn = 0;
    mstr = 0;
    spiswai = 0;
    spi_mode = 2'b00;
    send_data = 0;
    BaudRateDivisor = 12'd8;

    #10;
    PRESETn = 1;

    // Master mode enabled
    #10 mstr = 1;

    // Send signal trigger
    #10 send_data = 1;

    // Simulate sending for a while
    #40 send_data = 0;

    // Add SPI wait mode
    #20 spiswai = 1;

    #20 spiswai = 0;

    // Test other modes
    #10 spi_mode = 2'b11;

    #50 $finish;
  end

endmodule

