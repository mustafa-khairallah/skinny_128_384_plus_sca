/**********************************************************
 * File Name   : tb_uart_simple.sv
 * Description : TODO
 * Author      : T. Graba (Telecom ParisTECH)
 * Licence     : This code is distributed 'as is' without
 *               any warranty.You are free to use it and
 *               redistribute it under what ever condition
 *               you want.
 *********************************************************/

`timescale 1ns/1ns

module tb_uart_simple();

   /**********************************************************
    * File Name   : sim_includes.hsv
    * Description : some verilog tasks to handle uart
    *               communication and some global signals and
    *               definitions.
    * Author      : T. Graba (Telecom ParisTECH)
    * Licence     : This code is distributed 'as is' without
    *               any warranty.You are free to use it and
    *               redistribute it under what ever condition
    *               you want.
    *********************************************************/

   localparam          SYST_CLK_FREQ = 24_000_000;       // Hz
   localparam          UART_BAUD     = 115_200;
   localparam          GIGA          = 1_000_000_000;    // time scale is 1ns
   localparam          SYST_CLK_P    = GIGA/SYST_CLK_FREQ;
   localparam          UART_BAUD_P   = GIGA/UART_BAUD;
   localparam          UART_BAUD_P_16= UART_BAUD_P/16;

   // global simulation signals
   reg     n_reset  =  1'b0;
   // System Signals
   reg     clk = 0;

   // uart signals
   reg     to_uart = 1;
   wire    fr_uart;

   // trigger
   wire [1:0] trigger;

   // system clock
   always #(SYST_CLK_P/2) clk = !clk;

   // write serially an 8bit word generating start and stop
   // bits
   task UART_WRITE( input [7:0] word );
      integer i;
      begin
	 // start bit
	 to_uart = 0;
	 #(UART_BAUD_P);
	 for (i=0;i<8;i=i+1)
	   begin
              to_uart = word[i];
              #(UART_BAUD_P);
	   end
	 // stop bit
	 i = 255;
	 to_uart = 1;
	 #(UART_BAUD_P);
      end
   endtask

   // A write transaction to the TestChip
   task WRITE( input [7:0] data , input [6:0] address );
      begin
	 UART_WRITE({1'b0, address});
	 UART_WRITE(data);
      end
   endtask

   // A read transaction to the TestChip
   task READ( input [6:0] address , output reg [7:0] udata);
      integer i;
      begin
	 fork
	    // send a read command
	    begin
	       UART_WRITE({1'b1, address});
	    end
	    // wait for responce
	    begin
	       // wait for start bit
	       while(fr_uart != 0) #(UART_BAUD_P_16);

	       for (i=0;i<8;i=i+1)
		 begin
		    #(UART_BAUD_P);
		    udata[i] = fr_uart;
		 end
               #(UART_BAUD_P);
               if (!fr_uart) $display ("WARNING! No stop bit  from uart!");
	    end
	 join
      end
   endtask

   task CHECK_REG( input[6:0] Addr);
      reg[7:0] val,rval;
      begin
	 val = $random(); 
	 WRITE(val, Addr);
	 READ (Addr, rval);
	 if (rval != val ) 
	   begin
	      //$error("Value read from register %02h is not correct!",Addr);
	      $stop();
	   end
	 else
	   $display("Value read from register %02h is correct!",Addr);

      end
   endtask // CHECK_REG

   localparam REG_LOAD   = 7'h00;
   localparam REG_STORE  = 7'h01;

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

   localparam REG_START  = 7'h30;
   localparam REG_INC    = 7'h31;

   reg [255:0] plaintext;
   reg [127:0] cipher;
   reg [255:0] key;
   reg [127:0] tweak1;
   reg [127:0] tweak2;
   reg [1215:0] random_r;
   reg [127:0] 	mask;   

   top uut (

	    .n_reset  ( n_reset  ),
	    .clk      ( clk   ),
	    .uart_rxd ( to_uart  ),
	    .uart_txd ( fr_uart  ),
	    .trigger ( trigger )

	    // .switch   (  switch  )
	    //.trigger  ( trigger )
	    );

   // Test Sequence
   initial
     begin: main_loop
	reg[7:0] rdata;

	n_reset = 1'b0;
	
	key[127:0] = {8'hab,8'h1a,8'hfa,8'hc2,8'h61,8'h10,8'h12,8'hcd,8'h8c,8'hef,8'h95,8'h26,8'h18,8'hc3,8'heb,8'he8};
	tweak1 = {8'hdf,8'h88,8'h95,8'h48,8'hcf,8'hc7,8'hea,8'h52,8'hd2,8'h96,8'h33,8'h93,8'h01,8'h79,8'h74,8'h49};
	tweak2 = {8'hab,8'h58,8'h8a,8'h34,8'ha4,8'h7f,8'h1a,8'hb2,8'hdf,8'he9,8'hc8,8'h29,8'h3f,8'hbe,8'ha9,8'ha5};
	plaintext[127:0] = {8'ha3,8'h99,8'h4b,8'h66,8'had,8'h85,8'ha3,8'h45,8'h9f,8'h44,8'he9,8'h2b,8'h08,8'hf5,8'h50,8'hcb};

	mask = {$random(),$random(),$random(),$random()};
	key[255:128] = mask;
	key[127:0] = key[127:0] ^ mask;

	mask = {$random(),$random(),$random(),$random()};
	plaintext[255:128] = mask;
	plaintext[127:0] = plaintext[127:0] ^ mask;

	random_r = {$random(),$random(),$random(),$random(),
		    $random(),$random(),$random(),$random(),
		    $random(),$random(),$random(),$random(),
		    $random(),$random(),$random(),$random(),
		    $random(),$random(),$random(),$random(),
		    $random(),$random(),$random(),$random(),
		    $random(),$random(),$random(),$random(),
		    $random(),$random(),$random(),$random(),
		    $random(),$random(),$random(),$random(),
		    $random(),$random()};	
	
	#1000;
	n_reset = ! 1'b0;



	#1000;
	WRITE(1,REG_STORE);	
	WRITE(key[8*0+7-:8] , REG_KEY);
	WRITE(key[8*1+7-:8] , REG_KEY);
	WRITE(key[8*2+7-:8] , REG_KEY);
	WRITE(key[8*3+7-:8] , REG_KEY);
	WRITE(key[8*4+7-:8] , REG_KEY);
	WRITE(key[8*5+7-:8] , REG_KEY);
	WRITE(key[8*6+7-:8] , REG_KEY);
	WRITE(key[8*7+7-:8] , REG_KEY);
	WRITE(key[8*8+7-:8] , REG_KEY);
	WRITE(key[8*9+7-:8] , REG_KEY);
	WRITE(key[8*10+7-:8], REG_KEY);
	WRITE(key[8*11+7-:8], REG_KEY);
	WRITE(key[8*12+7-:8], REG_KEY);
	WRITE(key[8*13+7-:8], REG_KEY);
	WRITE(key[8*14+7-:8], REG_KEY);
	WRITE(key[8*15+7-:8], REG_KEY);
	WRITE(key[8*16+7-:8], REG_KEY);
	WRITE(key[8*17+7-:8], REG_KEY);
	WRITE(key[8*18+7-:8], REG_KEY);
	WRITE(key[8*19+7-:8], REG_KEY);
	WRITE(key[8*20+7-:8], REG_KEY);
	WRITE(key[8*21+7-:8], REG_KEY);
	WRITE(key[8*22+7-:8], REG_KEY);
	WRITE(key[8*23+7-:8], REG_KEY);
	WRITE(key[8*24+7-:8], REG_KEY);
	WRITE(key[8*25+7-:8], REG_KEY);
	WRITE(key[8*26+7-:8], REG_KEY);
	WRITE(key[8*27+7-:8], REG_KEY);
	WRITE(key[8*28+7-:8], REG_KEY);
	WRITE(key[8*29+7-:8], REG_KEY);
	WRITE(key[8*30+7-:8], REG_KEY);
	WRITE(key[8*31+7-:8], REG_KEY);

	WRITE(1,REG_STORE);	
	WRITE(tweak1[8*0+7-:8] , REG_TWEAK1);
	WRITE(tweak1[8*1+7-:8] , REG_TWEAK1);
	WRITE(tweak1[8*2+7-:8] , REG_TWEAK1);
	WRITE(tweak1[8*3+7-:8] , REG_TWEAK1);
	WRITE(tweak1[8*4+7-:8] , REG_TWEAK1);
	WRITE(tweak1[8*5+7-:8] , REG_TWEAK1);
	WRITE(tweak1[8*6+7-:8] , REG_TWEAK1);
	WRITE(tweak1[8*7+7-:8] , REG_TWEAK1);
	WRITE(tweak1[8*8+7-:8] , REG_TWEAK1);
	WRITE(tweak1[8*9+7-:8] , REG_TWEAK1);
	WRITE(tweak1[8*10+7-:8], REG_TWEAK1);
	WRITE(tweak1[8*11+7-:8], REG_TWEAK1);
	WRITE(tweak1[8*12+7-:8], REG_TWEAK1);
	WRITE(tweak1[8*13+7-:8], REG_TWEAK1);
	WRITE(tweak1[8*14+7-:8], REG_TWEAK1);
	WRITE(tweak1[8*15+7-:8], REG_TWEAK1);

	WRITE(1,REG_STORE);	
	WRITE(tweak2[8*0+7-:8] , REG_TWEAK2);
	WRITE(tweak2[8*1+7-:8] , REG_TWEAK2);
	WRITE(tweak2[8*2+7-:8] , REG_TWEAK2);
	WRITE(tweak2[8*3+7-:8] , REG_TWEAK2);
	WRITE(tweak2[8*4+7-:8] , REG_TWEAK2);
	WRITE(tweak2[8*5+7-:8] , REG_TWEAK2);
	WRITE(tweak2[8*6+7-:8] , REG_TWEAK2);
	WRITE(tweak2[8*7+7-:8] , REG_TWEAK2);
	WRITE(tweak2[8*8+7-:8] , REG_TWEAK2);
	WRITE(tweak2[8*9+7-:8] , REG_TWEAK2);
	WRITE(tweak2[8*10+7-:8], REG_TWEAK2);
	WRITE(tweak2[8*11+7-:8], REG_TWEAK2);
	WRITE(tweak2[8*12+7-:8], REG_TWEAK2);
	WRITE(tweak2[8*13+7-:8], REG_TWEAK2);
	WRITE(tweak2[8*14+7-:8], REG_TWEAK2);
	WRITE(tweak2[8*15+7-:8], REG_TWEAK2);

	WRITE(1,REG_STORE);	
	WRITE(plaintext[8*0+7-:8] , REG_PTEXT);
	WRITE(plaintext[8*1+7-:8] , REG_PTEXT);
	WRITE(plaintext[8*2+7-:8] , REG_PTEXT);
	WRITE(plaintext[8*3+7-:8] , REG_PTEXT);
	WRITE(plaintext[8*4+7-:8] , REG_PTEXT);
	WRITE(plaintext[8*5+7-:8] , REG_PTEXT);
	WRITE(plaintext[8*6+7-:8] , REG_PTEXT);
	WRITE(plaintext[8*7+7-:8] , REG_PTEXT);
	WRITE(plaintext[8*8+7-:8] , REG_PTEXT);
	WRITE(plaintext[8*9+7-:8] , REG_PTEXT);
	WRITE(plaintext[8*10+7-:8], REG_PTEXT);
	WRITE(plaintext[8*11+7-:8], REG_PTEXT);
	WRITE(plaintext[8*12+7-:8], REG_PTEXT);
	WRITE(plaintext[8*13+7-:8], REG_PTEXT);
	WRITE(plaintext[8*14+7-:8], REG_PTEXT);
	WRITE(plaintext[8*15+7-:8], REG_PTEXT);
	WRITE(plaintext[8*16+7-:8], REG_PTEXT);
	WRITE(plaintext[8*17+7-:8], REG_PTEXT);
	WRITE(plaintext[8*18+7-:8], REG_PTEXT);
	WRITE(plaintext[8*19+7-:8], REG_PTEXT);
	WRITE(plaintext[8*20+7-:8], REG_PTEXT);
	WRITE(plaintext[8*21+7-:8], REG_PTEXT);
	WRITE(plaintext[8*22+7-:8], REG_PTEXT);
	WRITE(plaintext[8*23+7-:8], REG_PTEXT);
	WRITE(plaintext[8*24+7-:8], REG_PTEXT);
	WRITE(plaintext[8*25+7-:8], REG_PTEXT);
	WRITE(plaintext[8*26+7-:8], REG_PTEXT);
	WRITE(plaintext[8*27+7-:8], REG_PTEXT);
	WRITE(plaintext[8*28+7-:8], REG_PTEXT);
	WRITE(plaintext[8*29+7-:8], REG_PTEXT);
	WRITE(plaintext[8*30+7-:8], REG_PTEXT);
	WRITE(plaintext[8*31+7-:8], REG_PTEXT);

	WRITE(1,REG_STORE);	
	WRITE(random_r[8*0+7-:8] , REG_RAND);
	WRITE(random_r[8*1+7-:8] , REG_RAND);
	WRITE(random_r[8*2+7-:8] , REG_RAND);
	WRITE(random_r[8*3+7-:8] , REG_RAND);
	WRITE(random_r[8*4+7-:8] , REG_RAND);
	WRITE(random_r[8*5+7-:8] , REG_RAND);
	WRITE(random_r[8*6+7-:8] , REG_RAND);
	WRITE(random_r[8*7+7-:8] , REG_RAND);
	WRITE(random_r[8*8+7-:8] , REG_RAND);
	WRITE(random_r[8*9+7-:8] , REG_RAND);
	WRITE(random_r[8*10+7-:8], REG_RAND);
	WRITE(random_r[8*11+7-:8], REG_RAND);
	WRITE(random_r[8*12+7-:8], REG_RAND);
	WRITE(random_r[8*13+7-:8], REG_RAND);
	WRITE(random_r[8*14+7-:8], REG_RAND);
	WRITE(random_r[8*15+7-:8], REG_RAND);
	WRITE(random_r[8*16+7-:8], REG_RAND);
	WRITE(random_r[8*17+7-:8], REG_RAND);
	WRITE(random_r[8*18+7-:8], REG_RAND);
	WRITE(random_r[8*19+7-:8], REG_RAND);
	WRITE(random_r[8*20+7-:8], REG_RAND);
	WRITE(random_r[8*21+7-:8], REG_RAND);
	WRITE(random_r[8*22+7-:8], REG_RAND);
	WRITE(random_r[8*23+7-:8], REG_RAND);
	WRITE(random_r[8*24+7-:8], REG_RAND);
	WRITE(random_r[8*25+7-:8], REG_RAND);
	WRITE(random_r[8*26+7-:8], REG_RAND);
	WRITE(random_r[8*27+7-:8], REG_RAND);
	WRITE(random_r[8*28+7-:8], REG_RAND);
	WRITE(random_r[8*29+7-:8], REG_RAND);
	WRITE(random_r[8*30+7-:8], REG_RAND);
	WRITE(random_r[8*31+7-:8], REG_RAND);

	WRITE(random_r[8*32+7-:8], REG_RAND);
	WRITE(random_r[8*33+7-:8], REG_RAND);
	WRITE(random_r[8*34+7-:8], REG_RAND);
	WRITE(random_r[8*35+7-:8], REG_RAND);
	WRITE(random_r[8*36+7-:8], REG_RAND);
	WRITE(random_r[8*37+7-:8], REG_RAND);
	WRITE(random_r[8*38+7-:8], REG_RAND);
	WRITE(random_r[8*39+7-:8], REG_RAND);
	WRITE(random_r[8*40+7-:8], REG_RAND);
	WRITE(random_r[8*41+7-:8], REG_RAND);
	WRITE(random_r[8*42+7-:8], REG_RAND);
	WRITE(random_r[8*43+7-:8], REG_RAND);
	WRITE(random_r[8*44+7-:8], REG_RAND);
	WRITE(random_r[8*45+7-:8], REG_RAND);
	WRITE(random_r[8*46+7-:8], REG_RAND);
	WRITE(random_r[8*47+7-:8], REG_RAND);
	WRITE(random_r[8*48+7-:8], REG_RAND);
	WRITE(random_r[8*49+7-:8], REG_RAND);
	WRITE(random_r[8*50+7-:8], REG_RAND);
	WRITE(random_r[8*51+7-:8], REG_RAND);
	WRITE(random_r[8*52+7-:8], REG_RAND);
	WRITE(random_r[8*53+7-:8], REG_RAND);
	WRITE(random_r[8*54+7-:8], REG_RAND);
	WRITE(random_r[8*55+7-:8], REG_RAND);
	WRITE(random_r[8*56+7-:8], REG_RAND);
	WRITE(random_r[8*57+7-:8], REG_RAND);
	WRITE(random_r[8*58+7-:8], REG_RAND);
	WRITE(random_r[8*59+7-:8], REG_RAND);
	WRITE(random_r[8*60+7-:8], REG_RAND);
	WRITE(random_r[8*61+7-:8], REG_RAND);
	WRITE(random_r[8*62+7-:8], REG_RAND);
	WRITE(random_r[8*63+7-:8], REG_RAND);

	WRITE(random_r[8*64+7-:8], REG_RAND);
	WRITE(random_r[8*65+7-:8], REG_RAND);
	WRITE(random_r[8*66+7-:8], REG_RAND);
	WRITE(random_r[8*67+7-:8], REG_RAND);
	WRITE(random_r[8*68+7-:8], REG_RAND);
	WRITE(random_r[8*69+7-:8], REG_RAND);
	WRITE(random_r[8*70+7-:8], REG_RAND);
	WRITE(random_r[8*71+7-:8], REG_RAND);
	WRITE(random_r[8*72+7-:8], REG_RAND);
	WRITE(random_r[8*73+7-:8], REG_RAND);
	WRITE(random_r[8*74+7-:8], REG_RAND);
	WRITE(random_r[8*75+7-:8], REG_RAND);
	WRITE(random_r[8*76+7-:8], REG_RAND);
	WRITE(random_r[8*77+7-:8], REG_RAND);
	WRITE(random_r[8*78+7-:8], REG_RAND);
	WRITE(random_r[8*79+7-:8], REG_RAND);
	WRITE(random_r[8*80+7-:8], REG_RAND);
	WRITE(random_r[8*81+7-:8], REG_RAND);
	WRITE(random_r[8*82+7-:8], REG_RAND);
	WRITE(random_r[8*83+7-:8], REG_RAND);
	WRITE(random_r[8*84+7-:8], REG_RAND);
	WRITE(random_r[8*85+7-:8], REG_RAND);
	WRITE(random_r[8*86+7-:8], REG_RAND);
	WRITE(random_r[8*87+7-:8], REG_RAND);
	WRITE(random_r[8*88+7-:8], REG_RAND);
	WRITE(random_r[8*89+7-:8], REG_RAND);
	WRITE(random_r[8*90+7-:8], REG_RAND);
	WRITE(random_r[8*91+7-:8], REG_RAND);
	WRITE(random_r[8*92+7-:8], REG_RAND);
	WRITE(random_r[8*93+7-:8], REG_RAND);
	WRITE(random_r[8*94+7-:8], REG_RAND);
	WRITE(random_r[8*95+7-:8], REG_RAND);

	WRITE(random_r[8*96+7-:8], REG_RAND);
	WRITE(random_r[8*97+7-:8], REG_RAND);
	WRITE(random_r[8*98+7-:8], REG_RAND);
	WRITE(random_r[8*99+7-:8], REG_RAND);
	WRITE(random_r[8*100+7-:8], REG_RAND);
	WRITE(random_r[8*101+7-:8], REG_RAND);
	WRITE(random_r[8*102+7-:8], REG_RAND);
	WRITE(random_r[8*103+7-:8], REG_RAND);
	WRITE(random_r[8*104+7-:8], REG_RAND);
	WRITE(random_r[8*105+7-:8], REG_RAND);
	WRITE(random_r[8*106+7-:8], REG_RAND);
	WRITE(random_r[8*107+7-:8], REG_RAND);
	WRITE(random_r[8*108+7-:8], REG_RAND);
	WRITE(random_r[8*109+7-:8], REG_RAND);
	WRITE(random_r[8*110+7-:8], REG_RAND);
	WRITE(random_r[8*111+7-:8], REG_RAND);
	WRITE(random_r[8*112+7-:8], REG_RAND);
	WRITE(random_r[8*113+7-:8], REG_RAND);
	WRITE(random_r[8*114+7-:8], REG_RAND);
	WRITE(random_r[8*115+7-:8], REG_RAND);
	WRITE(random_r[8*116+7-:8], REG_RAND);
	WRITE(random_r[8*117+7-:8], REG_RAND);
	WRITE(random_r[8*118+7-:8], REG_RAND);
	WRITE(random_r[8*119+7-:8], REG_RAND);
	WRITE(random_r[8*120+7-:8], REG_RAND);
	WRITE(random_r[8*121+7-:8], REG_RAND);
	WRITE(random_r[8*122+7-:8], REG_RAND);
	WRITE(random_r[8*123+7-:8], REG_RAND);
	WRITE(random_r[8*124+7-:8], REG_RAND);
	WRITE(random_r[8*125+7-:8], REG_RAND);
	WRITE(random_r[8*126+7-:8], REG_RAND);
	WRITE(random_r[8*127+7-:8], REG_RAND);

	WRITE(random_r[8*128+7-:8], REG_RAND);
	WRITE(random_r[8*129+7-:8], REG_RAND);
	WRITE(random_r[8*130+7-:8], REG_RAND);
	WRITE(random_r[8*131+7-:8], REG_RAND);
	WRITE(random_r[8*132+7-:8], REG_RAND);
	WRITE(random_r[8*133+7-:8], REG_RAND);
	WRITE(random_r[8*134+7-:8], REG_RAND);
	WRITE(random_r[8*135+7-:8], REG_RAND);
	WRITE(random_r[8*136+7-:8], REG_RAND);
	WRITE(random_r[8*137+7-:8], REG_RAND);
	WRITE(random_r[8*138+7-:8], REG_RAND);
	WRITE(random_r[8*139+7-:8], REG_RAND);
	WRITE(random_r[8*140+7-:8], REG_RAND);
	WRITE(random_r[8*141+7-:8], REG_RAND);
	WRITE(random_r[8*142+7-:8], REG_RAND);
	WRITE(random_r[8*143+7-:8], REG_RAND);
	WRITE(random_r[8*144+7-:8], REG_RAND);
	WRITE(random_r[8*145+7-:8], REG_RAND);
	WRITE(random_r[8*146+7-:8], REG_RAND);
	WRITE(random_r[8*147+7-:8], REG_RAND);
	WRITE(random_r[8*148+7-:8], REG_RAND);
	WRITE(random_r[8*149+7-:8], REG_RAND);
	WRITE(random_r[8*150+7-:8], REG_RAND);
	WRITE(random_r[8*151+7-:8], REG_RAND);	
	
	#1000;
	WRITE(    1 , REG_START);
	
	#1000;

	WRITE(1,REG_LOAD);
	
	READ(REG_CTEXT_0,cipher[8*0+7-:8]);
	READ(REG_CTEXT_1,cipher[8*1+7-:8]);
	READ(REG_CTEXT_2,cipher[8*2+7-:8]);
	READ(REG_CTEXT_3,cipher[8*3+7-:8]);
	READ(REG_CTEXT_4,cipher[8*4+7-:8]);
	READ(REG_CTEXT_5,cipher[8*5+7-:8]);
	READ(REG_CTEXT_6,cipher[8*6+7-:8]);
	READ(REG_CTEXT_7,cipher[8*7+7-:8]);
	READ(REG_CTEXT_8,cipher[8*8+7-:8]);
	READ(REG_CTEXT_9,cipher[8*9+7-:8]);
	READ(REG_CTEXT_A,cipher[8*10+7-:8]);
	READ(REG_CTEXT_B,cipher[8*11+7-:8]);
	READ(REG_CTEXT_C,cipher[8*12+7-:8]);
	READ(REG_CTEXT_D,cipher[8*13+7-:8]);
	READ(REG_CTEXT_E,cipher[8*14+7-:8]);
	READ(REG_CTEXT_F,cipher[8*15+7-:8]);


	$display ("%h (+) %h (+) %h (+) %h -> %h @ %t ns",plaintext[127:0]^plaintext[255:128],
		  tweak1,tweak2,
		  key[127:0]^key[255:128],
		  cipher[127:0],$time);
	
	$stop();
     end

endmodule
