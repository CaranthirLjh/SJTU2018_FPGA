module pipe_stage_wb (walu,wmo,wm2reg,wdi);
   input [31:0] walu,wmo;
   input wm2reg;
   
   output [31:0] wdi;
   
   assign wdi = wm2reg ? wmo : walu;
endmodule