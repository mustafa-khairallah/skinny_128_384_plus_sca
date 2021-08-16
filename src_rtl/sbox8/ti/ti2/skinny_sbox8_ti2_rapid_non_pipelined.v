

module ti2_rapid_a3 (/*AUTOARG*/
   // Outputs
   a3,
   // Inputs
   nb7, nb6, b5, nb4, nb3, nb2, nb0, r, clk
   ) ;
   output [1:0] a3;
   input [1:0] 	nb7, nb6, b5, nb4, nb3, nb2, nb0;
   input [21:0] r;   
   input 	clk;

   wire [1:0] 	t0;
   wire [1:0] 	t1;
   wire [1:0] 	t2;
   wire [1:0] 	t3;   

   and4_ti2 g0 (t0,nb7,nb6,nb3,nb2,r[ 8: 0],clk);
   and3_ti2 g1 (t1,nb7,nb6,nb0,	   r[13: 9],clk);
   and3_ti2 g2 (t2,nb4,nb3,nb2,	   r[18:14],clk);
   and2_ti2 g3 (t3,nb4,nb0,	   r[21:19],   clk);
   
   assign a3 = t0 ^ t1 ^ t2 ^ t3 ^ b5;
   
endmodule // ti2_rapid_a3

module ti2_rapid_a4 (/*AUTOARG*/
   // Outputs
   a4,
   // Inputs
   nb3, nb2, b1, nb0, r, clk
   ) ;
   output [1:0] a4;
   input [5:0] 	nb3, nb2, b1, nb0;
   input [5:0] 	r;   
   input 	clk;

   wire [1:0] 	t0;
   wire [1:0] 	t1;

   and2_dom1 g0 (t0,nb3,nb2,r[2:0],clk);
   and2_dom1 g1 (t1,nb0,nb3,r[5:3],clk);
   
   assign a4 = t0 ^ t1 ^ b1;
   
endmodule // ti2_rapid_a4

module ti2_rapid_a7 (/*AUTOARG*/
   // Outputs
   a7,
   // Inputs
   nb7, na4, na3, na2, b2, r, clk
   ) ;
   output [1:0] a7;
   input [1:0] 	nb7, na4, na3, na2, b2;
   input [7:0] r;   
   input 	clk;

   wire [1:0] 	t0;
   wire [1:0] 	t1;

   and3_dom1 g0 (t0,na2,na3,na4,r[4:0],clk);
   and2_dom1 g1 (t1,nb7,na4,    r[7:5],  clk);
   
   assign a7 = t0 ^ t1 ^ b2;
   
endmodule // ti2_rapid_a7

