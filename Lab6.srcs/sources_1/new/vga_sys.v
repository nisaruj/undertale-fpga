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
	
	// register for Basys 2 8-bit RGB DAC
	reg [11:0] rgb_reg;
	
	reg [9:0] center_x, center_y;
	
	always @(center_x, center_y)
	   $display("(%d, %d)", center_x, center_y);
	
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
   
        initial
        begin
            center_x = 9'd320;
            center_y = 9'd240;
            rgb_reg = 12'hFFF;
        end
        
        // rgb buffer
        always @(posedge clk, posedge reset)
        if (reset)
            rgb_reg <= 12'hFFF;
        
        wire render;
        renderer circle(render, {22'd0, center_x}, {22'd0,center_y}, {22'd0,x}, {22'd0,y}, 100); 
        // output
        assign rgb = (render && video_on) ? rgb_reg : 12'b0;
        
        
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
           
           tx_byte <= rx_byte - 8'h20;
           if (rx_byte == 119) //w
                center_y <= center_y - 1;
           else if (rx_byte == 97) //a
                center_x <= center_x - 1;
           else if (rx_byte == 115) //s
                center_y <= center_y + 1;
           else if (rx_byte == 100) //d
                center_x <= center_x + 1;
           else if (rx_byte == 99) //c
                rgb_reg <= 12'h0FF;
           else if (rx_byte == 109) //m
                rgb_reg <= 12'hF0F;
           else if (rx_byte == 121) //y
                rgb_reg <= 12'hFF0;
           else if (rx_byte == 32)//space
           begin
                rgb_reg <= 12'hFFF;
                tx_byte <= 90; //Z
           end
           else transmit <= 1'b0; // Send nothing
        end else begin
           tx_byte <= 8'h00;
           transmit <= 1'b0;
           rx_fifo_pop <= 1'b0;
        end
     end // else: !if(RESET)                      
    
endmodule