module pipeir (pc4,ins,wpcir,clock,resetn,dpc4,inst);
	input [31:0] pc4,ins;
	input wpcir,clock,resetn;
	output [31:0] dpc4,inst;
	
	reg [31:0] reg_pc4,reg_ins;
	assign dpc4 = reg_pc4;
	assign inst = reg_ins;
	always@(posedge clock)
		begin
			if (resetn==0)
				begin
					reg_ins<=32'h0;
					reg_pc4<=32'h0;
				end
				
			if (wpcir)
				begin
					reg_ins<=ins;
					reg_pc4<=pc4;
				end
		end
endmodule