`define APB_DATA_WIDTH 8
`define SPI_REG_WIDTH  8
`define APB_ADDR_WIDTH 3

module apb_slave_interface (
    input                            PCLK,
    input                            PRESETn,
    input      [`APB_ADDR_WIDTH-1:0] PADDR,
    input                            PWRITE,
    input                            PSEL,
    input                            PENABLE,
    input      [`APB_DATA_WIDTH-1:0] PWDATA,
    input                            ss,
    input      [`APB_DATA_WIDTH-1:0] miso_data,
    input                            receive_data,
    input                            tip,

    output reg [`APB_DATA_WIDTH-1:0] PRDATA,
    output reg                       mstr,
    output reg                       cpol,
    output reg                       cpha,
    output reg                       lsbfe,
    output reg                       spiswai,
    output reg [2:0]                 sppr,
    output reg [2:0]                 spr,
    output reg                       spi_interrupt_request,
    output reg                       PREADY,
    output reg                       PSLVERR,
    output reg                       send_data,
    output reg [`APB_DATA_WIDTH-1:0] mosi_data,
    output reg [1:0]                 spi_mode
);

    // FSM states
    localparam IDLE   = 2'b00;
    localparam SETUP  = 2'b01;
    localparam ENABLE = 2'b10;

    localparam spi_run  = 2'b00;
    localparam spi_wait = 2'b01;
    localparam spi_stop = 2'b10;

    // Register map
    localparam ADDR_CR1 = 3'b000;
    localparam ADDR_CR2 = 3'b001;
    localparam ADDR_BR  = 3'b010;
    localparam ADDR_SR  = 3'b011;
    localparam ADDR_DR  = 3'b100;

    // Masks
    localparam cr2_mask = 8'b00011011;
    localparam br_mask  = 8'b01110111;

    // State registers
    reg [1:0] STATE, next_state;
    reg [1:0] mode, next_mode;

    // SPI Registers
    reg [7:0] SPI_CR_1, SPI_CR_2, SPI_BR, SPI_SR, SPI_DR;

    // Flags
    reg sptef;  // SPI Transmit Empty Flag
    reg spif;   // SPI Interrupt Flag

    // Wires for register control bits
    wire spie   = SPI_CR_2[7];
    wire sptie  = SPI_CR_2[6];
    wire spe    = SPI_CR_1[6];
    wire ssoe   = SPI_CR_2[1];
    wire modfen = SPI_CR_2[0];

    wire wr_enb = (STATE == ENABLE && PWRITE);
    wire rd_enb = (STATE == ENABLE && !PWRITE);

    // FSM: Update APB state
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            STATE <= IDLE;
        else
            STATE <= next_state;
    end

    // FSM: Next APB state logic
    always @(*) begin
        case (STATE)
            IDLE:
                next_state = (PSEL && !PENABLE) ? SETUP : IDLE;
            SETUP:
                next_state = (PSEL && PENABLE) ? ENABLE : SETUP;
            ENABLE:
                next_state = (!PSEL) ? IDLE : ENABLE;
            default:
                next_state = IDLE;
        endcase
    end

    // FSM: SPI mode state
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            mode <= spi_stop;
        else
            mode <= next_mode;
    end

    // FSM: Next SPI mode logic
    always @(*) begin
        case (mode)
            spi_stop:
                next_mode = (spe && !ss) ? spi_run : spi_stop;
            spi_run:
                next_mode = ss ? spi_wait : spi_run;
            spi_wait:
                next_mode = (!ss) ? spi_run : spi_wait;
            default:
                next_mode = spi_stop;
        endcase
    end

    // Register Write Logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            SPI_CR_1 <= 8'b0000_0100;
            SPI_CR_2 <= 8'b0000_0000;
            SPI_BR   <= 8'b0000_0000;
            SPI_DR   <= 8'b0000_0000;
            SPI_SR   <= 8'b0000_0010; // Set SPTEF = 1 (buffer empty)
            mosi_data <= 8'b0;
            send_data <= 1'b0;
            sptef     <= 1'b1;
            spif      <= 1'b0;
        end else begin
            send_data <= 1'b0;

            if (wr_enb) begin
                case (PADDR)
                    ADDR_CR1: SPI_CR_1 <= PWDATA;
                    ADDR_CR2: SPI_CR_2 <= PWDATA & cr2_mask;
                    ADDR_BR:  SPI_BR   <= PWDATA & br_mask;
                    ADDR_DR: begin
                        SPI_DR    <= PWDATA;
                        mosi_data <= PWDATA;
                        send_data <= 1'b1;
                        sptef     <= 1'b0;
                    end
                    default: ;
                endcase
            end

            if (receive_data && (mode == spi_run || mode == spi_wait)) begin
                SPI_DR <= miso_data;
                spif   <= 1'b1;
            end

            if (send_data)
                SPI_SR[1] <= 1'b0; // Clear SPTEF
            else
                SPI_SR[1] <= sptef;

            SPI_SR[7] <= spif; // SPIF
        end
    end

    // Register Read Logic
    always @(*) begin
        PRDATA = 8'h00;
        case (PADDR)
            ADDR_CR1: PRDATA = SPI_CR_1;
            ADDR_CR2: PRDATA = SPI_CR_2;
            ADDR_BR:  PRDATA = SPI_BR;
            ADDR_SR:  PRDATA = SPI_SR;
            ADDR_DR:  PRDATA = SPI_DR;
            default:  PRDATA = 8'h00;
        endcase
    end

    // APB Response Logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PREADY  <= 1'b0;
            PSLVERR <= 1'b0;
        end else begin
            PREADY  <= (STATE == ENABLE);
            PSLVERR <= 1'b0;
        end
    end

    // Control outputs
    always @(*) begin
        mstr       = SPI_CR_1[4];
        cpol       = SPI_CR_1[3];
        cpha       = SPI_CR_1[2];
        lsbfe      = SPI_CR_1[1];
        spiswai    = SPI_CR_1[0];
        sppr       = SPI_BR[7:5];
        spr        = SPI_BR[2:0];
        spi_mode   = mode;
        spi_interrupt_request = spif && spie;
    end

endmodule

