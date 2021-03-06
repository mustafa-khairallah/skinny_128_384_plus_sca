/*
 Designer: Mustafa Khairallah
 Nanyang Technological University
 Singapore
 Date: July, 2021
 */

// The ISW gadget based sbox8 with registered shares.
// Takes 8 cycles. Non-pipelined, so the input
// must remain stable for 8 cycles, including the 
// refreshing mask r.

module skinny_sbox8_hpc2_1_str_non_pipelined (/*AUTOARG*/
   // Outputs
   bo1, bo0,
   // Inputs
   si1, si0, r, clk
   ) ;
   output [7:0] bo1; // share 1
   output [7:0] bo0; // share 0

   input [7:0] 	si1; // share 1
   input [7:0] 	si0; // share 0
   input [15:0]  r;   // refreshing mask
   input        clk;

   wire [1:0]   bi7;
   wire [1:0]   bi6;
   wire [1:0]   bi5;
   wire [1:0]   bi4;
   wire [1:0]   bi3;
   wire [1:0]   bi2;
   wire [1:0]   bi1;
   wire [1:0]   bi0;

   wire [1:0]   a7;
   wire [1:0]   a6;
   wire [1:0]   a5;
   wire [1:0]   a4;
   wire [1:0]   a3;
   wire [1:0]   a2;
   wire [1:0]   a1;
   wire [1:0]   a0;
 
   assign bi0 = {si1[0],si0[0]};
   assign bi1 = {si1[1],si0[1]};
   assign bi2 = {si1[2],si0[2]};
   assign bi3 = {si1[3],si0[3]};
   assign bi4 = {si1[4],si0[4]};
   assign bi5 = {si1[5],si0[5]};
   assign bi6 = {si1[6],si0[6]};
   assign bi7 = {si1[7],si0[7]};

   hpc2_1_str_sbox8_cfn_fr b764 (a0,bi7,bi6,bi4,r[ 1: 0],clk);
   hpc2_1_str_sbox8_cfn_fr b320 (a1,bi3,bi2,bi0,r[ 3: 2],clk);
   hpc2_1_str_sbox8_cfn_fr b216 (a2,bi2,bi1,bi6,r[ 5: 4],clk);
   hpc2_1_str_sbox8_cfn_fr b015 (a3,a0, a1, bi5,r[ 7: 6],clk);
   hpc2_1_str_sbox8_cfn_fr b131 (a4,a1, bi3,bi1,r[ 9: 8],clk);
   hpc2_1_str_sbox8_cfn_fr b237 (a5,a2, a3, bi7,r[11:10],clk);
   hpc2_1_str_sbox8_cfn_fr b303 (a6,a3, a0, bi3,r[13:12],clk);
   hpc2_1_str_sbox8_cfn_fr b422 (a7,a4, a5, bi2,r[15:14],clk);

   assign {bo1[6],bo0[6]} = a0;
   assign {bo1[5],bo0[5]} = a1;
   assign {bo1[2],bo0[2]} = a2;
   assign {bo1[7],bo0[7]} = a3;
   assign {bo1[3],bo0[3]} = a4;
   assign {bo1[1],bo0[1]} = a5;
   assign {bo1[4],bo0[4]} = a6;
   assign {bo1[0],bo0[0]} = a7;
   
endmodule // skinny_sbox8_hpc2_1_str_non_pipelined

// The core registered function of the skinny sbox8.
// fr: fully registered, all and operations are
// registered.
// cfn: core function
// The core function is basically (x nor y) xor z
// We use de morgan's law to convert it to:
// ((~x) and (~y)) xor z and use the ISW
// multiplier for the and gate. The is enforced by
// the idea from Knichel et al. to refresh one of
// the inputs to the multiplier.
// The core registered function of the skinny sbox8.
// fr: fully registered, all and operations are
// registered.
// cfn: core function
// The core function is basically (x nor y) xor z
// We use de morgan's law to convert it to:
// ((~x) and (~y)) xor z and use the ISW
// multiplier for the and gate.

module hpc2_1_str_sbox8_cfn_fr (/*AUTOARG*/
   // Outputs
   f,
   // Inputs
   a, b, z, r, clk
   ) ;
   output [1:0]        f;
   input [1:0]         a, b, z;
   input [1:0]	       r;
   input 	       clk;

   wire [1:0] 	       x;
   reg [1:0] 	       y;
   
   reg [7:0] 	       rg;

   assign x = {a[1],~a[0]};
   
   always @ (posedge clk) begin
      y <= {b[1],~b[0]} ^ {r[1],r[1]}; 
      
      rg[0] <= y[0];
      rg[1] <= x[0] & rg[0];
      rg[2] <= r[0] & ~x[0];
      rg[3] <= x[0] & (y[1]^r[0]);

      rg[4] <= y[1];
      rg[5] <= x[1] & rg[4];
      rg[6] <= r[0] & ~x[1];
      rg[7] <= x[1] & (y[0]^r[0]);                 
   end // always @ (posedge clk)

   assign f[0] = ^rg[3:1] ^ z[0];
   assign f[1] = ^rg[7:5] ^ z[1]; 

endmodule // hpc2_1_str_sbox8_cfn_fr


