/**********************************************************
 * File Name   : uart_interface.v
 * Description : TODO
 * Author      : T. Graba (Telecom ParisTECH)
 * Licence     : This code is distributed 'as is' without
 *               any warranty.You are free to use it and
 *               redistribute it under what ever condition
 *               you want.
 *********************************************************/

module uart_interface #(
    parameter          UART_CLK_FREQ = 64*115200,
    parameter          UART_BAUD     = 115_200
) (
    // System Signals
    input  wire    n_reset,
    input  wire    clk,
    // UART signals
    input  wire    uart_rxd,
    output wire    uart_txd,
    // System Interface
    input  wire [7:0] rdata,
    output reg  [7:0] wdata,
    output reg  [6:0] addr ,
    output reg       write,
    output reg       read_ack
);

// uart signals
    wire [7:0]   rx_data;
    wire         rx_avail;
    wire         rx_error;
    wire         rx_ack;
    reg  [7:0]   tx_data;
    reg          tx_wr;
    wire         tx_busy;

// uart instance
// TODO: Maybe smoehow use the error flag
uart #( .freq_hz (UART_CLK_FREQ), .baud (UART_BAUD) ) 
i_uart (
    .n_reset  ( n_reset  ), 
    .clk      ( clk      ),
    .uart_rxd ( uart_rxd ),
    .uart_txd ( uart_txd ),
    .rx_data  ( rx_data  ),
    .rx_avail ( rx_avail ),
    .rx_error ( rx_error ),
    .rx_ack   ( rx_ack   ),
    .tx_data  ( tx_data  ),
    .tx_wr    ( tx_wr    ),
    .tx_busy  ( tx_busy  )
);

// always ack when the uart receives a byte
// TODO: what we do in case of reception error
assign rx_ack = rx_avail;


reg [1:0] uckd_state;
localparam  IDLE         = 3'd0,
            L_RD_DATA    = 3'd1,
            T_RD_DATA    = 3'd2,
            W_WRITE_DATA = 3'd3;


// The value of rx_data[7] determines the command
//              1 : read
//              0 : write
localparam  READ_CMD  = 1'b1;
localparam  WRITE_CMD = 1'b0;
reg         uckd_cmd;


always @ (posedge clk or negedge n_reset)
    if (!n_reset)
    begin
        // Reset everything systematically
        uckd_state <= IDLE;
        addr       <= 7'd0;
        wdata      <= 8'd0;
        write      <= 0;
        read_ack   <= 0;
        tx_data    <= 8'd0;
        tx_wr      <= 0;
    end
    else
    begin
        // interface signals
        write       <= 0;
        read_ack    <= 0;
        // uart signals
        tx_wr       <= 0;
        case (uckd_state)
            IDLE: begin
                // Wait for a command
                if (rx_avail)
                begin
                   // latch the address
                    addr      <= rx_data[6:0];
                    uckd_cmd   = rx_data[7];
                    if (uckd_cmd == READ_CMD)
                    begin
                        // The read data will be send through the uart
                        uckd_state <= L_RD_DATA;
                    end
                    else
                        uckd_state <= W_WRITE_DATA;
                end
            end
            W_WRITE_DATA: begin
                // Wait for the data to write
                if (rx_avail)
                begin
                    // NOTE: rx_data is already a register 
                    // wdata will not change until next byte reception
                    wdata      <= rx_data;
                    uckd_state <= IDLE;
                    // generate a write pulse to the internal logic
                    write      <= 1;
                end
            end
            L_RD_DATA: begin
               // Read the data from the internal logic and send back an ack
               read_ack   <= 1;
               tx_data    <= rdata;
               uckd_state <= T_RD_DATA;
            end
            T_RD_DATA: begin
               // Wait as long as the uart is busy
               if (!tx_busy)
               begin
                  // send the read data through the uart
                  tx_wr <= 1;
                  uckd_state <= IDLE ;
               end
            end
            default: uckd_state <= IDLE ;
        endcase
    end

endmodule
