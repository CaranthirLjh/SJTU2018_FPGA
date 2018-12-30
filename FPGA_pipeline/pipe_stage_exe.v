module pipe_stage_exe (ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu );

	 input ealuimm,eshift,ejal;
	 input [31:0] ea,eb,eimm,epc4;
    input [4:0] ern0;
    input [3:0] ealuc;

    output [31:0] ealu;
    output [4:0] ern;
    
    wire [31:0] alua,alub,sa,ealu0,epc8;
    wire zero;
    
	 assign sa = { 27'b0, eimm[10:6] };
	 
	 //选择ALU中的a端口的信号
    mux2x32 e_alu_a(ea,sa,eshift,alua);
	 //选择ALU中的b端口的信号
    mux2x32 e_alu_b(eb,eimm,ealuimm,alub);
	 //predict the next pc(pc+8)
	 assign epc8 = epc4 + 32'h4;
	 //jal为跳转调用指令，根据ejal信号判断ALU执行哪种指令
    mux2x32 e_choose_epc(ealu0,epc8,ejal,ealu);
	 
    assign ern = ern0 | {5{ejal}};
	 //执行ALU
    alu al_unit(alua,alub,ealuc,ealu0,zero);
endmodule