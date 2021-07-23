/*
 Designer: Mustafa Khairallah
 Nanyang Technological University
 Singapore
 Date: July, 2021
 */

module golden_domd_np_2 ();
   parameter d = 2;
   
   wire [7:0] so_lut;
   wire [23:0] so_dom1_0;
   wire [7:0]  so_dom1;
   
   reg [7:0]   si;
   reg [23:0]  si_0;
   reg [23:0]  r;
   reg [7:0]   msk0, msk1;
   
   reg         clk;   

   reg [8:0]   i;
   reg         success;   

   assign so_dom1 = so_dom1_0[7:0] ^ so_dom1_0[15:8] ^ so_dom1_0[23:16];   
   skinny_sbox8_lut                     golden (so_lut,    si);
   skinny_sbox8_domd_non_pipelined #(d) uut    (so_dom1_0, si_0, r, clk);

   initial begin
      clk <= 1;
      forever begin
         #1;
         clk <= ~clk;
      end
   end 
   
   initial begin
      success <= 1;      
      for (i = 0; i < 256; i = i + 1) begin
         si   <= i[7:0];
         msk0  <= ($random()%256);
         msk1  <= ($random()%256);
         si_0[ 7:0]  <= i[7:0]^msk0^msk1;
         si_0[15:8]  <= msk0;
         si_0[23:16] <= msk1;    
         r    <= ($random());
         @(posedge clk);
         @(posedge clk);
         @(posedge clk);
         @(posedge clk);
         @(negedge clk);
         if (so_lut != so_dom1) begin
            $display("Error @ %2h, %2h, %2h", si, so_lut, so_dom1);  
            success <= 0;           
         end
      end
      if (success) begin
         $display("Successful test!!");  
      end
      else begin
         $display("Failed test!!");      
      end
      $finish;      
   end
   
endmodule // golden_dom1_np

