module top (/*AUTOARG*/
   // Outputs
   trigger, uart_txd,
   // Inputs
   uart_rxd, n_reset, clk
   ) ;

   output [1:0] trigger;
   output 	uart_txd;

   input 	uart_rxd, n_reset, clk;

   // UART clock and baud rate
   parameter   UART_CLK_FREQ = 24_000_000;
   parameter   UART_BAUD     = 115_200;
   
   // internal signals
   reg [7:0] 	rdata;
   wire [7:0] 	wdata;
   wire [6:0] 	addr ;
   wire 	write;
   // read_ack not used !!
   wire 	read_ack;

   // Asynchronous reset resynchronization
   reg 		s_n_reset_, s_n_reset;

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
localparam REG_PTEXT_0   = 7'h00;
localparam REG_PTEXT_1   = 7'h01;
localparam REG_PTEXT_2   = 7'h02;
localparam REG_PTEXT_3   = 7'h03;
localparam REG_PTEXT_4   = 7'h04;
localparam REG_PTEXT_5   = 7'h05;
localparam REG_PTEXT_6   = 7'h06;
localparam REG_PTEXT_7   = 7'h07;
localparam REG_PTEXT_8   = 7'h08;
localparam REG_PTEXT_9   = 7'h09;
localparam REG_PTEXT_A   = 7'h0A;
localparam REG_PTEXT_B   = 7'h0B;
localparam REG_PTEXT_C   = 7'h0C;
localparam REG_PTEXT_D   = 7'h0D;
localparam REG_PTEXT_E   = 7'h0E;
localparam REG_PTEXT_F   = 7'h0F;


localparam REG_CIPHER_0  = 7'h10;
localparam REG_CIPHER_1  = 7'h11;
localparam REG_CIPHER_2  = 7'h12;
localparam REG_CIPHER_3  = 7'h13;
localparam REG_CIPHER_4  = 7'h14;
localparam REG_CIPHER_5  = 7'h15;
localparam REG_CIPHER_6  = 7'h16;
localparam REG_CIPHER_7  = 7'h17;
localparam REG_CIPHER_8  = 7'h18;
localparam REG_CIPHER_9  = 7'h19;
localparam REG_CIPHER_A  = 7'h1A;
localparam REG_CIPHER_B  = 7'h1B;
localparam REG_CIPHER_C  = 7'h1C;
localparam REG_CIPHER_D  = 7'h1D;
localparam REG_CIPHER_E  = 7'h1E;
localparam REG_CIPHER_F  = 7'h1F;


localparam REG_KEY_0    = 7'h20;
localparam REG_KEY_1    = 7'h21;
localparam REG_KEY_2    = 7'h22;
localparam REG_KEY_3    = 7'h23;
localparam REG_KEY_4    = 7'h24;
localparam REG_KEY_5    = 7'h25;
localparam REG_KEY_6    = 7'h26;
localparam REG_KEY_7    = 7'h27;
localparam REG_KEY_8    = 7'h28;
localparam REG_KEY_9    = 7'h29;
localparam REG_KEY_A    = 7'h2A;
localparam REG_KEY_B    = 7'h2B;
localparam REG_KEY_C    = 7'h2C;
localparam REG_KEY_D    = 7'h2D;
localparam REG_KEY_E    = 7'h2E;
localparam REG_KEY_F    = 7'h2F;

localparam REG_TWEAK1_0    = 7'h30;
localparam REG_TWEAK1_1    = 7'h31;
localparam REG_TWEAK1_2    = 7'h32;
localparam REG_TWEAK1_3    = 7'h33;
localparam REG_TWEAK1_4    = 7'h34;
localparam REG_TWEAK1_5    = 7'h35;
localparam REG_TWEAK1_6    = 7'h36;
localparam REG_TWEAK1_7    = 7'h37;
localparam REG_TWEAK1_8    = 7'h38;
localparam REG_TWEAK1_9    = 7'h39;
localparam REG_TWEAK1_A    = 7'h3A;
localparam REG_TWEAK1_B    = 7'h3B;
localparam REG_TWEAK1_C    = 7'h3C;
localparam REG_TWEAK1_D    = 7'h3D;
localparam REG_TWEAK1_E    = 7'h3E;
localparam REG_TWEAK1_F    = 7'h3F;

