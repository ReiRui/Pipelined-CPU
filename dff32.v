module dff32 (d,clk,clrn,q,btn);
   input  [31:0] d;
   input         clk,clrn,btn;
   output [31:0] q;
   reg [31:0]    q;
   always @ (negedge clrn or posedge clk or negedge btn)
	begin	 
      if ((clrn == 0) ||(btn == 0))
          q <= -4;
       else
          q <= d; 
	end

	endmodule