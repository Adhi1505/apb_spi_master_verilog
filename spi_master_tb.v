`timescale 1ns / 1ps
`define APB_ADDR_WIDTH 3
`define APB_DATA_WIDTH 8

module spi_master_tb;
    // Clock and Reset
    reg PCLK;
    reg PRESETn;
    
    // APB Interface
    reg [`APB_ADDR_WIDTH-1:0] PADDR;
    reg [`APB_DATA_WIDTH-1:0] PWDATA;
    reg PWRITE, PSEL, PENABLE;
    wire [`APB_DATA_WIDTH-1:0] PRDATA;
    wire PREADY, PSLVERR;
    
    // SPI Interface
    reg ss;
    reg [`APB_DATA_WIDTH-1:0] miso_data;
    reg receive_data;
    reg tip;
    wire mstr, cpol, cpha, lsbfe, spiswai;
    wire [2:0] sppr, spr;
    wire send_data;
    wire [`APB_DATA_WIDTH-1:0] mosi_data;
    wire [1:0] spi_mode;
    wire spi_interrupt_request;
    
    // DUT instantiation
    apb_slave_interface uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .ss(ss),
        .miso_data(miso_data),
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
    
    // Clock generation
    always #5 PCLK = ~PCLK;
    
    // Task to perform APB Write
    task automatic apb_write(input [2:0] addr, input [7:0] data);
    begin
        @(posedge PCLK);
        PADDR = addr;
        PWDATA = data;
        PWRITE = 1;
        PSEL = 1;
        PENABLE = 0;
        @(posedge PCLK);
        PENABLE = 1;
        @(posedge PCLK);
        PSEL = 0;
        PENABLE = 0;
    end
    endtask
    
    // Task to perform APB Read
    task automatic apb_read(input [2:0] addr);
    begin
        @(posedge PCLK);
        PADDR = addr;
        PWRITE = 0;
        PSEL = 1;
        PENABLE = 0;
        @(posedge PCLK);
        PENABLE = 1;
        @(posedge PCLK);
        PSEL = 0;
        PENABLE = 0;
    end
    endtask
    
    initial begin
        // Initialization
        PCLK = 0;
        PRESETn = 0;
        PWRITE = 0;
        PSEL = 0;
        PENABLE = 0;
        ss = 0;
        miso_data = 8'h00;
        receive_data = 0;
        tip = 0;
        
        // Reset sequence
        #20;
        PRESETn = 1;
        
        $display("Starting SPI Master Test Sequence");
        
        // Test Sequence 1: Cphase 1, Cpol0, lsbfe 1
        $display("Test 1: Cphase 1, Cpol0, lsbfe 1");
        apb_write(3'b000, 8'b11111_010);     // Control Register: b11111_010
        apb_write(3'b001, 8'b11100_000);     // Baud Rate: b11100_000
        apb_write(3'b010, 8'b10000_000);     // Data Register: b10000_000
        apb_write(3'b011, 8'b10101_010);     // MISO data high lsbfe: b10101_010
        #100;
        
        // Test Sequence 2: Cphase 1, Cpol0, lsbfe 1
        $display("Test 2: Cphase 1, Cpol0, lsbfe 1");
        apb_write(3'b000, 8'b11111_010);     // Control Register: b11111_010
        apb_write(3'b001, 8'b11100_000);     // Baud Rate: b11100_000
        apb_write(3'b010, 8'b10000_000);     // Data Register: b10000_000
        apb_write(3'b011, 8'b10101_010);     // MISO data high lsbfe: b10101_010
        #100;
        
        // Test Sequence 3: Cphase 1, Cpol0, lsbfe 1
        $display("Test 3: Cphase 1, Cpol0, lsbfe 1");
        apb_write(3'b000, 8'b11111_010);     // Control Register: b11111_010
        apb_write(3'b001, 8'b11100_000);     // Baud Rate: b11100_000
        apb_write(3'b010, 8'b10000_000);     // Data Register: b10000_000
        apb_write(3'b011, 8'b10101_010);     // MISO data high lsbfe: b10101_010
        #100;
        
        // Test Sequence 4: Cphase 1, Cpol1, lsbfe 0
        $display("Test 4: Cphase 1, Cpol1, lsbfe 0");
        apb_write(3'b000, 8'b10101_110);     // Control Register: b10101_110
        apb_write(3'b001, 8'b11100_000);     // Baud Rate: b11100_000
        apb_write(3'b010, 8'b10000_000);     // Data Register: b10000_000
        apb_write(3'b011, 8'b11111_101);     // MISO data low lsbfe0: b11111_101
        #40;
        
        // Test Sequence 5: Another test for different configuration
        $display("Test 5: Additional configuration test");
        apb_write(3'b000, 8'b10101_110);     // Control Register: b10101_110
        apb_write(3'b001, 8'b11100_000);     // Baud Rate: b11100_000
        apb_write(3'b010, 8'b11000_010);     // Data Register: b11000_010
        apb_write(3'b011, 8'b11111_101);     // MISO data low lsbfe0: b11111_101
        #40;
        
        // Test Sequence 6: Final test configuration
        $display("Test 6: Final configuration test");
        apb_write(3'b000, 8'b10101_110);     // Control Register: b10101_110
        apb_write(3'b001, 8'b11100_000);     // Baud Rate: b11100_000
        apb_write(3'b010, 8'b11000_010);     // Data Register: b11000_010
        apb_write(3'b011, 8'b11111_101);     // MISO data low lsbfe0: b11111_101
        #100;
        
        $display("All test sequences completed");
        $finish;
    end
    
    // Monitor signals for debugging
    initial begin
        $monitor("Time=%0t, PADDR=%b, PWDATA=%b, PWRITE=%b, PSEL=%b, PENABLE=%b, PRDATA=%b", 
                 $time, PADDR, PWDATA, PWRITE, PSEL, PENABLE, PRDATA);
    end
    
endmodule
