/*
 Designer: Mustafa Khairallah
 Nanyang Technological University
 Singapore
 Date: July, 2021
 */

module skinny_sbox8_ti2_non_pipelined (/*AUTOARG*/);
   output [7:0] bo2;
   output [7:0] bo1;
   output [7:0] bo0;

   input [7:0] 	si2;
   input [7:0] 	si1;
   input [7:0] 	si0;
   input        clk;

   wire [2:0]	bi7;
   wire [2:0]	bi6;
   wire [2:0]	bi5;
   wire [2:0]	bi4;
   wire [2:0]	bi3;
   wire [2:0]	bi2;
   wire [2:0]	bi1;
   wire [2:0]	bi0;

   wire [2:0]	a7;
   wire [2:0]	a6;
   wire [2:0]	a5;
   wire [2:0]	a4;
   wire [2:0]	a3;
   wire [2:0]	a2;
   wire [2:0]	a1;
   wire [2:0]	a0;
 
   assign bi0 = {si2[0],si1[0],si0[0]};
   assign bi1 = {si2[1],si1[1],si0[1]};
   assign bi2 = {si2[2],si1[2],si0[2]};
   assign bi3 = {si2[3],si1[3],si0[3]};
   assign bi4 = {si2[4],si1[4],si0[4]};
   assign bi5 = {si2[5],si1[5],si0[5]};
   assign bi6 = {si2[6],si1[6],si0[6]};
   assign bi7 = {si2[7],si1[7],si0[7]};

   ti2_sbox8_cfn_fr b764 (a0,bi7,bi6,bi4,clk);
   ti2_sbox8_cfn_fr b320 (a1,bi3,bi2,bi0,clk);
   ti2_sbox8_cfn_fr b216 (a2,bi2,bi1,bi6,clk);
   ti2_sbox8_cfn_fr b015 (a3,a0, a1, bi5,clk);
   ti2_sbox8_cfn_fr b131 (a4,a1, bi3,bi1,clk);
   ti2_sbox8_cfn_fr b237 (a5,a2, a3, bi7,clk);
   ti2_sbox8_cfn_fr b303 (a6,a3, a0, bi3,clk);
   ti2_sbox8_cfn_fr b422 (a7,a4, a5, bi2,clk);

   assign {bo2[6],bo1[6],bo0[6]} = a0;
   assign {bo2[5],bo1[5],bo0[5]} = a1;
   assign {bo2[2],bo1[2],bo0[2]} = a2;
   assign {bo2[7],bo1[7],bo0[7]} = a3;
   assign {bo2[3],bo1[3],bo0[3]} = a4;
   assign {bo2[1],bo1[1],bo0[1]} = a5;
   assign {bo2[4],bo1[4],bo0[4]} = a6;
   assign {bo2[0],bo1[0],bo0[0]} = a7;	 
endmodule // skinny_sbox8_ti2_non_pipelined

module ti2_sbox8_cfn_fr (/*AUTOARG*/
   // Outputs
   f,
   // Inputs
   a, b, z, r, clk
   ) ;
   output [2:0]        f;
   input [2:0]         a, b, z;
   input 	       clk;

   wire [2:0] 	       x;
   wire [2:0] 	       y;
   
   reg [2:0] 	       rg;

   assign x = {a[2:1],~a[0]};
   assign y = {b[2:1],~b[0]};
   
   always @ (*) begin      
      
      rg[0] <= (x[1] & y[1]) ^ (x[1] & y[2]) ^ (x[2] & y[1]) ^ z[0];      
      rg[1] <= (x[2] & y[2]) ^ (x[0] & y[2]) ^ (x[2] & y[0]) ^ z[1];
      rg[2] <= (x[0] & y[0]) ^ (x[0] & y[1]) ^ (x[1] & y[0]) ^ z[2];      

   end // always @ (posedge clk)

   assign f[0] = rg[0];
   assign f[1] = rg[1];
   assign f[2] = rg[2];

endmodule // ti2_sbox8_cfn_fr
