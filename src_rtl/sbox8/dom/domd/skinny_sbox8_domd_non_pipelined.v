/*
 Designer: Mustafa Khairallah
 Nanyang Technological University
 Singapore
 Date: July, 2021
 */

// The d+1 share DOM-Indep multiplier based sbox8
// with registered shares. Generalization of
// skinny_sbox8_dom1_non_pipelined.v (see ../dom1/).
module skinny_sbox8_domd_non_pipelined (/*AUTOARG*/
                                        // Outputs
                                        so,
                                        // Inputs
                                        si, r, clk
                                        ) ;
   parameter d = 2;
   
   output [8*d+7:0] so;

   input [8*d+7:0]  si;
   input [8*d*(d+1)/2-1:0] r;
   input                   clk;

   wire [d:0]              bi [7:0];
   wire [d:0]              bo [7:0];
   wire [d:0]              a  [7:0];

   genvar                  i, j;

   generate
      for (i = 0; i < 8; i = i + 1) begin : pack_output
         for (j = 0; j < d+1; j = j + 1) begin : pack_internal 
            assign bi[i][j] = si[8*j+i];
         end
      end
   endgenerate

   domd_sbox8_cfn_fr #(d) b764 (a[0],bi[7],bi[6],bi[4],r[1*d*(d+1)/2-1:0*d*(d+1)/2],clk);
   domd_sbox8_cfn_fr #(d) b320 (a[1],bi[3],bi[2],bi[0],r[2*d*(d+1)/2-1:1*d*(d+1)/2],clk);
   domd_sbox8_cfn_fr #(d) b216 (a[2],bi[2],bi[1],bi[6],r[3*d*(d+1)/2-1:2*d*(d+1)/2],clk);
   domd_sbox8_cfn_fr #(d) b015 (a[3],a [0],a [1],bi[5],r[4*d*(d+1)/2-1:3*d*(d+1)/2],clk);
   domd_sbox8_cfn_fr #(d) b131 (a[4],a [1],bi[3],bi[1],r[5*d*(d+1)/2-1:4*d*(d+1)/2],clk);
   domd_sbox8_cfn_fr #(d) b237 (a[5],a [2],a [3],bi[7],r[6*d*(d+1)/2-1:5*d*(d+1)/2],clk);
   domd_sbox8_cfn_fr #(d) b303 (a[6],a [3],a [0],bi[3],r[7*d*(d+1)/2-1:6*d*(d+1)/2],clk);
   domd_sbox8_cfn_fr #(d) b422 (a[7],a [4],a [5],bi[2],r[8*d*(d+1)/2-1:7*d*(d+1)/2],clk);

   assign bo[6] = a[0];
   assign bo[5] = a[1];
   assign bo[2] = a[2];
   assign bo[7] = a[3];
   assign bo[3] = a[4];
   assign bo[1] = a[5];
   assign bo[4] = a[6];
   assign bo[0] = a[7];

   generate
      for (i = 0; i < 8; i = i + 1) begin : unpack_input
         for (j = 0; j < d+1; j = j + 1) begin : unpack_internal 
            assign so[8*j+i] = bo[i][j];
         end
      end
   endgenerate
   
endmodule // domd_sbox8


// The core registered function of the skinny sbox8.
// fr: fully registered, all and operations are
// registered.
// cfn: core function
// The core function is basically (x nor y) xor z
// We use de morgan's law to convert it to:
// ((~x) and (~y)) xor z and use the DOM-Indep
// multiplier for the and gate. We add the shares of
// z to the independent and gates and register the
// output of (a and b) xor c, while for the mixed
// shares we also use (a and b) xor c, but c is the
// fresh randomness.
// d is the protection order, where each value has
// (d+1) shares.
module domd_sbox8_cfn_fr (/*AUTOARG*/
                          // Outputs
                          f,
                          // Inputs
                          a, b, z, r, clk
                          ) ;
   parameter d = 1;
   
   output [d:0]          f;
   input [d:0]           a, b, z;
   input [d*(d+1)/2-1:0] r;   
   input                 clk;

   genvar                i,j;   

   reg [d:0]             g [d:0];
   wire [d:0]            x,y;

   assign x = {a[d:1],~a[0]};
   assign y = {b[d:1],~b[0]};

   generate
      for (i = 0; i <= d; i = i + 1) begin : nl_shares_matrix_out
         for (j = 0; j <= d; j = j + 1) begin : nl_shares_matrix_in
            always @ (posedge clk) begin
               if (i == j) begin
                  g[i][j] <= (x[i] & y[j]) ^ z[i];
               end
               else if (j > i) begin
                  g[i][j] <= (x[i] & y[j]) ^ r[i+j*(j-1)/2];
               end
               else begin
                  g[i][j] <= (x[i] & y[j]) ^ r[j+i*(i-1)/2];
               end
            end // always @ (posedge clk)
         end // for (j = 0; j <= d; j = j + 1)   
      end // for (i = 0; i <= d; i = i + 1)      
   endgenerate

   generate
      for (i = 0; i <= d; i = i + 1) begin : integration
         assign f[i] = ^g[i];    
      end
   endgenerate
   
endmodule // domd_sbox8_cfn_fr
