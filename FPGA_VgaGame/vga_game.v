module vga_game (
	input clk,
	input reset,
	/*小游戏控制用输入:*/
	//左右移动
	input turn_left,
	input turn_right,
	//加速开关
	input sw9,
	input sw8,
	input sw7,
	/*VGA用输出信号:*/
	output vga_hs,//行同步信号
	output vga_vs,//场同步信号
	output vga_blank,//复合空白信号控制信号
	output vga_clk,//VGA自时钟
	output reg[7:0] vga_r,
	output reg[7:0] vga_g,
	output reg[7:0] vga_b,
	/*LED显示分数用输出信号:*/
	//未接到的球的数量
	output [6:0] hex0,
	output [6:0] hex1,
	//当前分数
	output [6:0] hex2,
	output [6:0] hex3,
	//历史最高分
	output [6:0] hex4,
	output [6:0] hex5
);
	//declare vga_x&vga_y:
	wire[31:0] vga_x;
	wire[31:0] vga_y;
	//declare basket element:
	reg[31:0] basket_width_left,basket_width_right;//The width of the basket
	reg[31:0] basket_height_top,basket_height_bottom;//The height of the basket
	reg[31:0] basket_width_left_init,basket_width_right_init;//The width of the basket
	reg[31:0] basket_height_top_init,basket_height_bottom_init;//The height of the basket
	reg[31:0] basket_extra_width;//The extra width
	//declare ball elements:
	parameter ball_num=5;//The num of balls
	reg[31:0] ball_width_left [4:0],ball_width_right [4:0];//The width of the ball
	reg[31:0] ball_height_top [4:0],ball_height_bottom [4:0];//The height of the ball
	reg[31:0] ball_width_left_init [4:0];//The init of the ball
	//init:
	initial
	begin
		//init the basket elements:
		//width:
		basket_width_left_init <= 10'd500;
		basket_width_right_init <= 10'd540;
		basket_extra_width <= 10'd0;
		//height:
		basket_height_top_init <= 10'd720;
		basket_height_bottom_init <= 10'd730;
		
		//init the basket elements:
		ball_width_left_init[0]=500;
		ball_width_left_init[1]=100;
		ball_width_left_init[2]=600;
		ball_width_left_init[3]=800;
		ball_width_left_init[4]=400;
		
		//element 0:
		ball_width_left[0] = ball_width_left_init[0];
		if(ball_width_left[0] < 0)
		begin
			ball_width_left[0]=-ball_width_left[0];
		end
		ball_width_right[0]=ball_width_left[0]+10;
		ball_height_top[0]=400;
		ball_height_bottom[0]=410;
		//element 1:
		ball_width_left[1] = ball_width_left_init[1];
		if(ball_width_left[1] < 0)
		begin
			ball_width_left[1]=-ball_width_left[1];
		end
		ball_width_right[1]=ball_width_left[1]+10;
		ball_height_top[1]=300;
		ball_height_bottom[1]=310;
		//element 2:
		ball_width_left[2] = ball_width_left_init[2];
		if(ball_width_left[2] < 0)
		begin
			ball_width_left[2]=-ball_width_left[2];
		end
		ball_width_right[2]=ball_width_left[2]+10;
		ball_height_top[2]=200;
		ball_height_bottom[2]=210;
		//element 3:
		ball_width_left[3] = ball_width_left_init[3];
		if(ball_width_left[3] < 0)
		begin
			ball_width_left[3]=-ball_width_left[3];
		end
		ball_width_right[3]=ball_width_left[3]+10;
		ball_height_top[3]=100;
		ball_height_bottom[3]=110;
		//element 4:
		ball_width_left[4] = ball_width_left_init[4];
		if(ball_width_left[4] < 0)
		begin
			ball_width_left[4]=-ball_width_left[4];
		end
		ball_width_right[4]=ball_width_left[4]+10;
		ball_height_top[4]=0;
		ball_height_bottom[4]=10;
		
		//init missed ball
		missed_ball <= 0;//未接到的球的数量
		
		//init score:
		tmp_score <= 0;//当前分数
		history_highest_score <= 0;//历史最高分
		
		//init bool_game_over:
		bool_game_over <= 0;//游戏是否结束
	end
	
	//generate the clock used to refresh the screen
	reg game_clk;//the game clk signal
	reg[31:0]game_clk_counter;
	parameter GAME_COUNTER = 4999999;
	always@(posedge clk)
	begin
		if(game_clk_counter == GAME_COUNTER)
		begin
			game_clk_counter = 0;
			game_clk=~game_clk;
		end
		else
		begin
			game_clk_counter=game_clk_counter+1;
		end
	end
	
	//set the acceleration switch
	reg[9:0] extra_speed;
	always@(posedge clk)
	begin
		extra_speed = 0;
		if (sw7 == 1)
		begin
			extra_speed = 2;
		end
		else if (sw8 == 1)
		begin
			extra_speed = 5;
		end
		else if (sw9 == 1)
		begin
			extra_speed = 10;
		end
	end
	
	//calculate basket's moveing distance
	parameter basic_speed = 20;
	reg[31:0] basket_left_move_pos;
	reg[31:0] basket_right_move_pos;
	
	always@(negedge(turn_left) or negedge(reset))
	begin
		if (!reset)
		begin
			basket_left_move_pos = 0;
		end
		else
		begin
			basket_left_move_pos = basket_left_move_pos + basic_speed + extra_speed;
		end
	end
	always@(negedge(turn_right) or negedge(reset))
	begin
		if (!reset)
		begin
			basket_right_move_pos = 0;
		end
		else
		begin
			basket_right_move_pos = basket_right_move_pos + basic_speed + extra_speed;
		end
	end
	
	
	//refresh basket's pos
	//refresh ball's pos & get score & calculate missed ball 
	integer i;
	parameter ball_speed = 10;
	reg[31:0] missed_ball;
	reg[31:0] tmp_score;
	reg[31:0] history_highest_score;
	always@(posedge(game_clk) or negedge(reset))
	begin
		if (!reset)
		begin
			//reinit the basket elements:
			//The width of the basket
			basket_width_left = basket_width_left_init;
			basket_width_right = basket_width_right_init;
			//The height of the basket
			basket_height_top = basket_height_top_init;
			basket_height_bottom = basket_height_bottom_init;
			
			//reinit the ball elements:
			//element 1:
			ball_width_left[1] = ball_width_left_init[1];
			if(ball_width_left[1] < 0)
			begin
				ball_width_left[1]=-ball_width_left[1];
			end
			ball_width_right[1]=ball_width_left[1]+10;
			ball_height_top[1]=300;
			ball_height_bottom[1]=310;
			//element 2:
			ball_width_left[2] = ball_width_left_init[2];
			if(ball_width_left[2] < 0)
			begin
				ball_width_left[2]=-ball_width_left[2];
			end
			ball_width_right[2]=ball_width_left[2]+10;
			ball_height_top[2]=200;
			ball_height_bottom[2]=210;
			//element 3:
			ball_width_left[3] = ball_width_left_init[3];
			if(ball_width_left[3] < 0)
			begin
				ball_width_left[3]=-ball_width_left[3];
			end
			ball_width_right[3]=ball_width_left[3]+10;
			ball_height_top[3]=100;
			ball_height_bottom[3]=110;
			//element 4:
			ball_width_left[4] = ball_width_left_init[4];
			if(ball_width_left[4] < 0)
			begin
				ball_width_left[4]=-ball_width_left[4];
			end
			ball_width_right[4]=ball_width_left[4]+10;
			ball_height_top[4]=0;
			ball_height_bottom[4]=10;
			
			missed_ball = 0;
			tmp_score = 0;
		end
		else
		begin
			if (bool_game_over == 0)
			begin
				//Basket:
				//The width of the basket
				basket_width_left = basket_width_left_init - basket_left_move_pos + basket_right_move_pos;
				basket_width_right = basket_width_right_init - basket_left_move_pos + basket_right_move_pos + basket_extra_width;
				if(basket_width_left<=0)
				begin
					basket_width_left=0;
					basket_width_right=40 + basket_extra_width;
				end
				if(basket_width_right>=1020)
				begin
					basket_width_left=980 - basket_extra_width;
					basket_width_right=1020;
				end
				//The height of the basket
				basket_height_top = basket_height_top_init;
				basket_height_bottom = basket_height_bottom_init;
				//Ball:
				for (i = 0; i < ball_num; i = i + 1)
				begin
					//change the ball's position
					if(i!=4)
					begin
						ball_height_top[i] = ball_height_top[i] + ball_speed;
						ball_height_bottom[i] = ball_height_bottom[i] + ball_speed;
					end
					else
					begin
						ball_height_top[i] = ball_height_top[i] + 2*ball_speed;
						ball_height_bottom[i] = ball_height_bottom[i] + 2*ball_speed;
					end
					if (ball_height_top[i] >= 720)
					begin
						//calculate the score
						if(ball_width_left[i]>=basket_width_left&&ball_width_right[i]<=basket_width_right)
						begin
							if(i!=4)
							begin
								tmp_score = tmp_score+1;
								history_highest_score = tmp_score > history_highest_score ? tmp_score : history_highest_score;
							end
							else
							begin
								tmp_score = tmp_score+2;
								history_highest_score = tmp_score > history_highest_score ? tmp_score : history_highest_score;
								//gain extra width
								if(basket_extra_width<=20)
								begin
									basket_extra_width=basket_extra_width+5;
								end
							end				
						end
						//calculate the num of missed balls
						else
						begin
							missed_ball=missed_ball+1;
						end
						//generate the balls' new position
						ball_height_top[i] = 0;
						ball_height_bottom[i] = 10;
						ball_width_left[i] = ball_width_left_init[i]+(tmp_score%5)*50;
						ball_width_right[i] = ball_width_left[i]+10;
					end
				end
			end
		end
	end
	//VGA screen
	display_port screen(
	.clk(clk),
	.reset(reset),
	.vga_x(vga_x),
	.vga_y(vga_y),
	.vga_hs(vga_hs),
	.vga_vs(vga_vs),
	.vga_blank(vga_blank),
	.vga_clk(vga_clk)
	);
	//History_highest_score on LED
	out_port_score HighestScoreBoard(
	.in(history_highest_score),
	.out1(hex5),
	.out0(hex4)
	);
	//Tmp_score on LED
	out_port_score TmpScoreBoard(
	.in(tmp_score),
	.out1(hex3),
	.out0(hex2)
	);
	//Missed_ball on LED
	out_port_score MissedBallBoard(
	.in(missed_ball),
	.out1(hex1),
	.out0(hex0)
	);
	
	//game over situation
	reg bool_game_over;
	always@(posedge(clk))
	begin
		if(!reset)
		begin
			bool_game_over=0;
		end
		else
		begin
			if(bool_game_over==0)
			begin
				if(missed_ball>10)
				begin
					bool_game_over=1;
				end
			end
		end
	end
	
	//set color
	integer j;
	always@(posedge(clk))
	begin
		//game is going on
		if(bool_game_over==0)
		begin
			//set the color of the background
			if(vga_x >= 0 && vga_x <=1024 && vga_y >= 0 && vga_y <=768)
			begin
				vga_r = 8'd255;
				vga_g = 8'd255;
				vga_b = 8'd255;
			end
			//set the color of the ball
			for(j=0;j<ball_num-1;j=j+1)
			begin
				if(vga_x >= ball_width_left[j] && vga_x <= ball_width_right[j] && vga_y <= ball_height_bottom[j] && vga_y >= ball_height_top[j])
				begin
					vga_r = 8'd80;
					vga_g = 8'd255;
					vga_b = 8'd80;
				end
			end
			if(vga_x >= ball_width_left[4] && vga_x <= ball_width_right[4] && vga_y <= ball_height_bottom[4] && vga_y >= ball_height_top[4])
			begin
				vga_r = 8'd80;
				vga_g = 8'd80;
				vga_b = 8'd255;
			end
			//set the color of the basket 
			if (vga_x >= basket_width_left && vga_x < basket_width_right && vga_y <= basket_height_bottom && vga_y >= basket_height_top)
			begin
				vga_r = 8'd221;
				vga_g = 8'd169;
				vga_b = 8'd105;
			end
			
		end
		//game is over
		else
		begin
			vga_r = 8'd255;
			vga_g = 8'd128;
			vga_b = 8'd128;
		end
	end
	
endmodule