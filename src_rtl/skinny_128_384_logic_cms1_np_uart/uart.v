 /*********************************************************
 * File Name   : uart.v
 * Description : simple asynchronous receiver transmitter
 *               configurable baud rate:
 *                  - The baud rate and the clock frequency
 *                  are module parameter. The division ratio
 *                  is computed internally.
 *               fix word format:
 *                  - 8N1  (8bits - no parity - on stop bit)
 *                          LSb first
 * Operation:
 *          Read:
 *           when a valid packet is received, rx_avail is
 *           set and the data is available on rx_data.
 *           rx_data is not modified until a new valid data
 *           is received.
 *           if the packet format is not correct, rx_error 
 *           is set.
 *           The two flags are reseted by setting rx_ack
 *          Write:
 *           An 8 bits data to be written is presented on
 *           the input port tx_data
 *           setting tx_wr will copy tx_data into the
 *           internal buffer and start the transmission.
 *           During the transmission tx_busy is set.
 *           Setting tx_wr as long as tx_busy is high will
 *           have no effects.
 **********************************************************/

module uart #(
    parameter           freq_hz = 64*115200,
    parameter           baud    = 115_200
) (
    input wire          n_reset,
    input wire          clk,
    // UART lines
    input wire          uart_rxd,
    output reg          uart_txd,
    // 
    output reg  [7:0]   rx_data,
    output reg          rx_avail,
    output reg          rx_error,
    input  wire         rx_ack,
    input  wire [7:0]   tx_data,
    input  wire         tx_wr,
    output reg          tx_busy
);

localparam divisor = freq_hz/baud/16;

//-----------------------------------------------------------------
// enable16 generator
//-----------------------------------------------------------------
reg [15:0] enable16_counter;

wire    enable16;
assign  enable16 = (enable16_counter == 0);

always @(posedge clk or negedge n_reset)
begin
    if (!n_reset) begin
        enable16_counter <= divisor - 1;
    end else begin
        enable16_counter <= enable16_counter - 1;
        if (enable16_counter == 0) begin
            enable16_counter <= divisor-1;
        end
    end
end

//-----------------------------------------------------------------
// syncronize uart_rxd
//-----------------------------------------------------------------
reg r0_uart_rxd;
reg r_uart_rxd;

always @(posedge clk)
begin
    r0_uart_rxd <= uart_rxd;
    r_uart_rxd  <= r0_uart_rxd;
end

//-----------------------------------------------------------------
// UART RX Logic
//-----------------------------------------------------------------
reg       rx_busy;
reg [3:0] rx_count16;
reg [3:0] rx_bitcount;
reg [7:0] rxd_reg;

always @ (posedge clk or negedge n_reset)
begin
    if (!n_reset) begin
        rx_busy     <= 0;
        rx_count16  <= 0;
        rx_bitcount <= 0;
        rx_avail    <= 0;
        rx_error    <= 0;
        rx_data     <= 0;
        rxd_reg <= 0;
    end else begin 
        if (rx_ack) begin
            rx_avail <= 0;
            rx_error <= 0;
        end

        if (enable16) begin
            if (!rx_busy) begin           // look for start bit
                if (!r_uart_rxd) begin     //     start bit found
                    rx_busy     <= 1;
                    rx_count16  <= 7;
                    rx_bitcount <= 0;
                end
            end else begin
                rx_count16 <= rx_count16 + 1;

                if (rx_count16 == 0) begin      // sample 
                    rx_bitcount <= rx_bitcount + 1;

                    if (rx_bitcount == 0) begin          // verify startbit
                        if (r_uart_rxd) begin
                            rx_busy <= 0;
                        end
                    end else if (rx_bitcount == 9) begin // look for stop bit
                        rx_busy <= 0;
                        if (r_uart_rxd) begin             //   stop bit ok
                            rx_data  <= rxd_reg;
                            rx_avail <= 1;
                            rx_error <= 0;
                        end else begin                  //   bas stop bit
                            rx_error <= 1;
                        end
                    end else begin
                        rxd_reg <= { r_uart_rxd, rxd_reg[7:1] };
                    end
                end
            end 
        end
    end
end

//-----------------------------------------------------------------
// UART TX Logic
//-----------------------------------------------------------------
reg [3:0] tx_bitcount;
reg [3:0] tx_count16;
reg [7:0] txd_reg;

always @ (posedge clk or negedge n_reset)
begin
    if (!n_reset) begin
        tx_busy     <= 0;
        uart_txd    <= 1;
        txd_reg     <= 0;
        tx_count16  <= 0;
        tx_bitcount <= 0;
    end 
    else begin
        if (tx_wr && !tx_busy) begin
            txd_reg     <= tx_data;
            tx_bitcount <= 0;
            tx_count16  <= 1;
            tx_busy     <= 1;
            uart_txd    <= 0;
        end 
        else 
            if (enable16 && tx_busy) begin
                tx_count16  <= tx_count16 + 1;

                if (tx_count16 == 0) begin
                    tx_bitcount <= tx_bitcount + 1;
                    if (tx_bitcount == 8)
                        uart_txd <= 'b1; 
                    else 
                        if (tx_bitcount == 9) begin
                            uart_txd <= 'b1;
                            tx_busy  <= 0;
                        end 
                        else begin
                            uart_txd <= txd_reg[0];
                            txd_reg  <= { 1'b0, txd_reg[7:1] };
                        end
                end
            end
    end
end


endmodule
