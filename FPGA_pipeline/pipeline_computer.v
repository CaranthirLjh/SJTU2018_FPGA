module pipeline_computer(resetn,clock,mem_clock, pc,inst,ealu,malu,walu,
	out_port0,out_port1,out_port2,in_port0,in_port1,mem_dataout,io_read_data);
	
	input resetn, clock, mem_clock;
	input [31:0] in_port0,in_port1;
	
	output [31:0] out_port0,out_port1,out_port2;
	output [31:0] mem_dataout;
	output [31:0] io_read_data;
	output [31:0] pc,inst,ealu,malu,walu;	
	
	
	
	wire [31:0] bpc,jpc,npc,pc4,ins, inst;
	wire [31:0] dpc4,da,db,dimm;
	wire [31:0] epc4,ea,eb,eimm;
	wire [31:0] mb,mmo;
	wire [31:0] wmo,wdi;
	wire [4:0] drn,ern0,ern,mrn,wrn;

	wire [3:0] daluc,ealuc;

	wire [1:0] pcsource;

	wire wpcir;
	wire dwreg,dm2reg,dwmem,daluimm,dshift,djal; // id stage
	wire ewreg,em2reg,ewmem,ealuimm,eshift,ejal; // exe stage
	wire mwreg,mm2reg,mwmem; // mem stage
	wire wwreg,wm2reg; // wb stage
	
	
	pipe_reg_if if_reg(npc,wpcir,clock,resetn,pc);//IF reg
	
	pipe_stage_if if_stage(pcsource,pc,bpc,da,jpc,npc,pc4,ins,mem_clock);//IF stage
	
	pipe_reg_id id_reg(pc4,ins,wpcir,clock,resetn,dpc4,inst);//ID reg
	
	pipe_stage_id id_stage(mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
	wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,	
	bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,
	daluimm,da,db,dimm,drn,dshift,djal);// ID stage
	
	pipe_reg_exe exe_reg(dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,
	drn,dshift,djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,ealuc,ealuimm,
	ea,eb,eimm,ern0,eshift,ejal,epc4);//EXE reg
	
	pipe_stage_exe exe_stage(ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu);//EXE stage
	
	pipe_reg_mem mem_reg(ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,mwreg,mm2reg,mwmem,malu,mb,mrn);//MEM reg
	
	pipe_stage_mem mem_stage(mwmem,malu,mb,clock,mem_clock,mmo, 
	out_port0,out_port1,out_port2,in_port0,in_port1,mem_dataout,io_read_data);//MEM stage
	
	pipe_reg_wb wb_reg(mwreg,mm2reg,mmo,malu,mrn,clock,resetn,wwreg,wm2reg,wmo,walu,wrn);//WB reg
	
	pipe_stage_wb wb_stage(walu,wmo,wm2reg,wdi);//WB stage

endmodule