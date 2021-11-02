module skinny_2shares_top (/*AUTOARG*/
                   // Outputs
                   cipher_o, done_o,
                   // Inputs
                   random_i, input_i, key_i, tweak1_i, tweak2_i, clk_i, rst_i, start_i
                   ) ;
   parameter rpsb = 8;   
   
   output [255:0] cipher_o;
   output reg     done_o;

   input [1215:0] random_i;
   input [255:0]  input_i, key_i;
	input [127:0] tweak1_i, tweak2_i;
   input          clk_i, rst_i, start_i;

   reg [1215:0] random_r;
   
   reg [255:0]    state;
   reg [255:0]    key;
   wire [255:0]   next_key;
   reg [127:0]    tweak1;
   wire [127:0]   next_tweak1;
   reg [127:0]    tweak2;
   wire [127:0]   next_tweak2;
   reg [5:0]      constant;
   reg [4:0] 	  en;   

   wire [255:0]   sb, atk, shr, mxc, rkey; 

   assign cipher_o = state;
   
   always @ (posedge clk_i) begin
      if (!rst_i) begin
         done_o <= 1;
         constant <= 6'h01;
	 en <= 5'h10;	 
      end
      else if (start_i) begin
         constant <= 6'h01;
         state <= input_i;
	 random_r <= random_i;	 
         key <= key_i;
         tweak1 <= tweak1_i;
         tweak2 <= tweak2_i;     
         done_o <= 0;
	 en <= 5'h01;	 
      end
      else if (done_o == 0) begin
	 en <= {en[3:0],en[4]};	 
	 if (en[4]) begin
            constant <= {constant[4:0],constant[5]^constant[4]^1'b1};
            state <= mxc;
            key <= next_key;
            tweak1 <= next_tweak1;
            tweak2 <= next_tweak2;
	    random_r <= {random_r[1214:0],
			 random_r[1215]^random_r[27]^random_r[25]^random_r[9]^random_r[0]};  
            if (constant == 6'h1a) begin
               done_o <= 1;            
            end
	 end
      end
   end // always @ (posedge clk)

   // Tweakey Schedule
   key_expansion tk3_shr0 (.ko(next_key[127:0]), .ki(key[127:0]));
   key_expansion tk3_shr1 (.ko(next_key[255:128]), .ki(key[255:128]));
   tweak2_expansion tk2 (.ko(next_tweak2), .ki(tweak2));
   tweak1_expansion tk1 (.ko(next_tweak1), .ki(tweak1));

   // Round Tweakey
   assign rkey[127:0] = {key[127:64],64'h0} ^ {tweak1[127:64],64'h0} ^ 
			{4'h0,constant[3:0],24'h0,6'h0,constant[5:4],24'h0,8'h02,56'h0};
   assign rkey[255:128] = {key[255:192],64'h0} ^ {tweak2[127:64],64'h0}^
			  {4'h0,constant[3:0],24'h0,6'h0,constant[5:4],24'h0,8'h02,56'h0};

   // SBox layer
   skinny_sbox8_dom1_non_pipelined sbox00 (.bo1(sb[  7+128:  0+128]), .bo0(sb[	7:  0]), .si1(state[  7+128:  0+128]), .si0(state[  7:  0]), .r(random_r[  7:  0]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox01 (.bo1(sb[ 15+128:  8+128]), .bo0(sb[ 15:  8]), .si1(state[ 15+128:  8+128]), .si0(state[ 15:	8]), .r(random_r[ 15:  8]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox02 (.bo1(sb[ 23+128: 16+128]), .bo0(sb[ 23: 16]), .si1(state[ 23+128: 16+128]), .si0(state[ 23: 16]), .r(random_r[ 23: 16]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox03 (.bo1(sb[ 31+128: 24+128]), .bo0(sb[ 31: 24]), .si1(state[ 31+128: 24+128]), .si0(state[ 31: 24]), .r(random_r[ 31: 24]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox04 (.bo1(sb[ 39+128: 32+128]), .bo0(sb[ 39: 32]), .si1(state[ 39+128: 32+128]), .si0(state[ 39: 32]), .r(random_r[ 39: 32]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox05 (.bo1(sb[ 47+128: 40+128]), .bo0(sb[ 47: 40]), .si1(state[ 47+128: 40+128]), .si0(state[ 47: 40]), .r(random_r[ 47: 40]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox06 (.bo1(sb[ 55+128: 48+128]), .bo0(sb[ 55: 48]), .si1(state[ 55+128: 48+128]), .si0(state[ 55: 48]), .r(random_r[ 55: 48]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox07 (.bo1(sb[ 63+128: 56+128]), .bo0(sb[ 63: 56]), .si1(state[ 63+128: 56+128]), .si0(state[ 63: 56]), .r(random_r[ 63: 56]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox08 (.bo1(sb[ 71+128: 64+128]), .bo0(sb[ 71: 64]), .si1(state[ 71+128: 64+128]), .si0(state[ 71: 64]), .r(random_r[ 71: 64]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox09 (.bo1(sb[ 79+128: 72+128]), .bo0(sb[ 79: 72]), .si1(state[ 79+128: 72+128]), .si0(state[ 79: 72]), .r(random_r[ 79: 72]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox10 (.bo1(sb[ 87+128: 80+128]), .bo0(sb[ 87: 80]), .si1(state[ 87+128: 80+128]), .si0(state[ 87: 80]), .r(random_r[ 87: 80]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox11 (.bo1(sb[ 95+128: 88+128]), .bo0(sb[ 95: 88]), .si1(state[ 95+128: 88+128]), .si0(state[ 95: 88]), .r(random_r[ 95: 88]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox12 (.bo1(sb[103+128: 96+128]), .bo0(sb[103: 96]), .si1(state[103+128: 96+128]), .si0(state[103: 96]), .r(random_r[103: 96]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox13 (.bo1(sb[111+128:104+128]), .bo0(sb[111:104]), .si1(state[111+128:104+128]), .si0(state[111:104]), .r(random_r[111:104]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox14 (.bo1(sb[119+128:112+128]), .bo0(sb[119:112]), .si1(state[119+128:112+128]), .si0(state[119:112]), .r(random_r[119:112]), .en(en[3:0]), .clk(clk_i));
   skinny_sbox8_dom1_non_pipelined sbox15 (.bo1(sb[127+128:120+128]), .bo0(sb[127:120]), .si1(state[127+128:120+128]), .si0(state[127:120]), .r(random_r[127:120]), .en(en[3:0]), .clk(clk_i));

   // Add Tweakey
   assign atk[127:0] = rkey[127:0] ^ sb[127:0];
   assign atk[255:128] = rkey[255:128] ^ sb[255:128];

   // ShiftRows
   assign shr[127:96] =  atk[127:96];
   assign shr[ 95:64] = {atk[ 71:64],atk[95:72]};
   assign shr[ 63:32] = {atk[ 47:32],atk[63:48]};
   assign shr[ 31: 0] = {atk[ 23: 0],atk[31:24]};

   assign shr[127+128:96+128] =  atk[127+128:96+128];
   assign shr[ 95+128:64+128] = {atk[ 71+128:64+128],atk[95+128:72+128]};
   assign shr[ 63+128:32+128] = {atk[ 47+128:32+128],atk[63+128:48+128]};
   assign shr[ 31+128: 0+128] = {atk[ 23+128: 0+128],atk[31+128:24+128]};
							  
   // MixColumn
   assign mxc[ 95:64] = shr[127:96];
   assign mxc[ 63:32] = shr[ 95:64] ^ shr[63:32];
   assign mxc[ 31: 0] = shr[127:96] ^ shr[63:32];
   assign mxc[127:96] = shr[ 31: 0] ^ mxc[31: 0];

   assign mxc[ 95+128:64+128] = shr[127+128:96+128];
   assign mxc[ 63+128:32+128] = shr[ 95+128:64+128] ^ shr[63+128:32+128];
   assign mxc[ 31+128: 0+128] = shr[127+128:96+128] ^ shr[63+128:32+128];
   assign mxc[127+128:96+128] = shr[ 31+128: 0+128] ^ mxc[31+128: 0+128]; 
   							    	   
endmodule // skinny_2shares_top

module key_expansion (/*AUTOARG*/
                      // Outputs
                      ko,
                      // Inputs
                      ki
                      ) ;
   output [127:0] ko;
   input [127:0]  ki;

   wire [127:0]   kp;

   assign kp[127:120] = ki[ 55: 48];
   assign kp[119:112] = ki[  7:  0];
   assign kp[111:104] = ki[ 63: 56];
   assign kp[103: 96] = ki[ 23: 16];
   assign kp[ 95: 88] = ki[ 47: 40];
   assign kp[ 87: 80] = ki[ 15:  8];
   assign kp[ 79: 72] = ki[ 31: 24];
   assign kp[ 71: 64] = ki[ 39: 32];
   assign kp[ 63: 56] = ki[127:120];
   assign kp[ 55: 48] = ki[119:112];
   assign kp[ 47: 40] = ki[111:104];
   assign kp[ 39: 32] = ki[103: 96];
   assign kp[ 31: 24] = ki[ 95: 88];
   assign kp[ 23: 16] = ki[ 87: 80];
   assign kp[ 15:  8] = ki[ 79: 72];
   assign kp[  7:  0] = ki[ 71: 64];

   assign ko[127:120] = {kp[120]^kp[126],kp[127:121]};
   assign ko[119:112] = {kp[112]^kp[118],kp[119:113]};
   assign ko[111:104] = {kp[104]^kp[110],kp[111:105]};
   assign ko[103: 96] = {kp[ 96]^kp[102],kp[103: 97]};
   assign ko[ 95: 88] = {kp[ 88]^kp[ 94],kp[ 95: 89]};
   assign ko[ 87: 80] = {kp[ 80]^kp[ 86],kp[ 87: 81]};
   assign ko[ 79: 72] = {kp[ 72]^kp[ 78],kp[ 79: 73]};
   assign ko[ 71: 64] = {kp[ 64]^kp[ 70],kp[ 71: 65]};

   assign ko[ 63:  0] = kp[ 63:  0];
   
endmodule // key_expansion

module tweak2_expansion (/*AUTOARG*/
                         // Outputs
                         ko,
                         // Inputs
                         ki
                         ) ;
   output [127:0] ko;
   input [127:0]  ki;

   wire [127:0]   kp;

   assign kp[127:120] = ki[ 55: 48];
   assign kp[119:112] = ki[  7:  0];
   assign kp[111:104] = ki[ 63: 56];
   assign kp[103: 96] = ki[ 23: 16];
   assign kp[ 95: 88] = ki[ 47: 40];
   assign kp[ 87: 80] = ki[ 15:  8];
   assign kp[ 79: 72] = ki[ 31: 24];
   assign kp[ 71: 64] = ki[ 39: 32];
   assign kp[ 63: 56] = ki[127:120];
   assign kp[ 55: 48] = ki[119:112];
   assign kp[ 47: 40] = ki[111:104];
   assign kp[ 39: 32] = ki[103: 96];
   assign kp[ 31: 24] = ki[ 95: 88];
   assign kp[ 23: 16] = ki[ 87: 80];
   assign kp[ 15:  8] = ki[ 79: 72];
   assign kp[  7:  0] = ki[ 71: 64];

   assign ko[127:120] = {kp[126:120],kp[127]^kp[125]};   
   assign ko[119:112] = {kp[118:112],kp[119]^kp[117]};   
   assign ko[111:104] = {kp[110:104],kp[111]^kp[109]};   
   assign ko[103: 96] = {kp[102: 96],kp[103]^kp[101]};   
   assign ko[ 95: 88] = {kp[ 94: 88],kp[ 95]^kp[ 93]};   
   assign ko[ 87: 80] = {kp[ 86: 80],kp[ 87]^kp[ 85]};   
   assign ko[ 79: 72] = {kp[ 78: 72],kp[ 79]^kp[ 77]};   
   assign ko[ 71: 64] = {kp[ 70: 64],kp[ 71]^kp[ 69]};   

   assign ko[ 63:  0] = kp[ 63:  0];
   
endmodule // tweak2_expansion

module tweak1_expansion (/*AUTOARG*/
                         // Outputs
                         ko,
                         // Inputs
                         ki
                         ) ;
   output [127:0] ko;
   input [127:0]  ki;

   wire [127:0]   kp;

   assign kp[127:120] = ki[ 55: 48];
   assign kp[119:112] = ki[  7:  0];
   assign kp[111:104] = ki[ 63: 56];
   assign kp[103: 96] = ki[ 23: 16];
   assign kp[ 95: 88] = ki[ 47: 40];
   assign kp[ 87: 80] = ki[ 15:  8];
   assign kp[ 79: 72] = ki[ 31: 24];
   assign kp[ 71: 64] = ki[ 39: 32];
   assign kp[ 63: 56] = ki[127:120];
   assign kp[ 55: 48] = ki[119:112];
   assign kp[ 47: 40] = ki[111:104];
   assign kp[ 39: 32] = ki[103: 96];
   assign kp[ 31: 24] = ki[ 95: 88];
   assign kp[ 23: 16] = ki[ 87: 80];
   assign kp[ 15:  8] = ki[ 79: 72];
   assign kp[  7:  0] = ki[ 71: 64];

   assign ko = kp;
   
endmodule // tweak1_expansion

