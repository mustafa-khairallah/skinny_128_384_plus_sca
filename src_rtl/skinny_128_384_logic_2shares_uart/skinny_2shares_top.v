module skinny_2shares_top (/*AUTOARG*/
                   // Outputs
                   cipher_o, done_o,
                   // Inputs
                   input_i, key_i, tweak1_i, tweak2_i, clk_i, rst_i, start_i
                   ) ;
   parameter rpsb = 8;   
   
   output [255:0] cipher_o;
   output reg     done_o;

   reg [1215:0] random_i;
   input [255:0]  input_i, key_i, tweak1_i, tweak2_i;
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

   wire [255:0]   sb, atk, shr, mxc, rkey; 

   assign cipher_o = state;
   
   always @ (posedge clk_i) begin
      if (!rst_i) begin
         done_o <= 1;
         constant <= 6'h01;
      end
      else if (start_i) begin
         constant <= 6'h01;
         state <= input_i;
	 random_r <= random_i;	 
         key <= key_i;
         tweak1 <= tweak1_i;
         tweak2 <= tweak2_i;     
         done_o <= 0;    
      end
      else if (done_o == 0) begin
         constant <= {constant[4:0],constant[5]^constant[4]^1'b1};
         state <= mxc;
         key <= next_key;
         tweak1 <= next_tweak1;
         tweak2 <= next_tweak2;
         if (constant == 6'h1a) begin
            done_o <= 1;            
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
   skinny_sbox8_logic sbox00 (.so(sb[  7:  0]), .si(state[  7:  0]));
   skinny_sbox8_logic sbox01 (.so(sb[ 15:  8]), .si(state[ 15:  8]));
   skinny_sbox8_logic sbox02 (.so(sb[ 23: 16]), .si(state[ 23: 16]));
   skinny_sbox8_logic sbox03 (.so(sb[ 31: 24]), .si(state[ 31: 24]));
   skinny_sbox8_logic sbox04 (.so(sb[ 39: 32]), .si(state[ 39: 32]));
   skinny_sbox8_logic sbox05 (.so(sb[ 47: 40]), .si(state[ 47: 40]));
   skinny_sbox8_logic sbox06 (.so(sb[ 55: 48]), .si(state[ 55: 48]));
   skinny_sbox8_logic sbox07 (.so(sb[ 63: 56]), .si(state[ 63: 56]));
   skinny_sbox8_logic sbox08 (.so(sb[ 71: 64]), .si(state[ 71: 64]));
   skinny_sbox8_logic sbox09 (.so(sb[ 79: 72]), .si(state[ 79: 72]));
   skinny_sbox8_logic sbox10 (.so(sb[ 87: 80]), .si(state[ 87: 80]));
   skinny_sbox8_logic sbox11 (.so(sb[ 95: 88]), .si(state[ 95: 88]));
   skinny_sbox8_logic sbox12 (.so(sb[103: 96]), .si(state[103: 96]));
   skinny_sbox8_logic sbox13 (.so(sb[111:104]), .si(state[111:104]));
   skinny_sbox8_logic sbox14 (.so(sb[119:112]), .si(state[119:112]));
   skinny_sbox8_logic sbox15 (.so(sb[127:120]), .si(state[127:120]));

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
module skinny_sbox8_logic (
                           // Outputs
                           so,
                           // Inputs
                           si
                           ) ;
   output [7:0] so;
   input [7:0]  si;

   wire [7:0]   a;

   skinny_sbox8_cfn b764 (a[0],si[7],si[6],si[4]);
   skinny_sbox8_cfn b320 (a[1],si[3],si[2],si[0]);
   skinny_sbox8_cfn b216 (a[2],si[2],si[1],si[6]);
   skinny_sbox8_cfn b015 (a[3], a[0], a[1],si[5]);
   skinny_sbox8_cfn b131 (a[4], a[1],si[3],si[1]);
   skinny_sbox8_cfn b237 (a[5], a[2], a[3],si[7]);
   skinny_sbox8_cfn b303 (a[6], a[3], a[0],si[3]);
   skinny_sbox8_cfn b452 (a[7], a[4], a[5],si[2]);

   assign so[6] = a[0];
   assign so[5] = a[1];
   assign so[2] = a[2];
   assign so[7] = a[3];
   assign so[3] = a[4];
   assign so[1] = a[5];
   assign so[4] = a[6];
   assign so[0] = a[7];
   
endmodule // skinny_sbox8

// The core repeated function (x nor y) xor z
module skinny_sbox8_cfn (
                         // Outputs
                         f,
                         // Inputs
                         x, y, z
                         ) ;
   output f;
   input  x, y, z;

   assign f = ((~x) & (~y)) ^ z;
   
endmodule // skinny_sbox8_cfn
