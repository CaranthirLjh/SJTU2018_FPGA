module i_out_port(in_1,in_2,out1_0,out1_1,out2_0,out2_1);
	input [31:0] in_1,in_2;
	output [6:0] out1_0,out1_1,out2_0,out2_1;
	
	reg [3:0] num3,num2,num1,num0;

	sevenseg display_3( num3, out2_1 );
	sevenseg display_2( num2, out2_0 );
	sevenseg display_1( num1, out1_1 );
	sevenseg display_0( num0, out1_0 );
	
	always @ (in_1 or in_2)
	begin
		num1 = ( in_1 / 10 ) % 10;
		num0 = in_1 % 10;
		num3 = ( in_2 / 10 ) % 10;
		num2 = in_2 % 10;
	end
	
endmodule