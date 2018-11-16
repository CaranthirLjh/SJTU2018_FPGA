// ==============================================================
// 
// This stopwatch is just to test the work of LED and KEY on DE1-SOC board.
// use "=" to give value to hour_counter_high and so on. 异步操作/阻塞赋值方式
//
// 3 key: key_reset/系统复位, key_start_pause/暂停计时, key_display_stop/暂停显示
//
// ==============================================================
module clock_main(clk,key_reset,key_start_pause,key_display_stop, 
// 时钟输入 + 3 个按键；按键按下为 0 。板上利用施密特触发器做了一定消抖，效果待测试。
 hex0,hex1,hex2,hex3,hex4,hex5,
// 板上的 6 个 7 段数码管，每个数码管有 7 位控制信号。
 led0,led1,led2,led3 ); 
// LED 发光二极管指示灯，用于指示/测试程序按键状态，若需要，可增加。 高电平亮。
	input clk,key_reset,key_start_pause,key_display_stop;
	output [6:0] hex0,hex1,hex2,hex3,hex4,hex5;
	output led0,led1,led2,led3;
	reg led0,led1,led2,led3;
	reg display_work; 
// 显示刷新，即显示寄存器的值 实时 更新为 计数寄存器 的值。
	reg counter_work; 
// 计数（计时）工作 状态，由按键 “计时/暂停” 控制。
	parameter DELAY_TIME = 10000000; 
// 定义一个常量参数。 10000000 ->200ms；
// 定义 6 个显示数据（变量）寄存器：
	reg [3:0] minute_display_high;
	reg [3:0] minute_display_low;
	reg [3:0] second_display_high;
	reg [3:0] second_display_low;
	reg [3:0] msecond_display_high;
	reg [3:0] msecond_display_low;
// 定义 6 个计时数据（变量）寄存器：
 
	reg [3:0] minute_counter_high;
	reg [3:0] minute_counter_low;
	reg [3:0] second_counter_high;
	reg [3:0] second_counter_low;
	reg [3:0] msecond_counter_high;
	reg [3:0] msecond_counter_low;

	reg [31:0] counter_50M; // 计时用计数器， 每个 50MHz 的 clock 为 20ns。
// DE1-SOC 板上有 4 个时钟， 都为 50MHz，所以需要 500000 次 20ns 之后，才是 10ms。
	reg bool_reset; // 消抖动用状态寄存器 -- for reset KEY
	reg [31:0] counter_reset; // 按键状态时间计数器
	reg bool_start_pause; //消抖动用状态寄存器 -- for counter/pause KEY
	reg [31:0] counter_start; //按键状态时间计数器
	reg bool_display_stop; //消抖动用状态寄存器 -- for KEY_display_refresh/pause
	reg [31:0] counter_display; //按键状态时间计数器
 
	reg start; // 工作状态寄存器
	reg display; // 工作状态寄存器
