module pipe_stage_if(pcsource,pc,bpc,jrpc,jpc,new_pc,pc_plus4,inst,mem_clock);//IF stage
	input [1:0] pcsource;
	input [31:0] pc,bpc,jrpc,jpc;
	input mem_clock;
	
	output [31:0] new_pc,pc_plus4;
	output [31:0] inst;

	mux4x32 selectnewpc (pc_plus4,bpc,jrpc,jpc,pcsource,new_pc);//根据pcsource的值选择next PC
	cla32 pc_plus (pc,32'h4,1'b0,pc_plus4);//pc_plus4=pc+4
	lpm_rom_irom irom (pc[7:2],mem_clock,inst);//instruction memory:get inst from mem
endmodule