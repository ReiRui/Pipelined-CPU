module pip_top(
	input clock,btn,
	input wire [4:0] sw_a,sw_b,
	output wire [6:0] hex_7,hex_6,hex_5,hex_4,hex_3,hex_2,hex_1,hex_0
	);

	//output pc,wdi,inst,wrn,walu,wmo,drn,malu,mb,mwmem,ewmem,dwmem,ealu,dimm,da;
	
	wire [31:0] pc,bpc,jpc,npc,pc4,ins,inst,walu,ealu,malu;
	wire [31:0] dpc4,da,db,dimm;
	wire [31:0] epc4,ea,eb,eimm;
	wire [31:0] mb,mmo;
	wire [31:0] wmo,wdi;
	wire [4:0] drn,ern0,ern,mrn,wrn;
	wire [3:0] daluc,ealuc;
	wire [1:0] pcsource;
	wire wpcir;//0 represent wait
	wire dwreg,dm2reg,dwmem,daluimm,dshift,djal;
	wire ewreg,em2reg,ewmem,ealuimm,eshift,ejal;
	wire mwreg,mm2reg,mwmem;
	wire wwreg,wm2reg, mem_clock;
	wire [31:0] out_port0,out_port1,out_port2,in_port0,in_port1;
	wire resetn;
	assign resetn = 1;

	wire [3:0] data_7,data_6,data_5,data_4,data_3,data_2;
   
	assign hex_1 = 7'b1111111;
	assign hex_0 = 7'b1111111;
	assign data_7 = out_port0/10;
	assign data_6 = out_port0%10;
	assign data_5 = out_port1/10;
	assign data_4 = out_port1%10;
	assign data_3 = out_port2/10;
	assign data_2 = out_port2%10;
	assign in_port0 = {27'b0,sw_a};
	assign in_port1 = {27'b0,sw_b};
	
	led hex7(data_7,clock,hex_7);
	led hex6(data_6,clock,hex_6);
	led hex5(data_5,clock,hex_5);
	led hex4(data_4,clock,hex_4);
	led hex3(data_3,clock,hex_3);
	led hex2(data_2,clock,hex_2);


	assign mem_clock = ~clock;


	pipepc prog_cnt(npc,wpcir,clock,resetn,pc,btn);
	//程序计数器模块，是最前面一级IF流水段的输入。

	pipeif if_stage (pcsource,pc,bpc,da,jpc,npc,pc4,ins,mem_clock); // IF stage
	//IF 取指令模块，注意其中包含的指令同步ROM 存储器的同步信号，
	//即输入给该模块的mem_clock 信号，模块内定义为rom_clk。// 注意 mem_clock。
	//实验中可采用系统clock 的反相信号作为mem_clock（亦即rom_clock）,
	//即留给信号半个节拍的传输时间。

	pipeir inst_reg (pc4,ins,wpcir,clock,resetn,dpc4,inst); // IF/ID 流水线寄存器
	//IF/ID 流水线寄存器模块，起承接IF 阶段和ID 阶段的流水任务。
	//在clock 上升沿时，将IF 阶段需传递给ID 阶段的信息，锁存在IF/ID 流水线寄存器
	//中，并呈现在ID 阶段。

	pipeid id_stage (mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst, // ID stage
							wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,
							bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,
							daluimm,da,db,dimm,drn,dshift,djal);
	//ID 指令译码模块。注意其中包含控制器CU、寄存器堆、及多个多路器等。
	//其中的寄存器堆，会在系统clock 的下沿进行寄存器写入，也就是给信号从WB 阶段
	//传输过来留有半个clock 的延迟时间，亦即确保信号稳定。
	//该阶段CU 产生的、要传播到流水线后级的信号较多。
							
	pipedereg de_reg (dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,dshift, // ID/EXE 流水线寄存器
							djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,ealuc,ealuimm,
							ea,eb,eimm,ern0,eshift,ejal,epc4);
	//ID/EXE 流水线寄存器模块，起承接ID 阶段和EXE 阶段的流水任务。
	//在clock 上升沿时，将ID 阶段需传递给EXE 阶段的信息，锁存在ID/EXE 流水线
	//寄存器中，并呈现在EXE 阶段。
		
	pipeexe exe_stage (ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu); // EXE stage
	//EXE 运算模块。其中包含ALU 及多个多路器等。

	pipeemreg em_reg (ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,
							mwreg,mm2reg,mwmem,malu,mb,mrn); // EXE/MEM 流水线寄存器
	//EXE/MEM 流水线寄存器模块，起承接EXE 阶段和MEM 阶段的流水任务。
	//在clock 上升沿时，将EXE 阶段需传递给MEM 阶段的信息，锁存在EXE/MEM
	//流水线寄存器中，并呈现在MEM 阶段。
		
							
	pipemem mem_stage(mwmem,malu,mb,clock,mem_clock,mmo,out_port0,out_port1,out_port2,in_port0,in_port1); // MEM stage
	//MEM 数据存取模块。其中包含对数据同步RAM 的读写访问。// 注意 mem_clock。
	//输入给该同步RAM 的mem_clock 信号，模块内定义为ram_clk。
	//实验中可采用系统clock 的反相信号作为mem_clock 信号（亦即ram_clk）,
	//即留给信号半个节拍的传输时间，然后在mem_clock 上沿时，读输出、或写输入。

	pipemwreg mw_reg (mwreg,mm2reg,mmo,malu,mrn,clock,resetn,
							wwreg,wm2reg,wmo,walu,wrn); // MEM/WB 流水线寄存器
	//MEM/WB 流水线寄存器模块，起承接MEM 阶段和WB 阶段的流水任务。
	//在clock 上升沿时，将MEM 阶段需传递给WB 阶段的信息，锁存在MEM/WB
	//流水线寄存器中，并呈现在WB 阶段。

	mux2x32 wb_stage (walu,wmo,wm2reg,wdi); // WB stage
	//WB 写回阶段模块。事实上，从设计原理图上可以看出，该阶段的逻辑功能部件只
	//包含一个多路器，所以可以仅用一个多路器的实例即可实现该部分。
	//当然，如果专门写一个完整的模块也是很好的。
						
endmodule