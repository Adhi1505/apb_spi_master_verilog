module spi_slave_control_select (
    input         PCLK,
    input         PRESETn,
    input         mstr,
    input         spiswai,
    input  [1:0]  spi_mode,
    input         send_data,
    input  [11:0] BaudRateDivisor,
    output reg    ss,
    output        tip,
    output reg    receive_data
);

    reg [15:0] count;
    wire [15:0] target;
    reg rcv;

    assign target = BaudRateDivisor * 5'd16;  // 16 SPI clocks = 1 frame
    assign tip = ~ss;                         // Transmission in progress when ss is LOW

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            ss           <= 1'b1;  // Inactive high
            count        <= 16'hFFFF;
            rcv          <= 1'b0;
            receive_data <= 1'b0;
        end
        else if (mstr && (spi_mode == 2'b00 || (spi_mode == 2'b01 && ~spiswai))) begin
            if (send_data && ss) begin
                ss    <= 1'b0;     // Assert SS (start transaction)
                count <= 16'd0;
                rcv   <= 1'b0;
            end
            else if (!ss) begin
                if (count < target) begin
                    count <= count + 1'b1;
                end
                else begin
                    ss           <= 1'b1;  // Deassert SS after transmission
                    receive_data <= 1'b1;  // Signal that data is ready to receive
                    rcv          <= 1'b1;
                end
            end
            else begin
                receive_data <= 1'b0; // Clear receive signal
            end
        end
        else begin
            ss           <= 1'b1;     // Default inactive
            count        <= 16'hFFFF;
            rcv          <= 1'b0;
            receive_data <= 1'b0;
        end
    end

endmodule

