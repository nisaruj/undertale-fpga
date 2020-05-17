module uart_fifo (/*AUTOARG*/
   // Outputs
   rx_byte, tx, irq, busy, tx_fifo_full, rx_fifo_empty,
   // Inputs
   tx_byte, clk, rst, rx, transmit, rx_fifo_pop
   ) ;

   //---------------------------------------------------------------------------
   //
   // PARAMETERS
   //
   //---------------------------------------------------------------------------

   //---------------------------------------------------------------------------
   //
   // PORTS
   //
   //---------------------------------------------------------------------------

   input [7:0] tx_byte;           // The byte to send to PC.  Loaded into FIFO first
   input       clk;               // 50MHz free running clock
   input       rst;               // Synchronous active high reset logic
   input       rx;                // Serial RX signal from PC
   input       transmit;          // Signal to send a byte to the PC
   input       rx_fifo_pop;       // Pop the value out of RX FIFO

   output [7:0] rx_byte;          // First byte in FIFO that we have received
   output       tx;               // Signal from FPGA to PC for serial transmission
   output       irq;              // Receive or error or RX Full interrupt
   output       busy;             // actively receiving or transmitting when this is high
   output       tx_fifo_full;     // The TX FIFO is full when asserted no more data can be transmitted.
   output       rx_fifo_empty;    // Asserted when the RX FIFO is not holding data

   //---------------------------------------------------------------------------
   //
   // Registers
   //
   //---------------------------------------------------------------------------
   /*AUTOREG*/
   reg          tx_fifo_pop;      // If there is byte to send and not sending pop a value from TX FIFO

   //---------------------------------------------------------------------------
   //
   // WIRES
   //
   //---------------------------------------------------------------------------
   /*AUTOWIRE*/

   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 is_receiving;           // From uart_inst of uart.v
   wire                 is_transmitting;        // From uart_inst of uart.v
   wire                 received;               // From uart_inst of uart.v
   wire                 recv_error;             // From uart_inst of uart.v
   // End of automatics


   wire                 rx_fifo_full;           // Asserted when RX FIFO is full
   wire [7:0]           rx_fifo_data_in;        // Byte from UART to RX FIFO
   wire                 rx_fifo_pop;            // Pop a value from the RX FIFO
   wire                 rx_fifo_empty;          // Asserted when the RX FIFO is empty

   wire [7:0]           tx_fifo_data_out;       // Byte from TX FIFO to UART
   wire                 tx_fifo_full;           // Asserted when the TX FIFO is FULL
   wire                 tx_fifo_empty;          // Asserted when the TX FIFO is EMPTY


   //---------------------------------------------------------------------------
   //
   // COMBINATIONAL LOGIC
   //
   //---------------------------------------------------------------------------

   //
   // Assert an interrupt if we have received a byte, an error of if the rx_fifo
   // is full.  All of these are reasons for reading this UART
   //
   assign irq = received || recv_error || rx_fifo_full;

   //
   // If we are actively receiving or transmitting, we are "busy"
   //
   assign busy = is_receiving || is_transmitting;

   //---------------------------------------------------------------------------
   //
   // SEQUENTIAL LOGIC
   //
   //---------------------------------------------------------------------------

   //
   // UART Instance.  Handles the actual sending/receiving of serial data
   //
   uart uart_inst(
                  // Outputs
                  .tx                   (tx),
                  .received             (received),
                  .rx_byte              (rx_fifo_data_in),
                  .is_receiving         (is_receiving),
                  .is_transmitting      (is_transmitting),
                  .recv_error           (recv_error),
                  // Inputs
                  .clk                  (clk),
                  .rst                  (rst),
                  .rx                   (rx),
                  .transmit             (tx_fifo_pop),
                  .tx_byte              (tx_fifo_data_out));


   //
   // RX FIFO takes data recevied by the UART and holds until outside module
   // requests data
   //
   fifo #(.DATA_WIDTH(8))
   rx_fifo(
           // Outputs
           .DATA_OUT               (rx_byte),
           .FULL                   (rx_fifo_full),
           .EMPTY                  (rx_fifo_empty),
           // Inputs
           .CLK                    (clk),
           .RESET                  (rst),
           .ENABLE                 (1'b1),
           .FLUSH                  (1'b0),
           .DATA_IN                (rx_fifo_data_in),
           .PUSH                   (received),
           .POP                    (rx_fifo_pop));


   //
   // TX FIFO takes data from outside module and holds it until the
   // UART is able to transmit it
   //
   fifo #(.DATA_WIDTH(8))
   tx_fifo(
           // Outputs
           .DATA_OUT               (tx_fifo_data_out),
           .FULL                   (tx_fifo_full),
           .EMPTY                  (tx_fifo_empty),
           // Inputs
           .CLK                    (clk),
           .RESET                  (rst),
           .ENABLE                 (1'b1),
           .FLUSH                  (1'b0),
           .DATA_IN                (tx_byte),
           .PUSH                   (transmit),
           .POP                    (tx_fifo_pop));

   //
   // POP from TX FIFO is it is NOT empty and we are NOT transmitting
   //
   
   always @(posedge clk)
     if (rst) begin
        tx_fifo_pop <= 1'b0;
     end else begin
        tx_fifo_pop <= !is_transmitting & !tx_fifo_empty;
     end




endmodule // uart_fifo