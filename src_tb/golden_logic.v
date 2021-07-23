/*
 Designer: Mustafa Khairallah
 Nanyang Technological University
 Singapore
 Date: July, 2021
 */

module golden_logic ();

   wire [7:0] so_lut;
   wire [7:0] so_logic;

   reg [7:0]  si;

   reg [8:0]  i;
   reg        success;   

   skinny_sbox8_lut   golden (so_lut,   si);
   skinny_sbox8_logic uut    (so_logic, si);
   
   initial begin
      success <= 1;      
      for (i = 0; i < 256; i = i + 1) begin
         si <= i[7:0];   
         #1;
         if (so_lut != so_logic) begin
            $display("Error @ %2h, %2h", si, so_lut);  
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
   
endmodule // golden_logic
