module pipeexe (ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu);
input [3:0] ealuc;
input ealuimm,eshift,ejal;
input [31:0] ea,eb,eimm,epc4;
input [4:0] ern0;
output [4:0] ern;
output [31:0] ealu;

wire [31:0] ealu_a,ealu_b,ealu_mem;
wire [31:0] epc44 = epc4+32'h4;
mux2x32 alu_a (ea,eimm,eshift,ealu_a);
mux2x32 alu_b (eb,eimm,ealuimm,ealu_b);
alu al_exe (ealu_a,ealu_b,ealuc,ealu_mem);
mux2x32 link (ealu_mem,epc44,ejal,ealu);
assign ern = ern0 | {5{ejal}};
endmodule