localparam REG_TWEAK2_0    = 7'h40;
localparam REG_TWEAK2_1    = 7'h41;
localparam REG_TWEAK2_2    = 7'h42;
localparam REG_TWEAK2_3    = 7'h43;
localparam REG_TWEAK2_4    = 7'h44;
localparam REG_TWEAK2_5    = 7'h45;
localparam REG_TWEAK2_6    = 7'h46;
localparam REG_TWEAK2_7    = 7'h47;
localparam REG_TWEAK2_8    = 7'h48;
localparam REG_TWEAK2_9    = 7'h49;
localparam REG_TWEAK2_A    = 7'h4A;
localparam REG_TWEAK2_B    = 7'h4B;
localparam REG_TWEAK2_C    = 7'h4C;
localparam REG_TWEAK2_D    = 7'h4D;
localparam REG_TWEAK2_E    = 7'h4E;
localparam REG_TWEAK2_F    = 7'h4F;


localparam REG_START     = 7'h50;

   reg [127:0] plaintext;
   reg [127:0] cipher;
   reg [127:0] key;
   reg [127:0] tweak1;
   reg [127:0] tweak2;

   reg 	       start;   

   wire        eoc;
   wire [127:0] cipher_o;
   
   always @ (posedge clk) begin
      if (!s_n_reset) begin
	 plaintext <= 128'h0;
	 cipher <= 128'h0;
	 key <= 128'h0;
	 tweak1 <= 1'h0;
	 tweak2 <= 1'h0;
	 start <= 0;	 
      end
      else begin
	 if (write) begin
	    case (addr)
	      REG_PTEXT_0 : plaintext[  7 -: 8] <= wdata;
              REG_PTEXT_1 : plaintext[ 15 -: 8] <= wdata;
              REG_PTEXT_2 : plaintext[ 23 -: 8] <= wdata;
              REG_PTEXT_3 : plaintext[ 31 -: 8] <= wdata;
              REG_PTEXT_4 : plaintext[ 39 -: 8] <= wdata;
              REG_PTEXT_5 : plaintext[ 47 -: 8] <= wdata;
              REG_PTEXT_6 : plaintext[ 55 -: 8] <= wdata;
              REG_PTEXT_7 : plaintext[ 63 -: 8] <= wdata;
              REG_PTEXT_8 : plaintext[ 71 -: 8] <= wdata;
              REG_PTEXT_9 : plaintext[ 79 -: 8] <= wdata;
              REG_PTEXT_A : plaintext[ 87 -: 8] <= wdata;
              REG_PTEXT_B : plaintext[ 95 -: 8] <= wdata;
              REG_PTEXT_C : plaintext[103 -: 8] <= wdata;
              REG_PTEXT_D : plaintext[111 -: 8] <= wdata;
              REG_PTEXT_E : plaintext[119 -: 8] <= wdata;
              REG_PTEXT_F : plaintext[127 -: 8] <= wdata;
              
	      REG_KEY_0 : key[  7 -: 8] <= wdata;
              REG_KEY_1 : key[ 15 -: 8] <= wdata;
              REG_KEY_2 : key[ 23 -: 8] <= wdata;
              REG_KEY_3 : key[ 31 -: 8] <= wdata;
              REG_KEY_4 : key[ 39 -: 8] <= wdata;
              REG_KEY_5 : key[ 47 -: 8] <= wdata;
              REG_KEY_6 : key[ 55 -: 8] <= wdata;
              REG_KEY_7 : key[ 63 -: 8] <= wdata;
              REG_KEY_8 : key[ 71 -: 8] <= wdata;
              REG_KEY_9 : key[ 79 -: 8] <= wdata;
              REG_KEY_A : key[ 87 -: 8] <= wdata;
              REG_KEY_B : key[ 95 -: 8] <= wdata;
              REG_KEY_C : key[103 -: 8] <= wdata;
              REG_KEY_D : key[111 -: 8] <= wdata;
              REG_KEY_E : key[119 -: 8] <= wdata;
              REG_KEY_F : key[127 -: 8] <= wdata;

	      REG_TWEAK1_0 : tweak1[  7 -: 8] <= wdata;
	      REG_TWEAK1_1 : tweak1[ 15 -: 8] <= wdata;
	      REG_TWEAK1_2 : tweak1[ 23 -: 8] <= wdata;
	      REG_TWEAK1_3 : tweak1[ 31 -: 8] <= wdata;
	      REG_TWEAK1_4 : tweak1[ 39 -: 8] <= wdata;
	      REG_TWEAK1_5 : tweak1[ 47 -: 8] <= wdata;
	      REG_TWEAK1_6 : tweak1[ 55 -: 8] <= wdata;
	      REG_TWEAK1_7 : tweak1[ 63 -: 8] <= wdata;
	      REG_TWEAK1_8 : tweak1[ 71 -: 8] <= wdata;
	      REG_TWEAK1_9 : tweak1[ 79 -: 8] <= wdata;
	      REG_TWEAK1_A : tweak1[ 87 -: 8] <= wdata;
	      REG_TWEAK1_B : tweak1[ 95 -: 8] <= wdata;
	      REG_TWEAK1_C : tweak1[103 -: 8] <= wdata;
	      REG_TWEAK1_D : tweak1[111 -: 8] <= wdata;
	      REG_TWEAK1_E : tweak1[119 -: 8] <= wdata;
	      REG_TWEAK1_F : tweak1[127 -: 8] <= wdata;

	      REG_TWEAK2_0 : tweak2[  7 -: 8] <= wdata;
	      REG_TWEAK2_1 : tweak2[ 15 -: 8] <= wdata;
	      REG_TWEAK2_2 : tweak2[ 23 -: 8] <= wdata;
	      REG_TWEAK2_3 : tweak2[ 31 -: 8] <= wdata;
	      REG_TWEAK2_4 : tweak2[ 39 -: 8] <= wdata;
	      REG_TWEAK2_5 : tweak2[ 47 -: 8] <= wdata;
	      REG_TWEAK2_6 : tweak2[ 55 -: 8] <= wdata;
	      REG_TWEAK2_7 : tweak2[ 63 -: 8] <= wdata;
	      REG_TWEAK2_8 : tweak2[ 71 -: 8] <= wdata;
	      REG_TWEAK2_9 : tweak2[ 79 -: 8] <= wdata;
	      REG_TWEAK2_A : tweak2[ 87 -: 8] <= wdata;
	      REG_TWEAK2_B : tweak2[ 95 -: 8] <= wdata;
	      REG_TWEAK2_C : tweak2[103 -: 8] <= wdata;
	      REG_TWEAK2_D : tweak2[111 -: 8] <= wdata;
	      REG_TWEAK2_E : tweak2[119 -: 8] <= wdata;
	      REG_TWEAK2_F : tweak2[127 -: 8] <= wdata;
              
	      REG_START   : start <= 1;
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
	REG_PTEXT_0 : rdata <= plaintext[  7 -: 8];
        REG_PTEXT_1 : rdata <= plaintext[ 15 -: 8];
        REG_PTEXT_2 : rdata <= plaintext[ 23 -: 8];
        REG_PTEXT_3 : rdata <= plaintext[ 31 -: 8];
        REG_PTEXT_4 : rdata <= plaintext[ 39 -: 8];
        REG_PTEXT_5 : rdata <= plaintext[ 47 -: 8];
        REG_PTEXT_6 : rdata <= plaintext[ 55 -: 8];
        REG_PTEXT_7 : rdata <= plaintext[ 63 -: 8];
        REG_PTEXT_8 : rdata <= plaintext[ 71 -: 8];
        REG_PTEXT_9 : rdata <= plaintext[ 79 -: 8];
        REG_PTEXT_A : rdata <= plaintext[ 87 -: 8];
        REG_PTEXT_B : rdata <= plaintext[ 95 -: 8];
        REG_PTEXT_C : rdata <= plaintext[103 -: 8];
        REG_PTEXT_D : rdata <= plaintext[111 -: 8];
        REG_PTEXT_E : rdata <= plaintext[119 -: 8];
        REG_PTEXT_F : rdata <= plaintext[127 -: 8];
        
	REG_CIPHER_0 : rdata <= cipher [  7 -: 8] ;
        REG_CIPHER_1 : rdata <= cipher [ 15 -: 8] ;
        REG_CIPHER_2 : rdata <= cipher [ 23 -: 8] ;
        REG_CIPHER_3 : rdata <= cipher [ 31 -: 8] ;
        REG_CIPHER_4 : rdata <= cipher [ 39 -: 8] ;
        REG_CIPHER_5 : rdata <= cipher [ 47 -: 8] ;
        REG_CIPHER_6 : rdata <= cipher [ 55 -: 8] ;
        REG_CIPHER_7 : rdata <= cipher [ 63 -: 8] ;
	REG_CIPHER_8 : rdata <= cipher [ 71 -: 8] ;
        REG_CIPHER_9 : rdata <= cipher [ 79 -: 8] ;
        REG_CIPHER_A : rdata <= cipher [ 87 -: 8] ;
        REG_CIPHER_B : rdata <= cipher [ 95 -: 8] ;
        REG_CIPHER_C : rdata <= cipher [103 -: 8] ;
        REG_CIPHER_D : rdata <= cipher [111 -: 8] ;
        REG_CIPHER_E : rdata <= cipher [119 -: 8] ;
        REG_CIPHER_F : rdata <= cipher [127 -: 8] ;
	
	REG_KEY_0 : rdata <= key[  7 -: 8];
        REG_KEY_1 : rdata <= key[ 15 -: 8];
        REG_KEY_2 : rdata <= key[ 23 -: 8];
        REG_KEY_3 : rdata <= key[ 31 -: 8];
        REG_KEY_4 : rdata <= key[ 39 -: 8];
        REG_KEY_5 : rdata <= key[ 47 -: 8];
        REG_KEY_6 : rdata <= key[ 55 -: 8];
        REG_KEY_7 : rdata <= key[ 63 -: 8];
        REG_KEY_8 : rdata <= key[ 71 -: 8];
        REG_KEY_9 : rdata <= key[ 79 -: 8];
        REG_KEY_A : rdata <= key[ 87 -: 8];
        REG_KEY_B : rdata <= key[ 95 -: 8];
        REG_KEY_C : rdata <= key[103 -: 8];
        REG_KEY_D : rdata <= key[111 -: 8];
        REG_KEY_E : rdata <= key[119 -: 8];
        REG_KEY_F : rdata <= key[127 -: 8];

	REG_TWEAK1_0 : rdata <= tweak1[  7 -: 8];
        REG_TWEAK1_1 : rdata <= tweak1[ 15 -: 8];
        REG_TWEAK1_2 : rdata <= tweak1[ 23 -: 8];
        REG_TWEAK1_3 : rdata <= tweak1[ 31 -: 8];
        REG_TWEAK1_4 : rdata <= tweak1[ 39 -: 8];
        REG_TWEAK1_5 : rdata <= tweak1[ 47 -: 8];
        REG_TWEAK1_6 : rdata <= tweak1[ 55 -: 8];
        REG_TWEAK1_7 : rdata <= tweak1[ 63 -: 8];
        REG_TWEAK1_8 : rdata <= tweak1[ 71 -: 8];
        REG_TWEAK1_9 : rdata <= tweak1[ 79 -: 8];
        REG_TWEAK1_A : rdata <= tweak1[ 87 -: 8];
        REG_TWEAK1_B : rdata <= tweak1[ 95 -: 8];
        REG_TWEAK1_C : rdata <= tweak1[103 -: 8];
        REG_TWEAK1_D : rdata <= tweak1[111 -: 8];
        REG_TWEAK1_E : rdata <= tweak1[119 -: 8];
        REG_TWEAK1_F : rdata <= tweak1[127 -: 8];

	REG_TWEAK2_0 : rdata <= tweak2[  7 -: 8];
        REG_TWEAK2_1 : rdata <= tweak2[ 15 -: 8];
        REG_TWEAK2_2 : rdata <= tweak2[ 23 -: 8];
        REG_TWEAK2_3 : rdata <= tweak2[ 31 -: 8];
        REG_TWEAK2_4 : rdata <= tweak2[ 39 -: 8];
        REG_TWEAK2_5 : rdata <= tweak2[ 47 -: 8];
        REG_TWEAK2_6 : rdata <= tweak2[ 55 -: 8];
        REG_TWEAK2_7 : rdata <= tweak2[ 63 -: 8];
        REG_TWEAK2_8 : rdata <= tweak2[ 71 -: 8];
        REG_TWEAK2_9 : rdata <= tweak2[ 79 -: 8];
        REG_TWEAK2_A : rdata <= tweak2[ 87 -: 8];
        REG_TWEAK2_B : rdata <= tweak2[ 95 -: 8];
        REG_TWEAK2_C : rdata <= tweak2[103 -: 8];
        REG_TWEAK2_D : rdata <= tweak2[111 -: 8];
        REG_TWEAK2_E : rdata <= tweak2[119 -: 8];
        REG_TWEAK2_F : rdata <= tweak2[127 -: 8];
      endcase // case (addr)      
   end // always @ (*)

   skinny_top inst_skinny (.cipher_o(cipher_o),.done_o(eoc),
			   .input_i(plaintext),.key_i(key),
			   .tweak1_i(tweak1),.tweak2_i(tweak2),.clk_i(clk),.rst_i(s_n_reset),.start_i(start));

   assign trigger[0] = start;
   assign trigger[1] = eoc;  
   
endmodule // top
