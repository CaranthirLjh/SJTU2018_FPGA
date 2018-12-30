module pipe_reg_if(new_pc,wpcir,clk,resetn,pc);//IF stage前的reg，传入的是下一个PC
	input  [31:0] new_pc;
   input  wpcir,clk,resetn;
	
   output [31:0] pc;
   dffe32 next_pc(new_pc, clk, resetn, wpcir, pc);//get PC
endmodule