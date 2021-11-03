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
   localparam REG_CTEXT_0  = 7'h40;
   localparam REG_CTEXT_1  = 7'h41;
   localparam REG_CTEXT_2  = 7'h42;
   localparam REG_CTEXT_3  = 7'h43;
   localparam REG_CTEXT_4  = 7'h44;
   localparam REG_CTEXT_5  = 7'h45;
   localparam REG_CTEXT_6  = 7'h46;
   localparam REG_CTEXT_7  = 7'h47;   
   localparam REG_CTEXT_8  = 7'h48;
   localparam REG_CTEXT_9  = 7'h49;
   localparam REG_CTEXT_A  = 7'h4a;
   localparam REG_CTEXT_B  = 7'h4b;
   localparam REG_CTEXT_C  = 7'h4c;
   localparam REG_CTEXT_D  = 7'h4d;
   localparam REG_CTEXT_E  = 7'h4e;
   localparam REG_CTEXT_F  = 7'h4f;

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
		 store <= 0;
		 cnt <= 0;		 
	      end
	      REG_STORE: begin
		 store <= 1;
		 load <= 0;
		 cnt <= 0;		 
	      end
	      REG_PTEXT: begin
		 cnt <= cnt + 1;
		 if (cnt == 8'h1F) begin
		    cnt <= 0;	
		    store <= 0;
		    load <= 0;
		 end
		 if (store) begin
		    plaintext <= {wdata,plaintext[255:8]};
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
		    key <= {wdata,key[255:8]};
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
		    tweak1 <= {wdata,tweak1[127:8]};
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
		    tweak2 <= {wdata,tweak2[127:8]};
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
		    random_r <= {wdata,random_r[1215:8]};
		 end
	      end
	      REG_START: begin
		 start <= 1;		 
	      end
	      REG_INC: begin		 
	      end
	    endcase // case (addr)	    
	 end // if (write)	         
         else if (eoc) begin
            cipher <= cipher_o;
            start <= 0;     
         end     
      end // else: !if(!s_n_reset)      
   end // always @ (posedge clk)

   always @ (*) begin
      rdata <= 8'h00;
      case (addr) 
	REG_CTEXT_0: rdata <= cipher[  7:  0] ^ cipher[135:128];
	REG_CTEXT_1: rdata <= cipher[ 15:  8] ^ cipher[143:136];
	REG_CTEXT_2: rdata <= cipher[ 23: 16] ^ cipher[151:144];
	REG_CTEXT_3: rdata <= cipher[ 31: 24] ^ cipher[159:152];
	REG_CTEXT_4: rdata <= cipher[ 39: 32] ^ cipher[167:160];
	REG_CTEXT_5: rdata <= cipher[ 47: 40] ^ cipher[175:168];
	REG_CTEXT_6: rdata <= cipher[ 55: 48] ^ cipher[183:176];
	REG_CTEXT_7: rdata <= cipher[ 63: 56] ^ cipher[191:184];
	REG_CTEXT_8: rdata <= cipher[ 71: 64] ^ cipher[199:192];
	REG_CTEXT_9: rdata <= cipher[ 79: 72] ^ cipher[207:200];
	REG_CTEXT_A: rdata <= cipher[ 87: 80] ^ cipher[215:208];
	REG_CTEXT_B: rdata <= cipher[ 95: 88] ^ cipher[223:216];
	REG_CTEXT_C: rdata <= cipher[103: 96] ^ cipher[231:224];
	REG_CTEXT_D: rdata <= cipher[111:104] ^ cipher[239:232];
	REG_CTEXT_E: rdata <= cipher[119:112] ^ cipher[247:240];
	REG_CTEXT_F: rdata <= cipher[127:120] ^ cipher[255:248];
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
