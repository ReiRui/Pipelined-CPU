module pipepc (d,e,clk,clrn,q,btn);
   input  [31:0] d;
   input  clk,clrn,e,btn;
   output [31:0] q;
   reg    [31:0] q;
   always @ (posedge clk)
      if (clrn == 0 || btn==0 ) 
				q <= -4;
		else		
			if (e == 1) q <= d;
			
endmodule