module and4_ti2 (/*AUTOARG*/
   // Outputs
   f,
   // Inputs
   a, b, c, d, r, clk
   ) ;
   output [2:0] f;
   
   input [2:0] 	a, b, c, d;
   input [8:0] 	r;
   input 	clk;

   reg [8:0] 	z;

   always @ (posedge clk) begin
      z[0] <= (a[0]&b[0]&c[0]&d[0]) ^
	      (a[0]&b[0]&c[0]&d[1]) ^
	      (a[0]&b[0]&c[1]&d[0]) ^
	      (a[0]&b[0]&c[1]&d[1]) ^
	      (a[0]&b[1]&c[0]&d[0]) ^
	      (a[0]&b[1]&c[0]&d[1]) ^
	      (a[0]&b[1]&c[1]&d[0]) ^
	      (a[0]&b[1]&c[1]&d[1]) ^
	      (a[1]&b[0]&c[0]&d[0]) ^
	      (a[1]&b[0]&c[0]&d[1]) ^
	      (a[1]&b[0]&c[1]&d[0]) ^
	      (a[1]&b[0]&c[1]&d[1]) ^
	      (a[1]&b[1]&c[0]&d[0]) ^
	      (a[1]&b[1]&c[0]&d[1]) ^
	      (a[1]&b[1]&c[1]&d[0]) ^
	      (a[1]&b[1]&c[1]&d[1]) ^ r[0] ^ r[1];
      z[1] <= (a[0]&b[0]&c[0]&d[2]) ^
	      (a[0]&b[0]&c[2]&d[0]) ^
	      (a[0]&b[0]&c[2]&d[2]) ^
	      (a[0]&b[2]&c[0]&d[0]) ^
	      (a[0]&b[2]&c[0]&d[2]) ^
	      (a[0]&b[2]&c[2]&d[0]) ^
	      (a[0]&b[2]&c[2]&d[2]) ^
	      (a[2]&b[0]&c[0]&d[0]) ^
	      (a[2]&b[0]&c[0]&d[2]) ^
	      (a[2]&b[0]&c[2]&d[0]) ^
	      (a[2]&b[0]&c[2]&d[2]) ^
	      (a[2]&b[2]&c[0]&d[0]) ^
	      (a[2]&b[2]&c[0]&d[2]) ^
	      (a[2]&b[2]&c[2]&d[0]) ^
	      (a[2]&b[2]&c[2]&d[2]) ^ r[1] ^ r[2];
      z[2] <= (a[1]&b[1]&c[1]&d[2]) ^
	      (a[1]&b[1]&c[2]&d[1]) ^
	      (a[1]&b[1]&c[2]&d[2]) ^
	      (a[1]&b[2]&c[1]&d[1]) ^
	      (a[1]&b[2]&c[1]&d[2]) ^
	      (a[1]&b[2]&c[2]&d[1]) ^
	      (a[1]&b[2]&c[2]&d[2]) ^
	      (a[2]&b[1]&c[1]&d[1]) ^
	      (a[2]&b[1]&c[1]&d[2]) ^
	      (a[2]&b[1]&c[2]&d[1]) ^
	      (a[2]&b[1]&c[2]&d[2]) ^
	      (a[2]&b[2]&c[1]&d[1]) ^
	      (a[2]&b[2]&c[1]&d[2]) ^
	      (a[2]&b[2]&c[2]&d[1]) ^ r[2] ^ r[3];      
      z[3] <= (a[0]&b[0]&c[1]&d[2]) ^
	      (a[0]&b[0]&c[2]&d[1]) ^
	      (a[0]&b[1]&c[1]&d[2]) ^
	      (a[0]&b[1]&c[2]&d[1]) ^
	      (a[0]&b[1]&c[2]&d[2]) ^
	      (a[1]&b[0]&c[2]&d[2]) ^
	      (a[1]&b[0]&c[2]&d[1]) ^
	      (a[1]&b[0]&c[2]&d[2]) ^ r[3] ^ r[4];
      z[4] <= (a[0]&b[1]&c[0]&d[2]) ^
	      (a[0]&b[1]&c[2]&d[0]) ^
	      (a[0]&b[2]&c[2]&d[2]) ^
	      (a[1]&b[1]&c[0]&d[2]) ^
	      (a[1]&b[1]&c[2]&d[0]) ^
	      (a[1]&b[2]&c[0]&d[0]) ^
	      (a[1]&b[2]&c[0]&d[2]) ^
	      (a[1]&b[2]&c[2]&d[0]) ^ r[4] ^ r[5];
      z[5] <= (a[0]&b[2]&c[0]&d[1]) ^
	      (a[0]&b[2]&c[1]&d[0]) ^
	      (a[0]&b[2]&c[1]&d[1]) ^
	      (a[2]&b[0]&c[0]&d[1]) ^
	      (a[2]&b[0]&c[1]&d[0]) ^
	      (a[2]&b[0]&c[1]&d[1]) ^
	      (a[2]&b[2]&c[0]&d[1]) ^
	      (a[2]&b[2]&c[1]&d[0]) ^ r[5] ^ r[6];
      z[6] <= (a[0]&b[2]&c[1]&d[2]) ^
	      (a[0]&b[2]&c[1]&d[2]) ^
	      (a[2]&b[0]&c[1]&d[2]) ^
	      (a[2]&b[0]&c[2]&d[1]) ^ r[6] ^ r[7];
      z[7] <= (a[1]&b[0]&c[0]&d[2]) ^
	      (a[1]&b[0]&c[2]&d[0]) ^
	      (a[2]&b[1]&c[0]&d[0]) ^
	      (a[2]&b[1]&c[0]&d[2]) ^
	      (a[2]&b[1]&c[2]&d[0]) ^ r[7] ^ r[8];
      z[8] <= (a[1]&b[2]&c[0]&d[1]) ^
	      (a[1]&b[2]&c[1]&d[0]) ^
	      (a[2]&b[1]&c[0]&d[1]) ^
	      (a[2]&b[1]&c[1]&d[0]) ^ r[8] ^ r[0];
   end // always @ (posedge clk)
   
   assign f[0] = z[0] ^ z[1] ^ z[2];
   assign f[1] = z[3] ^ z[4] ^ z[5];
   assign f[2] = z[6] ^ z[7] ^ z[8];
   
