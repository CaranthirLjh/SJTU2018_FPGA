module sc_computer_io(resetn,clock,mem_clk,pc,inst,aluout,memout,imem_clk,dmem_clk,
out_port0,out_port1,out_port2,in_port0,in_port1,mem_dataout,io_read_data);
	input resetn;
	input clock,mem_clk;
	input [31:0] in_port0,in_port1;
	output imem_clk,dmem_clk;
	output [31:0] pc,inst,aluout,memout,mem_dataout,io_read_data,out_port0,out_port1,out_port2;
	
	wire wmem;
	wire [31:0] data;
	
	//use sc_cpu module
	sc_cpu cpu(clock,resetn,inst,memout,pc,wmem,aluout,data);
	//use instruction memory module
	sc_instmem imem(pc,inst,clock,mem_clk,imem_clk);
	//use data memory module
	sc_datamem_io  dmem (aluout,data,memout,wmem,clock,mem_clk,dmem_clk,
		out_port0,out_port1,out_port2,in_port0,in_port1,mem_dataout,io_read_data	); // data memory.

	
endmodule