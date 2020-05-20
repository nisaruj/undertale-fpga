module vgaSystem
	(
		input wire clk,
		input wire RsRx,
		input wire btnC,
		output wire Hsync, Vsync,
		output wire [3:0] vgaRed, vgaGreen, vgaBlue,
		output wire RsTx
	);
	
	/* COMMON */
	wire reset;
	assign reset = btnC;
	
	// Keypress event
	reg [7:0] kbControl;
	
	/* VGA */
	
	wire [11:0] rgb;
    assign vgaRed = rgb[11:8];
    assign vgaGreen = rgb[7:4];
    assign vgaBlue = rgb[3:0]; 
    	
	wire [9:0] x, y;
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

    // instantiate vga_sync
    vga_sync vga_sync_unit (.clk(clk), .reset(0), .hsync(Hsync), .vsync(Vsync),
                                .video_on(video_on), .p_tick(), .x(x), .y(y));
    
    wire [11:0] sceneRender;
    mapScene scene1(sceneRender, kbControl, x, y, clk); 
    
    // TODO: Use Scene MUX for multiple scene
    // output
    assign rgb = video_on ? sceneRender : 12'b0;
        
    /* UART */
    
   reg [7:0] tx_byte;
   reg       transmit;
   reg       rx_fifo_pop;
   
   wire [7:0] rx_byte;
   wire       irq;
   wire       busy;
   wire       tx_fifo_full;
   wire       rx_fifo_empty;
   wire       is_transmitting;
   
      uart_fifo uart_fifo(
                       // Outputs
                       .rx_byte         (rx_byte[7:0]),
                       .tx              (RsTx),
                       .irq             (irq),
                       .busy            (busy),
                       .tx_fifo_full    (tx_fifo_full),
                       .rx_fifo_empty   (rx_fifo_empty),
//                       .is_transmitting (is_transmitting),
                       // Inputs
                       .tx_byte         (tx_byte[7:0]),
                       .clk             (clk),
                       .rst             (reset),
                       .rx              (RsRx),
                       .transmit        (transmit),
                       .rx_fifo_pop     (rx_fifo_pop));
                 //
                 
   // If we get an interrupt and the tx fifo is not full, read the receive byte
   // and send it back as the transmit byte, signal transmit and pop the byte from
   // the receive FIFO.
   //
   always @(posedge clk)
     if (reset) begin
        tx_byte <= 8'h00;
        transmit <= 1'b0;
        rx_fifo_pop <= 1'b0;
     end else begin
        if (!rx_fifo_empty & !tx_fifo_full & !transmit /*& !is_transmitting*/) begin
           // ECHO HERE
           transmit <= 1'b1;
           rx_fifo_pop <= 1'b1;
            
           // To upper case    
           tx_byte <= rx_byte - 8'h20;
           kbControl <= rx_byte;
        end else begin
           tx_byte <= 8'h00;
           transmit <= 1'b0;
           rx_fifo_pop <= 1'b0;
           kbControl <= 8'h00;
        end
     end // else: !if(RESET)                      
    
endmodule