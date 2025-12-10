module shift_register (
    input         PCLK,
    input         PRESETn,
    input         ss,
    input         send_data,
    input         lsbfe,
    input         cpha,
    input         cpol,
    input         flag_low,
    input         flag_high,
    input         flags_low,
    input         flags_high,
    input  [7:0]  data_mosi,
    input         miso,
    input         receive_data,

    output reg    mosi,
    output reg [7:0] data_miso
);

    reg [7:0] shift_reg;
    reg [2:0] bit_cnt;

    wire is_lsb_first = lsbfe;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            shift_reg <= 8'd0;
            bit_cnt   <= 3'd0;
            mosi      <= 1'b0;
            data_miso <= 8'd0;
        end
        else begin
            // Load MOSI data when transmission starts
            if (send_data) begin
                shift_reg <= data_mosi;
                bit_cnt   <= 3'd7;
                mosi      <= is_lsb_first ? data_mosi[0] : data_mosi[7];
            end

            // Shifting on appropriate clock edges
            if (!ss && (flags_low || flags_high)) begin
                // Shift out
                if (flags_low) begin  // Assuming shift on falling edge
                    mosi <= is_lsb_first ? shift_reg[1] : shift_reg[6];
                end

                // Shift in
                if (flags_high) begin  // Sample MISO on rising edge
                    if (is_lsb_first) begin
                        shift_reg <= {miso, shift_reg[7:1]};  // LSB first
                    end else begin
                        shift_reg <= {shift_reg[6:0], miso};  // MSB first
                    end

                    if (bit_cnt > 0)
                        bit_cnt <= bit_cnt - 1;
                end
            end

            // Capture received data
            if (receive_data) begin
                data_miso <= shift_reg;
            end
        end
    end
endmodule