// sevenseg 模块为 4 位的 BCD 码至 7 段 LED 的译码器，
//下面实例化 6 个 LED 数码管的各自译码器。
	sevenseg LED8_minute_display_high ( minute_display_high, hex5 );
	sevenseg LED8_minute_display_low ( minute_display_low, hex4 );
	
	sevenseg LED8_second_display_high( second_display_high, hex3 );
	sevenseg LED8_second_display_low ( second_display_low, hex2 );
	
	sevenseg LED8_msecond_display_high( msecond_display_high, hex1 );
	sevenseg LED8_msecond_display_low ( msecond_display_low, hex0 );
	
	/*My Implementation*/
	//declare new reg
	reg [31:0] per_time_counter;//最小单位时间计数器
	reg bool_do_reset;//是否执行reset
	reg bool_do_pause;//是否暂停
	reg bool_do_display;//是否显示
	
	//实现LED发光指示灯:led0=reset/led1=start_pause/led2=display_stop
	always @ (key_reset)
	begin
		led0=1;
	end
	always @ (key_start_pause)
	begin
		led1=1;
	end
	always @ (key_display_stop)
	begin
		led2=1;
	end
	
	
	always @ (posedge clk) // 每一个时钟上升沿开始触发下面的逻辑，
	// 进行计时后各部分的刷新工作
	begin
	//此处功能代码省略，由同学自行设计。
	//按键判断：
		//case1-1：按下reset
		if(key_reset && !bool_reset)
		begin
			counter_reset=counter_reset+1;//按下过0.5s后生效
			if(counter_reset >= 2500000)
			begin
				bool_reset=~bool_reset;//reverse the reset state
				counter_reset=0;//set the count to 0
				bool_do_reset=1;//set the do_reset to 1
			end
		end
		//case1-2:松开reset
		else if(!key_reset && bool_reset)
		begin
			counter_reset=counter_reset+1;//按下过0.5s后生效
			if(counter_reset >= 2500000)
			begin
				bool_reset=~bool_reset;//reverse the reset state
				counter_reset=0;//set the count to 0
			end
		end
		//case1-3:else
		else
		begin
			counter_reset=0;//clear the reset counter
		end
		
		//case2-1:按下start_pause，尝试启用暂停
		if(key_start_pause && !bool_start_pause)
		begin
			counter_start=counter_start+1;
			if(counter_start >= 2500000)
			begin
				bool_start_pause=~bool_start_pause;
				counter_start=0;
				bool_do_pause=1;
			end
		end
		//case2-2：按下start_pause，尝试解除暂停
		else if(key_start_pause && bool_start_pause)
		begin
			counter_start=counter_start+1;
			if(counter_start >= 2500000)
			begin
				bool_start_pause=~bool_start_pause;
				counter_start=0;
				bool_do_pause=0;
			end
		end
		//case2-3:else
		else
		begin
			counter_start=0;//clear the reset counter
		end
		
		//case3-1:按下display_stop，尝试开启显示
		if(key_display_stop && !bool_display_stop)
		begin
			counter_display=counter_display+1;
			if(counter_display >= 2500000)
			begin
				bool_display_stop=~bool_display_stop;
				counter_display=0;
				bool_do_display=1;
			end
		end
		//case3-2:按下display_stop，尝试关闭显示
		else if(key_display_stop && bool_display_stop)
		begin
			counter_display=counter_display+1;
			if(counter_display >= 2500000)
			begin
				bool_display_stop=~bool_display_stop;
				counter_display=0;
				bool_do_display=0;
			end
		end
		//case3-3:else
		else
		begin
			counter_display=0;//clear the reset counter
		end
		
		//judge display&reset
		//do reset
		if(bool_do_reset)
		begin
			minute_counter_high=0;
			minute_counter_low=0;
			second_counter_high=0;
			second_counter_low=0;
			msecond_counter_high=0;
			msecond_counter_low=0;
			//finish reset,set do_reset to 0
			bool_do_reset=0;
		end
		//do_display
		if(bool_do_display)
		begin
			minute_display_high=minute_counter_high;
			minute_display_low=minute_counter_low;
			second_display_high=second_counter_high;
			second_display_low=second_counter_low;
			msecond_display_high=msecond_counter_high;
			msecond_display_low=msecond_counter_low;
		end
		
		//update the clock counter
		if(!bool_do_pause)
		begin
			per_time_counter=per_time_counter+1;
			if(per_time_counter==500000)
			begin
				msecond_counter_low=msecond_counter_low+1;//msecond_low+1
				per_time_counter=0;//reset the per_time_counter
				//whether a carry happen on the msecond_counter_high
				if(msecond_counter_low==10)
				begin
					msecond_counter_high=msecond_counter_high+1;
					msecond_counter_low=0;
					//whether a carry happen on the second_counter_low
					if(msecond_counter_high==10)
					begin
						second_counter_low=second_counter_low+1;
						msecond_counter_high=0;
						//whether a carry happen on the second_counter_high
						if(second_counter_low==10)
						begin
							second_counter_high=second_counter_high+1;
							second_counter_low=0;
							//whether a carry happen on the minute_counter_low
							if(second_counter_high==6)
							begin
								minute_counter_low=minute_counter_low+1;
								second_counter_high=0;
								//whether a carry happen on the minute_counter_high
								if(minute_counter_low==10)
								begin
									minute_counter_high=minute_counter_high+1;
									minute_counter_low=0;
									//whether a carry happen on the over_minute_counter_high
									if(minute_counter_high==10)
									begin
										minute_counter_high=10;
									end
								end
							end
						end
					end
				end
			end
		end
	
	
	end
endmodule


//4bit 的 BCD 码至 7 段 LED 数码管译码器模块
//可供实例化共 6 个显示译码模块
module sevenseg ( data, ledsegments); 
	input [3:0] data;
	output ledsegments;
	reg [6:0] ledsegments;
	
	always @ (*)
		case(data)
			// gfe_dcba // 7 段 LED 数码管的位段编号
			// 654_3210 // DE1-SOC 板上的信号位编号
			0: ledsegments = 7'b100_0000; // DE1-SOC 板上的数码管为共阳极接法。
			1: ledsegments = 7'b111_1001;
			2: ledsegments = 7'b010_0100;
			3: ledsegments = 7'b011_0000;
			4: ledsegments = 7'b001_1001;
			5: ledsegments = 7'b001_0010;
			6: ledsegments = 7'b000_0010;
			7: ledsegments = 7'b111_1000;
			8: ledsegments = 7'b000_0000;
			9: ledsegments = 7'b001_0000; 
			default: ledsegments = 7'b111_1111; // 其它值时全灭。
		endcase 
endmodule
