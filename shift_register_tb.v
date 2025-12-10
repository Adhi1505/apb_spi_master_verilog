`timescale 1ns / 1ps

module shift_register_tb;

    // Inputs
    reg PCLK;
    reg PRESETn;
    reg ss;
    reg send_data;
    reg lsbfe;
    reg cpha;
    reg cpol;
    reg flag_low;
    reg flag_high;
    reg flags_low;
    reg flags_high;
    reg [7:0] data_mosi;
    reg miso;
    reg receive_data;

    // Outputs
    wire mosi;
    wire [7:0] data_miso;

    // Instantiate the Unit Under Test (UUT)
    shift_register uut (
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
        .data_mosi(data_mosi),
        .miso(miso),
        .receive_data(receive_data),
        .mosi(mosi),
        .data_miso(data_miso)
    );

    // Clock generation
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK; // 10ns period
    end

    // Main stimulus
    initial begin
        // Initialize inputs
        PRESETn = 0;
        ss = 1;
        send_data = 0;
        lsbfe = 0;
        cpha = 0;
        cpol = 0;
        flag_low = 0;
        flag_high = 0;
        flags_low = 0;
        flags_high = 0;
        data_mosi = 8'b10101010;
        miso = 0;
        receive_data = 0;

        // Apply reset
        #10 PRESETn = 1;

        // Activate slave
        #10 ss = 0;

        // Load data to send (MSB first)
        #10 send_data = 1;
        #10 send_data = 0;

        // Simulate shifting of 8 bits
        repeat (8) begin
            #5  flag_low = 1; flags_low = 1; // Falling edge
            #5  flag_low = 0; flags_low = 0;
            
            miso = $random % 2; // Provide a random bit on MISO

            #5  flag_high = 1; flags_high = 1; // Rising edge
            #5  flag_high = 0; flags_high = 0;
        end

        // Trigger receive capture
        #10 receive_data = 1;
        #10 receive_data = 0;

        // Wait and observe
        #50 $finish;
    end

endmodule

