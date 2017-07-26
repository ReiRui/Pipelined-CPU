module pipeif (pcsource,pc,bpc,ra,jpc,npc,p4,ins,rom_clock);
	input [1:0] pcsource;
	input [31:0] pc,bpc,ra,jpc;
	input rom_clock;
	output [31:0] npc,ins,p4;
	
	assign p4 = pc + 32'h4;
   mux4x32 nextpc(p4,bpc,ra,jpc,pcsource,npc);

   lpm_rom_irom  irom(pc[7:2],rom_clock,ins); 

endmodule