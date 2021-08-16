/*
 Designer: Mustafa Khairallah
 Nanyang Technological University
 Singapore
 Date: July, 2021
 */

module golden_cms1_rapid_np ();

   wire [7:0] so_lut;
   wire [7:0] so_dom1_0;
   wire [7:0] so_dom1_1;
   wire [7:0] so_dom1;
   
   reg [7:0]  si;
   reg [7:0]  si_0;
   reg [7:0]  si_1;
   reg [75:0]  r;
   reg [7:0]  msk;
   
   reg        clk;   

   reg [8:0]  i;
   reg        success;   

   assign so_dom1 = so_dom1_0 ^ so_dom1_1;   
   skinny_sbox8_lut                      golden (so_lut,                si);
   skinny_sbox8_cms1_rapid_non_pipelined uut    (so_dom1_1,  so_dom1_0, si_1, si_0, r, clk);

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
         msk  <= ($random()%33554432);
         si_0 <= i[7:0]^msk;
         si_1 <= msk;
         r    <= {$random(),$random(),$random()};	 
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

