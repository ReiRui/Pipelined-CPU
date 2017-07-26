module pipeid (mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
						wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,
						bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,
						daluimm,da,db,dimm,drn,dshift,djal);

	input mwreg,ewreg,em2reg,mm2reg,wwreg,clock,resetn;
	input [4:0] mrn,ern,wrn;
	input [31:0] wdi;
	input [31:0] dpc4,inst,mmo;
	input [31:0] ealu,malu;
	output [3:0]  daluc;
	output [31:0] bpc,jpc,da,db,dimm;
	output [1:0] pcsource;
	output [4:0] drn;
	output wpcir,dwreg,dm2reg,dwmem,daluimm,dshift,djal;
	
	mux4x32 fwa(da0,ealu,malu,mmo,fwda,da);
	mux4x32 fwb(db0,ealu,malu,mmo,fwdb,db);
	assign wpcir = ~( (em2reg & ((ern==rs) | (ern == rt))) | (mm2reg & ((mrn==rs) | (mrn == rt))) );
	
	//assign wpcir = 1;
	
	
	
   wire [31:0]   dpc4,npc,bpc,res,alu_mem,dalub;
   wire [3:0]    daluc;
   wire [4:0]    reg_dest,wn,mrn,ern;
   wire [1:0]    pcsource;
   wire          dwmem,dwreg,regrt,dm2reg,dshift,daluimm,djal,sext;
   wire [31:0]   sa = { 27'b0, inst[10:6] }; // extend to 32 bits from sa for shift instruction
   wire [31:0]   offset = {imm[13:0],inst[15:0],1'b0,1'b0};   //offset(include sign extend)
   wire          e = sext & inst[15];          // positive or negative sign at sext signal
   wire [15:0]   imm = {16{e}};                // high 16 sign bit
   wire [31:0]   dimm = {imm,inst[15:0]}; // sign extend to high 16
   wire 				zero;
	wire 	[1:0] 	fwda ;
	wire 	[1:0] 	fwdb ;
	wire  [4:0] 	rs =inst[25:21];
	wire  [4:0] 	rt =inst[20:16];
	wire [31:0] 	da0,db0;
	
	assign fwda[0] = (ewreg & (ern!=0) & (ern == rs) & ~em2reg) | (mwreg & (mrn!=0) & (mrn == rs) & mm2reg);
	assign fwda[1] = (mwreg & (mrn!=0) & (mrn == rs) & ~mm2reg) | (mwreg & (mrn!=0) & (mrn == rs) & mm2reg);
	assign fwdb[0] = (ewreg & (ern!=0) & (ern == rt) & ~em2reg) | (mwreg & (mrn!=0) & (mrn == rt) & mm2reg);
	assign fwdb[1] = (mwreg & (mrn!=0) & (mrn == rt) & ~mm2reg) | (mwreg & (mrn!=0) & (mrn == rt) & mm2reg);
	assign zero = ~(|ealu);
	
	/*always@(posedge clock)
		begin
			if (ealu==0)
				zero <=1;
			else
				zero <=0;
			
			
			if (ewreg & (ern!=0) & (ern == rs) & ~em2reg)
				fwda <= 2'b01;
			else	
				begin
					if (mwreg & (mrn!=0) & (mrn == rs) & ~mm2reg)
						fwda <= 2'b10;
					else
						begin
							if (mwreg & (mrn!=0) & (mrn == rs) & mm2reg)
								fwda <= 2'b11;
							else
								fwda <= 2'b00;
						end
				end
				
			if (ewreg & (ern!=0) & (ern == rt) & ~em2reg)
				fwdb <= 2'b01;
			else	
				begin
					if (mwreg & (mrn!=0) & (mrn == rt) & ~mm2reg)
						fwdb <= 2'b10;
					else
						begin
							if (mwreg & (mrn!=0) & (mrn == rt) & mm2reg)
								fwdb <= 2'b11;
							else
								fwdb <=2'b00;
						end
				end
		end*/
   
   

   
   assign bpc = dpc4 + offset;     // modified
   
	
	
   wire [31:0] jpc = {dpc4[31:28],inst[25:0],1'b0,1'b0}; // j address 
   
   sc_cu cu (inst[31:26],inst[5:0],zero,dwmem,dwreg,regrt,dm2reg,
                        daluc,dshift,daluimm,pcsource,djal,sext);
                        
                        
  // mux2x32 alu_b (db,immediate,daluimm,dalub);
  // mux2x32 alu_a (da,sa,dshift,da);
   //mux2x32 result(alu,mem,dm2reg,alu_mem);
   //mux2x32 link (alu_mem,dpc4,djal,res);
   mux2x5 reg_wn (inst[15:11],inst[20:16],regrt,drn);
   //assign drn = reg_dest | {5{djal}}; // jal: r31 <-- dpc4;      // 31 or reg_dest
   regfile rf (inst[25:21],inst[20:16],wdi,wrn,wwreg,clock,resetn,da0,db0);
   //alu al_unit (da,db,daluc,alu,zero);						
						
endmodule						
						