module baud_rate_generator (
    input        PCLK,
    input        PRESETn,
    input  [1:0] spi_mode,
    input        spiswai,
    input  [2:0] sppr,
    input  [2:0] spr,
    input        cpol,
    input        cpha,
    input        ss,

    output reg   sclk,
    output reg   flag_low,
    output reg   flag_high,
    output       flags_low,  // Optional: assign if needed
    output       flags_high, // Optional: assign if needed
    output [11:0] BaudRateDivisor
);

    reg [11:0] count;
    wire pre_sclk;
    wire [11:0] baud_div;

    assign baud_div = (sppr + 1) * (1 << (spr + 1));
    assign BaudRateDivisor = baud_div;
    assign pre_sclk = cpol ? 1'b1 : 1'b0;

    assign flags_low  = flag_low;
    assign flags_high = flag_high;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            count <= 12'b0;
            sclk  <= pre_sclk;
        end 
        else if ((!ss) && (spi_mode == 2'b00 || (spi_mode == 2'b01 && !spiswai))) begin
            if (count == (baud_div - 1'b1)) begin
                sclk  <= ~sclk;
                count <= 12'b0;
            end else begin
                count <= count + 1'b1;
            end
        end else begin
            sclk  <= pre_sclk;
            count <= 12'b0;
        end
    end

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            flag_low  <= 1'b0;
            flag_high <= 1'b0;
        end else begin
            if ((!cpha && cpol) || (cpha && !cpol)) begin
                if (sclk) begin
                    flag_high <= (count == (baud_div - 1'b1)) ? 1'b1 : 1'b0;
                end else begin
                    flag_high <= 1'b0;
                end
            end else begin
                if (!sclk) begin
                    flag_low <= (count == (baud_div - 1'b1)) ? 1'b1 : 1'b0;
                end else begin
                    flag_low <= 1'b0;
                end
            end
        end
    end

endmodule

