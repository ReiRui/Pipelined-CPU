module pipemem (mwmem,malu,mb,clock,ram_clock,mmo,
						out_port0,out_port1,out_port2,in_port0,in_port1);
							
							
	input  [31:0]  malu;
   input  [31:0]  mb;
   input          mwmem, clock,ram_clock;
	input  [31:0]	in_port0,in_port1;
	
   output [31:0]  mmo;
   
   output [31:0]	out_port0,out_port1,out_port2;
	
	wire [31:0]	io_read_data;
	
	wire[31:0] 		mmo;
     
   wire           write_enable; 
	wire				write_datamem_enable;
	wire[31:0]		mem_mmo;
	wire 				write_io_output_reg_enable;
	
   //assign         write_enable = mwmem & ~clock; 
	assign         write_enable = mwmem;
   assign 			write_datamem_enable= write_enable & (~malu[7]);
	assign 			write_io_output_reg_enable=write_enable & (malu[7]);
   
	mux2x32 mem_io_mmo_mux(mem_mmo,io_read_data,malu[7],mmo);
   lpm_ram_dq_dram  dram(malu[6:2],ram_clock,mb,write_datamem_enable,mem_mmo);
	io_output_reg  io_output_regx2(malu,mb,write_io_output_reg_enable,
								ram_clock,out_port0,out_port1,out_port2);
	io_input_reg   io_input_regx2(malu,ram_clock,io_read_data,in_port0,in_port1);		

endmodule