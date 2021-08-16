/*
 Designer: Mustafa Khairallah
 Nanyang Technological University
 Singapore
 Date: July, 2021
 */

// This file represents one round of the Skinny cipher
// applied on 32 bits, also known as superbox.
//

module skinny_superbox32_dom1_non_pipelined (/*AUTOARG*/
   // Outputs
   so1, so0,
   // Inputs
   si1, si0, k1, k0, r, clk
   );
   output [31:0] so1, so0;
   input [31:0]  si1, si0;
   input [15:0]  k1, k0;
   input [31:0]  r;
   input 	 clk;

   wire [31:0]	sbi0, sbi1;
   wire [31:0]	 sbo0, sbo1;
   wire [31:0]	 mxc0, mxc1;
   wire [31:0]	 atk0, atk1;

   assign sbi0 = si0;
   assign sbi1 = si1;
   
   skinny_sbox8_dom1_non_pipelined sbox0 (sbo1[ 7: 0],sbo0[ 7: 0],sbi1[ 7: 0],sbi0[ 7: 0],r[ 7: 0],clk);
   skinny_sbox8_dom1_non_pipelined sbox1 (sbo1[15: 8],sbo0[15: 8],sbi1[15: 8],sbi0[15: 8],r[15: 8],clk);
   skinny_sbox8_dom1_non_pipelined sbox2 (sbo1[23:16],sbo0[23:16],sbi1[23:16],sbi0[23:16],r[23:16],clk);
   skinny_sbox8_dom1_non_pipelined sbox3 (sbo1[31:24],sbo0[31:24],sbi1[31:24],sbi0[31:24],r[31:24],clk);

   assign atk1 = {k1 ^ sbo1[31:16],sbo1[15:0]};
   assign atk0 = {k0 ^ sbo0[31:16],sbo0[15:0]};

   assign mxc1[23:16] = atk1[31:24];
   assign mxc1[15: 8] = atk1[23:16] ^ atk1[15: 8];
   assign mxc1[ 7: 0] = atk1[31:24] ^ atk1[15: 8];
   assign mxc1[31:24] = atk1[ 7: 0] ^ mxc1[ 7: 0]; 
   
   assign mxc0[23:16] = atk0[31:24];
   assign mxc0[15: 8] = atk0[23:16] ^ atk0[15: 8];
   assign mxc0[ 7: 0] = atk0[31:24] ^ atk0[15: 8];
   assign mxc0[31:24] = atk0[ 7: 0] ^ mxc0[ 7: 0];

   assign so1 = mxc1;
   assign so0 = mxc0;   
   
endmodule // skinny_supberbox32_dom1_non_pipelined

					     
