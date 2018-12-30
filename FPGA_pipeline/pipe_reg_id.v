module pipe_reg_id (pc_plus4,inst,wpcir,clk,resetn,out_pc_plus4,out_inst);
	input [31:0] pc_plus4,inst;
	input wpcir,clk,resetn;
	
	output [31:0] out_pc_plus4,out_inst;
	
	dffe32 pc_plus(pc_plus4,clk,resetn,wpcir,out_pc_plus4);//输出pc信号
	dffe32 instruction(inst,clk,resetn,wpcir,out_inst);//输出ins信号
endmodule