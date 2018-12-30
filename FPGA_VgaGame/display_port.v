module display_port(
	input clk,
	input reset,
	output reg[31:0] vga_x,//VGA screen's X coordinate
	output reg[31:0] vga_y,//VGA screen's Y coordinate
	output vga_hs,//行同步信号
	output vga_vs,//场同步信号
	output vga_blank,//复合空白信号控制信号
	output vga_clk//VGA自时钟
);
	//行同步信号
	assign vga_hs = ~(vga_x >= visible_pulse_h + front_pulse_h && vga_x < visible_pulse_h + front_pulse_h + sync_pulse_h);
	//场同步信号
	assign vga_vs = ~(vga_y >= visible_pulse_v + front_pulse_v && vga_y < visible_pulse_v + front_pulse_v + sync_pulse_v);
	//复合空白信号控制信号  当vga_blank为低电平时模拟视频输出消隐电平，此时从R9~R0,G9~G0,B9~B0输入的所有数据被忽略
	assign vga_blank = vga_y < visible_pulse_v && vga_x < visible_pulse_h;
	//VGA自时钟
	assign vga_clk = clk;
	
	//resolution ratioL:1920*1080
	//1920(x):
	parameter integer visible_pulse_h = 1024;//显示脉冲
	parameter integer front_pulse_h = 24;//前沿脉冲
	parameter integer sync_pulse_h = 136;//同步脉冲
	parameter integer back_pulse_h = 160;//后沿脉冲
	parameter integer whole_pulse_h = 1344;//帧长
	//1080(y):
	parameter integer visible_pulse_v = 768;//显示脉冲
	parameter integer front_pulse_v = 3;//前沿脉冲
	parameter integer sync_pulse_v = 6;//同步脉冲
	parameter integer back_pulse_v = 29;//后沿脉冲
	parameter integer whole_pulse_v = 806;//帧长
	
	/*generate the hs && vs timing*/
	always@(posedge(clk)) 
	begin
		if (!reset)
		begin
			vga_x = 0;
			vga_y = 0;
		end
		//set vga_x & vga_y
		else
		begin
			vga_x = vga_x + 1;
			if( vga_x == whole_pulse_h)
			begin
				vga_x = 0;
				vga_y = vga_y + 1;
				if( vga_y == whole_pulse_v)
					vga_y = 0;
			end
		end
	end
endmodule