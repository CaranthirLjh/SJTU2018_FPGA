module io_in_port (sw9,sw8,sw7,sw6,sw5,sw4,sw3,sw2,sw1,sw0,out1,out0);
	input sw9,sw8,sw7,sw6,sw5,sw4,sw3,sw2,sw1,sw0;
	output [31:0] out1,out0;

	assign out0[4] = sw4;
	assign out0[3] = sw3;
	assign out0[2] = sw2;
	assign out0[1] = sw1;
	assign out0[0] = sw0;
	
	assign out1[4] = sw9;
	assign out1[3] = sw8;
	assign out1[2] = sw7;
	assign out1[1] = sw6;
	assign out1[0] = sw5;
	
endmodule