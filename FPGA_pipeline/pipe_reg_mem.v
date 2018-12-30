module pipe_reg_mem (ewreg,em2reg,ewmem,ealu,eb,ern,clk,resetn,mwreg,mm2reg,mwmem,malu,mb,mrn);
    input clk,resetn;
	 input [4:0] ern;
    input [31:0] ealu,eb;
    input ewreg,em2reg,ewmem;

    output [31:0] malu,mb;
    output [4:0] mrn;
    output mwreg,mm2reg,mwmem;
	 
	 reg [31:0] malu,mb;
	 reg [4:0] mrn;
	 reg mwreg,mm2reg,mwmem;
    
	 //在时钟上升沿更新信号，并发送给MEM stage
    always @ (negedge resetn or posedge clk)
		begin
		//若resetn为零，将所有信号置为零
		if (resetn == 0) 
			begin
			mwreg <= 0;
			mm2reg <= 0;
			mwmem <= 0;
			malu <= 0;
			mb <= 0;
			mrn <= 0;
			end
		//更新信号	
		else 
			begin
			mwreg <= ewreg;
			mm2reg <= em2reg;
			mwmem <= ewmem;
			malu <= ealu;
			mb <= eb;
			mrn <= ern;
			end
		end
		
endmodule