endmodule // and4_ti2

module and3_ti2 (/*AUTOARG*/
   // Outputs
   f,
   // Inputs
   a, b, c, r, clk
   ) ;
   output [2:0] f;
   
   input [2:0] 	a, b, c;
   input [4:0] 	r;
   input 	clk;

   reg [4:0] 	z;

   always @ (posedge clk) begin
      z[0] <= (a[0]&b[0]&c[0]) ^
	      (a[0]&b[0]&c[1]) ^
	      (a[0]&b[1]&c[0]) ^
	      (a[0]&b[1]&c[1]) ^
	      (a[1]&b[0]&c[0]) ^
	      (a[1]&b[0]&c[1]) ^
	      (a[1]&b[1]&c[0]) ^
	      (a[1]&b[1]&c[1]) ^ r[0] ^ r[1];
      z[1] <= (a[0]&b[0]&c[2]) ^
	      (a[0]&b[2]&c[0]) ^
	      (a[0]&b[2]&c[2]) ^
	      (a[2]&b[0]&c[0]) ^
	      (a[2]&b[0]&c[2]) ^
	      (a[2]&b[2]&c[0]) ^
	      (a[2]&b[2]&c[2]) ^ r[1] ^ r[2];
      z[2] <= (a[0]&b[1]&c[2]) ^
	      (a[0]&b[2]&c[1]) ^
	      (a[1]&b[1]&c[2]) ^
	      (a[1]&b[2]&c[1]) ^
	      (a[1]&b[2]&c[2]) ^ r[2] ^ r[3];
      z[3] <= (a[1]&b[0]&c[2]) ^
	      (a[2]&b[0]&c[1]) ^
	      (a[2]&b[1]&c[1]) ^
	      (a[2]&b[1]&c[2]) ^ r[3] ^ r[4];
      z[4] <= (a[1]&b[2]&c[0]) ^
	      (a[2]&b[1]&c[0]) ^
	      (a[2]&b[2]&c[1]) ^ r[4] ^ r[0];
   end // always @ (posedge clk)

   assign f[0] = z[0];
   assign f[1] = z[1] ^ z[2];
   assign f[2] = z[3] ^ z[4];
   
endmodule // and3_ti2

module and2_ti2 (/*AUTOARG*/
   // Outputs
   f,
   // Inputs
   a, b, r, clk
   ) ;
   output reg [2:0] f;
   
   input [2:0] 	    a, b;
   input [2:0] 	    r;
   input 	    clk;
   
   always @ (posedge clk) begin
      f[0] <= (a[1] & b[1]) ^ (a[1] & b[2]) ^ (a[2] & b[1]) ^ r[0] ^ r[1];	
      f[1] <= (a[2] & b[2]) ^ (a[0] & b[2]) ^ (a[2] & b[0]) ^ r[1] ^ r[2];	
      f[2] <= (a[0] & b[0]) ^ (a[0] & b[1]) ^ (a[1] & b[0]) ^ r[2] ^ r[0];   
   end
   
endmodule // and2_ti2


module ti2_reshare_sbox8_cfn_fr (/*AUTOARG*/
   // Outputs
   f,
   // Inputs
   a, b, z, r, clk
   ) ;
   output [2:0]        f;
   input [2:0]         a, b, z;
   input [2:0] 	       r;
   input 	       clk;

   wire [2:0] 	       x;
   wire [2:0] 	       y;
   
   reg [2:0] 	       rg;

   assign x = {a[2:1],~a[0]};
   assign y = {b[2:1],~b[0]};
   
   always @ (posedge clk) begin      
      
      rg[0] <= (x[1] & y[1]) ^ (x[1] & y[2]) ^ (x[2] & y[1]) ^ z[0] ^ r[0] ^ r[1];      
      rg[1] <= (x[2] & y[2]) ^ (x[0] & y[2]) ^ (x[2] & y[0]) ^ z[1] ^ r[1] ^ r[2];      
      rg[2] <= (x[0] & y[0]) ^ (x[0] & y[1]) ^ (x[1] & y[0]) ^ z[2] ^ r[2] ^ r[0];      

   end // always @ (posedge clk)

   assign f[0] = rg[0];
   assign f[1] = rg[1];
   assign f[2] = rg[2];

endmodule // ti2_sbox8_cfn_fr
