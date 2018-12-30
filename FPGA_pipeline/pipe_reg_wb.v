module pipe_reg_wb(mwreg,mm2reg,mmo,malu,mrn,clk,resetn,wwreg,wm2reg,wmo,walu,wrn);

    input clk,resetn;
	 input [4:0] mrn;
    input [31:0] mmo,malu;
    input mwreg,mm2reg;
    
    output reg [31:0] wmo,walu;
    output reg [4:0] wrn;
    output reg wwreg,wm2reg;
    //在时钟上升沿更新信号，并发送给WB stage
    always @ (negedge resetn or posedge clk)
		begin
		//若resetn为零，将所有信号置为零
		if(resetn == 0) 
			begin
			wwreg   <= 0;
			wm2reg  <= 0;
			wmo     <= 0;
			walu    <= 0;
			wrn     <= 0;
			end
		//更新信号		
		else 
			begin 
			wwreg   <= mwreg ;
			wm2reg  <= mm2reg;
			wmo     <= mmo   ;
			walu    <= malu  ;
			wrn     <= mrn   ;
			end
		end
		
endmodule 