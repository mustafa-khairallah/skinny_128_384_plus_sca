module top (/*AUTOARG*/
   // Outputs
   trigger, uart_txd,
   // Inputs
   uart_rxd, n_reset, clk
   ) ;

   output [1:0] trigger;
   output       uart_txd;

   input        uart_rxd, n_reset, clk;

   // UART clock and baud rate
   parameter   UART_CLK_FREQ = 24_000_000;
   parameter   UART_BAUD     = 115_200;
   
   // internal signals
   reg [7:0]    rdata;
   wire [7:0]   wdata;
   wire [6:0]   addr ;
   wire         write;
   // read_ack not used !!
   wire         read_ack;

   // Asynchronous reset resynchronization
   reg          s_n_reset_, s_n_reset;

   always@(posedge clk or negedge n_reset)
     if (!n_reset) begin
        s_n_reset_ <= 1'b0;
        s_n_reset  <= 1'b0;
     end else begin
        s_n_reset_ <= 1'b1;
        s_n_reset  <= s_n_reset_;
     end

   // Uart interface
   uart_interface #(
                    .UART_CLK_FREQ ( UART_CLK_FREQ ),
                    .UART_BAUD     ( UART_BAUD     )    
                    )
   uart_inst
     (
      // System Signals
      .n_reset ( s_n_reset ),
      .clk     ( clk      ),
      // UART signals,
      .uart_rxd     ( uart_rxd ),
      .uart_txd     ( uart_txd ),
      // System Interface,
      .rdata        ( rdata    ),
      .wdata        ( wdata    ),
      .addr         ( addr     ),
      .write        ( write    ),
      .read_ack     ( read_ack )
      );
   localparam REG_LOAD   = 7'h00;
   localparam REG_STORE   = 7'h01;

   localparam REG_PTEXT  = 7'h20;
   localparam REG_KEY    = 7'h21;
   localparam REG_TWEAK1 = 7'h22;
   localparam REG_TWEAK2 = 7'h23;
   localparam REG_RAND   = 7'h24;
   localparam REG_CTEXT  = 7'h25;

   localparam REG_START     = 7'h30;
   localparam REG_INC       = 7'h31;

   reg [255:0] plaintext;
   reg [255:0] cipher;
   reg [255:0] key;
   reg [127:0] tweak1;
   reg [127:0] tweak2;
   reg [1215:0] random_r;

   reg          start, load, store;

   reg [7:0] 	cnt;   

   wire         eoc;
   wire [255:0] cipher_o;
   
   
   always @ (posedge clk) begin
      if (!s_n_reset) begin
         plaintext <= 256'h0;
         cipher <= 256'h0;
         key <= 256'h0;
         tweak1 <= 128'h0;
         tweak2 <= 128'h0;
         random_r <= 1216'h0;
         start <= 0;
         load <= 0;
         store <= 0;
         cnt <= 0;
      end
      else begin
	 if (write) begin
	    case (addr) 
	      REG_LOAD: begin
		 load <= 1;		 
	      end
	      REG_STORE: begin
		 store <= 1;		 
	      end
	      REG_PTEXT: begin
		 cnt <= cnt + 1;
		 if (cnt == 8'h1F) begin
		    cnt <= 0;	
		    store <= 0;
		    load <= 0;
		 end
		 if (store) begin
		    plaintext <= {plaintext[247:0],wdata};
		 end
		 else if (load) begin
		    plaintext <= {plaintext[247:0],plaintext[255:248]};
		 end
	      end
	      REG_CTEXT: begin
		 cnt <= cnt + 1;
		 if (cnt == 8'h1F) begin
		    cnt <= 0;	
		    store <= 0;
		    load <= 0;
		 end
		 if (store) begin
		    cipher <= {cipher[247:0],wdata};
		 end
		 else if (load) begin
		    cipher <= {cipher[247:0],cipher[255:248]};
		 end
	      end
	      REG_KEY: begin
		 cnt <= cnt + 1;
		 if (cnt == 8'h1F) begin
		    cnt <= 0;	
		    store <= 0;
		    load <= 0;
		 end
		 if (store) begin
		    key <= {key[247:0],wdata};
		 end
		 else if (load) begin
		    key <= {key[247:0],key[255:248]};
		 end
	      end
	      REG_TWEAK1: begin
		 cnt <= cnt + 1;
		 if (cnt == 8'h0F) begin
		    cnt <= 0;	
		    store <= 0;
		    load <= 0;
		 end
		 if (store) begin
		    tweak1 <= {tweak1[119:0],wdata};
		 end
		 else if (load) begin
		    tweak1 <= {tweak1[119:0],tweak1[127:120]};
		 end
	      end
	      REG_TWEAK2: begin
		 cnt <= cnt + 1;
		 if (cnt == 8'h0F) begin
		    cnt <= 0;	
		    store <= 0;
		    load <= 0;
		 end
		 if (store) begin
		    tweak2 <= {tweak2[119:0],wdata};
		 end
		 else if (load) begin
		    tweak2 <= {tweak2[119:0],tweak2[127:120]};
		 end
	      end
	      REG_RAND: begin
		 cnt <= cnt + 1;
		 if (cnt == 8'h98) begin
		    cnt <= 0;	
		    store <= 0;
		    load <= 0;
		 end
		 if (store) begin
		    random_r <= {random_r[1207:0],wdata};
		 end
		 else if (load) begin
		    random_r <= {random_r[1207:0],random_r[1215:1208]};
		 end
	      end
	      REG_START: begin
		 start <= 1;		 
	      end
	      REG_INC: begin		 
	      end
	    endcase // case (addr)	    
	 end                   
         else if (eoc) begin
            cipher <= cipher_o;
            start <= 0;     
         end     
      end // else: !if(!s_n_reset)      
   end // always @ (posedge clk)

   always @ (*) begin
      rdata <= 8'h00;
      case (addr) 
	REG_PTEXT: begin
	   rdata <= plaintext[255:248];
	end
	REG_CTEXT: begin
	   rdata <= cipher[255:248];
	end
	REG_KEY: begin
	   rdata <= key[255:248];
	end
	REG_TWEAK1: begin
	   rdata <= tweak1[127:120];
	end
	REG_TWEAK2: begin
	   rdata <= tweak2[127:120];
	end
	REG_RAND: begin
	   rdata <= random_r[1215:1208];
	end
      endcase // case (addr)      
   end // always @ (*)

   skinny_2shares_top inst_skinny (.cipher_o(cipher_o),.done_o(eoc),
				   .input_i(plaintext),.key_i(key),
				   .tweak1_i(tweak1),.tweak2_i(tweak2),
				   .clk_i(clk),.rst_i(s_n_reset),.start_i(start),
				   .random_i(random_r));

   assign trigger[0] = start;
   assign trigger[1] = eoc;  
   
endmodule // top
