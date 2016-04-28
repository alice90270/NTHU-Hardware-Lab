`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:44:59 05/24/2015 
// Design Name: 
// Module Name:    test 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module test(DIGIT, DISPLAY, ROW, COLUMN, clk, S1_reset, S2, S3, S4, S5, S6, S7, S8, LED,LCD_ENABLE, LCD_RW, LCD_DI, LCD_CS1, LCD_CS2, LCD_RST,LCD_DATA);
	input clk, S1_reset, S2, S3, S4, S5, S6, S7, S8;
	input [3:0] COLUMN;
	output reg [3:0] DIGIT;
	output reg [3:0] ROW;
	output reg [15:0] DISPLAY;
	output reg [15:0] LED;
	output LCD_ENABLE;
	output LCD_RW;
	output LCD_DI;
	output LCD_CS1;
	output LCD_CS2;
	output LCD_RST;
	output[7:0] LCD_DATA;
	reg[7:0] LCD_DATA;
	reg[7:0] PATTERN,PATTERN,PATTERN2,PATTERN3,PATTERN4,PATTERN5,PATTERN6,PATTERN7;
	reg[1:0] LCD_SEL;
	reg[2:0] STATE;
	reg[2:0] X_PAGE;
	reg[1:0] DELAY;
	reg[7:0] INDEX;
	reg[1:0] ENABLE;
	reg CLEAR;
	reg LCD_RW;
	reg LCD_DI;
	reg LCD_RST;
	wire LCD_clk;
	wire LCD_CS1;
	wire LCD_CS2;
	wire LCD_ENABLE;
	reg[25:1] DIVIDER;
	reg [3:0] DEBOUNCE_COUNT;
	reg [3:0] b0,b1,b2,b3,tempans0,tempans1,tempans2,tempans3,ans0,ans1,ans2,ans3;
	reg [4:0] BCD,a0,a1,a2,a3,tempansA0,tempansA1,tempansA2,tempansA3,ansA0,ansA1,ansA2,ansA3;
	reg [7:0]shift_S2,shift_S3,shift_S4,shift_S5,shift_S6,shift_S7,shift_S8;
	reg [5:0]state;
	reg [3:0] SCAN_CODE;
	reg [15:0] KEY_BUFFER;
	reg [2:0] X,Y;
	reg PRESS_KEY;
	reg[1:0] answer_flag;
	reg[4:0] chances;
	reg[2:0] level;
	reg[3:0] a, b, c, d;
	wire clk_15,clk20,clk23;
	wire PRESS_VALID;
	wire DB_S2,DB_S3,DB_S4,DB_S5,DB_S6,DB_S7,DB_S8;
	wire OP_S2,OP_S3,OP_S4,OP_S5,OP_S6,OP_S7,OP_S8;
	
	parameter start =6'd0;
	parameter choose_level=6'd27;
	parameter guess0_9=6'd28;
	parameter guess0_F=6'd29;
	parameter input0=6'd30;
	parameter input1=6'd31;
	parameter input2=6'd32;
	parameter input3=6'd33;
	parameter input4=6'd34;
	parameter minus=6'd35;
	parameter check_answer=6'd36;
	parameter win=6'd37;
	parameter fail=6'd38;
	parameter XAYB=6'd39;
	
/*********************************************************
				* Clock Divider*
*********************************************************/
	always@(posedge clk)begin
			if(!S1_reset)
				DIVIDER <= {12'h000,2'b00};
			else
				DIVIDER <= DIVIDER + 1;
		end
	assign clk_15 = DIVIDER[14];
	assign clk_20 = DIVIDER[19];
	assign clk_23 = DIVIDER[23];
	assign LCD_clk = DIVIDER[8];
	
/*********************************************************
					* State *
*********************************************************/
	always @(posedge clk_15 or negedge S1_reset) begin
		if(!S1_reset) begin
			state<= start;
		end
		else begin
			
			case(state)
				start:begin
					if(PRESS_VALID)		state <= choose_level;
					else  state <= start;
				end
				choose_level:begin
					if(PRESS_VALID)begin
						if(level<3'd4)	state <= guess0_9;
						else			state <= guess0_F;
					end
					else 				state <= choose_level;
				end
				guess0_9:begin
					if(PRESS_VALID)		state <= input0;
					else				state <= guess0_9;
				end
				guess0_F:begin
					if(PRESS_VALID)		state <= input0;
					else				state <= guess0_F;
				end
				input0:	begin
					if(!DB_S8)begin						//restart
						if(level<3'd4)	state <= guess0_9;
						else			state <= guess0_F;
					end
					else if(!DB_S5)		state <= input0;//cancel
					else if(PRESS_VALID)state <= input1;
					else 				state <= input0;
				end
				input1:	begin
					if(!DB_S8)begin						//restart
						if(level<3'd4)	state <= guess0_9;
						else			state <= guess0_F;
					end
					else if(!DB_S5)		state <= input0;//cancel
					else if(PRESS_VALID)state <= input2;
					else 				state <= input1;
				end
				input2:	begin
					if(!DB_S8)begin						//restart
						if(level<3'd4)	state <= guess0_9;
						else			state <= guess0_F;
					end
					else if(!DB_S5)		state <= input0;//cancel
					else if(PRESS_VALID)state <= input3;
					else 				state <= input2;
				end
				input3:	begin
					if(!DB_S8)begin						//restart
						if(level<3'd4)	state <= guess0_9;
						else			state <= guess0_F;
					end
					else if(!DB_S5)		state <= input0;//cancel
					else if(PRESS_VALID)state <= input4;
					else 				state <= input3;
				end
				input4:	begin
					if(!DB_S8)begin						//restart
						if(level<3'd4)	state <= guess0_9;
						else			state <= guess0_F;
					end
					else if(!DB_S5)		state <= input0;//cancel
					else if(!DB_S4)		state <= minus;//send
					else				state <= input4;
				end
				minus:begin
					state <= check_answer;
				end
				check_answer: begin
					if(answer_flag==2'd1) 				//correct
						state<=win;
					else if(answer_flag==2'd2) begin	//wrong
						if(chances==5'd0)
							state<=fail;				//GAME OVER
						else
							state<=XAYB;
					end
					else	state<=XAYB;
				end
				win:begin
					if(PRESS_VALID) state<=start;	//reset
					else			state<=win;
				end
				XAYB:begin
					if(PRESS_VALID) state<=input0;	//keep trying
					else			state<=XAYB;
				end
				fail:begin
					if(PRESS_VALID) state<=start;	//reset
					else			state<=fail;
				end
				default:state <= start;
			endcase
		end
	end
/*********************************************************
* Keyboard *
*********************************************************/
	/*********************************************************
	* Scanning Code Generator *
	*********************************************************/
		always@(posedge clk or negedge S1_reset)begin
			if(!S1_reset)
				SCAN_CODE <= 5'h0;
			else if(PRESS_KEY)
				SCAN_CODE <= SCAN_CODE + 1;
		end
		
	/*********************************************************
	* Scanning Keyboard *
	*********************************************************/
		always@(SCAN_CODE,COLUMN)begin
			case(SCAN_CODE[3:2])
				2'b00 : ROW = 4'b1110;
				2'b01 : ROW = 4'b1101;
				2'b10 : ROW = 4'b1011;
				2'b11 : ROW = 4'b0111;
			endcase
			case(SCAN_CODE[1:0])
				2'b00 : PRESS_KEY = COLUMN[0];
				2'b01 : PRESS_KEY = COLUMN[1];
				2'b10 : PRESS_KEY = COLUMN[2];
				2'b11 : PRESS_KEY = COLUMN[3];
			endcase
		end
		
	/*********************************************************
	* Debounce Circuit * 
	// PRESS_VALID 是否按下keyboard //
	*********************************************************/
		always@(posedge clk_15 or negedge S1_reset) begin
			if(!S1_reset)
				DEBOUNCE_COUNT <= 5'h0;
			else if(PRESS_KEY)
				DEBOUNCE_COUNT <= 5'h0;
			else if(DEBOUNCE_COUNT <= 5'hE)
				DEBOUNCE_COUNT <= DEBOUNCE_COUNT + 1;
		end
		assign PRESS_VALID = (DEBOUNCE_COUNT == 5'hD) ?1'b1 : 1'b0;
	
	/*********************************************************
	* level & chances *
	*********************************************************/	
	always@(negedge clk_23 or negedge S1_reset)begin
			if(!S1_reset) begin
				level<=3'd1;
			end
			else begin
				case(state)
					choose_level:begin
						if(!DB_S2)begin
							case(level)
								3'd1: level <= 3'd2;
								3'd2: level <= 3'd3;
								3'd3: level <= 3'd4;
								3'd4: level <= 3'd5;
								3'd5: level <= 3'd6;
								3'd6: level <= 3'd6;
								default: level <= 3'd1;
							endcase
						end
						if(!DB_S3)begin
							case(level)
								3'd1: level <= 3'd1;
								3'd2: level <= 3'd1;
								3'd3: level <= 3'd2;
								3'd4: level <= 3'd3;
								3'd5: level <= 3'd4;
								3'd6: level <= 3'd5;
								default: level <= 3'd1;
							endcase
						end
					end
				endcase
			end	
	end	
	/*********************************************************
	* input function *
	*********************************************************/
		always@(negedge clk_15 or negedge S1_reset)begin
			if(!S1_reset) begin
				KEY_BUFFER <= 16'h0000;
				chances<=5'd16;
			end
			else begin
				case(state)
					guess0_9:begin
						case(level)
							3'd1: chances <= 5'd16;
							3'd2: chances <= 5'd8;
							3'd3: chances <= 5'd6;
							default: chances <= 5'd16;
						endcase
					end
					guess0_F:begin
						case(level)
							3'd4: chances <= 5'd16;
							3'd5: chances <= 5'd15;
							3'd6: chances <= 5'd13;
							default:chances <= 5'd16;
						endcase
					end
					input0:begin
						KEY_BUFFER[11:0] <= 12'b0;
						if(PRESS_VALID)	
							begin
								case(SCAN_CODE)
									5'hC : KEY_BUFFER[15:12] <= 5'h0; // 0
									5'hD : KEY_BUFFER[15:12] <= 5'h1; // 1
									5'h9 : KEY_BUFFER[15:12] <= 5'h2; // 2
									5'h5 : KEY_BUFFER[15:12] <= 5'h3; // 3
									5'hE : KEY_BUFFER[15:12] <= 5'h4; // 4
									5'hA : KEY_BUFFER[15:12] <= 5'h5; // 5
									5'h6 : KEY_BUFFER[15:12] <= 5'h6; // 6
									5'hF : KEY_BUFFER[15:12] <= 5'h7; // 7
									5'hB : KEY_BUFFER[15:12] <= 5'h8; // 8 -8 
									5'h7 : KEY_BUFFER[15:12] <= 5'h9; // 9 -7
									5'h8 : KEY_BUFFER[15:12] <= 5'hA; // A -6
									5'h4 : KEY_BUFFER[15:12] <= 5'hB; // B -5
									5'h3 : KEY_BUFFER[15:12] <= 5'hC; // C -4
									5'h2 : KEY_BUFFER[15:12] <= 5'hD; // D -3
									5'h1 : KEY_BUFFER[15:12] <= 5'hE; // E -2
									5'h0 : KEY_BUFFER[15:12] <= 5'hF; // F -1
								endcase			
							end
						else	KEY_BUFFER[15:12] <= 5'h0;
					end
					input1: begin
						KEY_BUFFER[7:0] <= 8'b0;
						if(PRESS_VALID)	
							begin
								case(SCAN_CODE)
									5'hC : KEY_BUFFER[11:8] <= 5'h0; // 0
									5'hD : KEY_BUFFER[11:8] <= 5'h1; // 1
									5'h9 : KEY_BUFFER[11:8] <= 5'h2; // 2
									5'h5 : KEY_BUFFER[11:8] <= 5'h3; // 3
									5'hE : KEY_BUFFER[11:8] <= 5'h4; // 4
									5'hA : KEY_BUFFER[11:8] <= 5'h5; // 5
									5'h6 : KEY_BUFFER[11:8] <= 5'h6; // 6
									5'hF : KEY_BUFFER[11:8] <= 5'h7; // 7
									5'hB : KEY_BUFFER[11:8] <= 5'h8; // 8 -8 
									5'h7 : KEY_BUFFER[11:8] <= 5'h9; // 9 -7
									5'h8 : KEY_BUFFER[11:8] <= 5'hA; // A -6
									5'h4 : KEY_BUFFER[11:8] <= 5'hB; // B -5
									5'h3 : KEY_BUFFER[11:8] <= 5'hC; // C -4
									5'h2 : KEY_BUFFER[11:8] <= 5'hD; // D -3
									5'h1 : KEY_BUFFER[11:8] <= 5'hE; // E -2
									5'h0 : KEY_BUFFER[11:8] <= 5'hF; // F -1
								endcase
							end
						else 	KEY_BUFFER[11:8] <= 5'h0;
					end
					input2:begin
						KEY_BUFFER[3:0] <= 4'b0;
						if(PRESS_VALID)	
							begin
								case(SCAN_CODE)
									5'hC : KEY_BUFFER[7:4] <= 5'h0; // 0
									5'hD : KEY_BUFFER[7:4] <= 5'h1; // 1
									5'h9 : KEY_BUFFER[7:4] <= 5'h2; // 2
									5'h5 : KEY_BUFFER[7:4] <= 5'h3; // 3
									5'hE : KEY_BUFFER[7:4] <= 5'h4; // 4
									5'hA : KEY_BUFFER[7:4] <= 5'h5; // 5
									5'h6 : KEY_BUFFER[7:4] <= 5'h6; // 6
									5'hF : KEY_BUFFER[7:4] <= 5'h7; // 7
									5'hB : KEY_BUFFER[7:4] <= 5'h8; // 8 -8 
									5'h7 : KEY_BUFFER[7:4] <= 5'h9; // 9 -7
									5'h8 : KEY_BUFFER[7:4] <= 5'hA; // A -6
									5'h4 : KEY_BUFFER[7:4] <= 5'hB; // B -5
									5'h3 : KEY_BUFFER[7:4] <= 5'hC; // C -4
									5'h2 : KEY_BUFFER[7:4] <= 5'hD; // D -3
									5'h1 : KEY_BUFFER[7:4] <= 5'hE; // E -2
									5'h0 : KEY_BUFFER[7:4] <= 5'hF; // F -1
								endcase
							end
						else 	KEY_BUFFER[7:4] <= 5'h0;
					end
					input3:begin
						if(PRESS_VALID)	
							begin
								case(SCAN_CODE)
									5'hC : KEY_BUFFER[3:0] <= 5'h0; // 0
									5'hD : KEY_BUFFER[3:0] <= 5'h1; // 1
									5'h9 : KEY_BUFFER[3:0] <= 5'h2; // 2
									5'h5 : KEY_BUFFER[3:0] <= 5'h3; // 3
									5'hE : KEY_BUFFER[3:0] <= 5'h4; // 4
									5'hA : KEY_BUFFER[3:0] <= 5'h5; // 5
									5'h6 : KEY_BUFFER[3:0] <= 5'h6; // 6
									5'hF : KEY_BUFFER[3:0] <= 5'h7; // 7
									5'hB : KEY_BUFFER[3:0] <= 5'h8; // 8 -8 
									5'h7 : KEY_BUFFER[3:0] <= 5'h9; // 9 -7
									5'h8 : KEY_BUFFER[3:0] <= 5'hA; // A -6
									5'h4 : KEY_BUFFER[3:0] <= 5'hB; // B -5
									5'h3 : KEY_BUFFER[3:0] <= 5'hC; // C -4
									5'h2 : KEY_BUFFER[3:0] <= 5'hD; // D -3
									5'h1 : KEY_BUFFER[3:0] <= 5'hE; // E -2
									5'h0 : KEY_BUFFER[3:0] <= 5'hF; // F -1
								endcase
							end
						else 	KEY_BUFFER[3:0] <= 5'h0;
					end
					input4:begin
					end
					minus:begin
						if(level!=3'd1 && level!=3'd4)	
							chances <= chances-1'b1;
						else
							chances <= chances;
						a <= KEY_BUFFER[15:12];
						b <= KEY_BUFFER[11:8];
						c <= KEY_BUFFER[7:4];
						d <= KEY_BUFFER[3:0];
					end
					win:begin
					
					end
					XAYB:begin
					
					end
					fail:begin
					
					end
					default: KEY_BUFFER <= 16'b0;
				endcase
			end
		end
		
	/*********************************************************
	* check_answer function *
	*********************************************************/
	always@(negedge clk_15 or negedge S1_reset)begin
		if(!S1_reset) begin
			X<=3'd5; //5A
			Y<=3'd5; //5B
			answer_flag<=1'b0;
		end
		else if(state==check_answer)begin//*判斷XAYB*//
			/**4A**/
						if({a,b,c,d}=={ans3,ans2,ans1,ans0})begin//abcd
							answer_flag<=1'b1;
							X<=3'd4; //4A
							Y<=3'd0; //0B
						end
			/**3A**/
						else if( (a==ans3&&b==ans2&&c==ans1) || //abc_
								 ({a,b,d}=={ans3,ans2,ans0}) || //ab_d
								 ({a,c,d}=={ans3,ans1,ans0}) || //a_cd
								 ({b,c,d}=={ans2,ans1,ans0})    //_bcd
								)begin
							answer_flag<=2'd2;
							X<=3'd3; //3A
							Y<=3'd0; //0B
						end
			/**2A**/
						else if({a,b}=={ans3,ans2})begin//ab__
							answer_flag<=2'd2;
							X<=3'd2; //2A
							if({c,d}=={ans0,ans1})		Y<=3'd2; //2B
							else if(c==ans0||d==ans1)		Y<=3'd1; //1B		
							else													Y<=3'd0; //0B
						end
						else if({a,c}=={ans3,ans1})begin//a_c_
							answer_flag<=2'd2;
							X<=3'd2; //2A						
							if( {b,d}=={ans0,ans2})		Y<=3'd2; //2B
							else if(b==ans0||d==ans2)	Y<=3'd1; //1B		
							else													Y<=3'd0; //0B
						end
						else if({a,d}=={ans3,ans0})begin//a__d
							answer_flag<=2'd2;
							X<=3'd2; //2A							
							if( {b,c}=={ans1,ans2})		Y<=3'd2; //2B
							else if(b==ans1||c==ans2)	Y<=3'd1; //1B		
							else													Y<=3'd0; //0B
						end
						else if({b,c}=={ans2,ans1})begin//_bc_
							answer_flag<=2'd2;
							X<=3'd2; //2A			
							if( {a,d}== {ans0,ans3})	Y<=3'd2; //2B
							else if(a==ans0||d==ans3)	Y<=3'd1; //1B		
							else					Y<=3'd0; //0B
						end
						else if({b,d}=={ans2,ans0})begin//_b_d
							answer_flag<=2'd2;
							X<=3'd2; //2A			
							if({a,c}== {ans1,ans3})		Y<=3'd2; //2B
							else if(a==ans1||c==ans3)	Y<=3'd1; //1B		
							else													Y<=3'd0; //0B
						end
						else if({c,d}=={ans1,ans0})begin//__cd
							answer_flag<=2'd2;
							X<=3'd2; //2A				//__cd	
							if({b,a}== {ans3,ans2})	Y<=3'd2; //2B
							else if(b==ans3||a==ans2)	Y<=3'd1; //1B		
							else													Y<=3'd0; //0B
						end

			/***1A***/
						else if(a==ans3)begin //a___
							answer_flag<=2'd2;
							X<=3'd1; //1A							
							if(( {c,d,b}=={ans2,ans1,ans0})||({d,b,c}=={ans2,ans1,ans0})) 
								Y<=3'd3; //3B
							else if(((b==ans1||b==ans0)&&(c==ans2||c==ans0))||((b==ans1||b==ans0)&&(d==ans2||d==ans1))||((d==ans1||d==ans2)&&(c==ans2||c==ans0))) 
								Y<=3'd2; //2B
							else if( b==ans1||b==ans0||c==ans2||c==ans0||d==ans1||d==ans2 ) 
								Y<=3'd1; //1B
							else	
								Y<=3'd0; //0B
						end
						else if(b==ans2)begin //_b__ 
							answer_flag<=2'd2;
							X<=3'd1; //1A			
							if(( {c,d,a}== {ans3,ans1,ans0})||( {d,a,c}== {ans3,ans1,ans0})) 
								Y<=3'd3; //3B
							else if(((a==ans1||a==ans0)&&(c==ans3||c==ans0))||((a==ans1||a==ans0)&&(d==ans3||d==ans1))||((d==ans1||d==ans3)&&(c==ans3||c==ans0))) 
								Y<=3'd2; //2B
							else if( a==ans1||a==ans0||c==ans3||c==ans0||d==ans1||d==ans3 ) 
								Y<=3'd1; //1B
							else	
								Y<=3'd0; //0B			
						end
						else if(c==ans1)begin //__c_		
							answer_flag<=2'd2;
							X<=3'd1; //1A				
							if(( {b,d,a}== {ans3,ans2,ans0})||( {d,a,b}== {ans3,ans2,ans0})) 
								Y<=3'd3; //3B
							else if(((a==ans2||a==ans0)&&(b==ans3||b==ans0))||((a==ans2||a==ans0)&&(d==ans3||d==ans2))||((d==ans2||d==ans3)&&(b==ans3||b==ans0))) 
								Y<=3'd2; //2B
							else if( a==ans2||a==ans0||b==ans3||b==ans0||d==ans2||d==ans3 ) 
								Y<=3'd1; //1B
							else	
								Y<=3'd0; //0B
						end
						else if(d==ans0)begin //___d
							answer_flag<=2'd2;
							X<=3'd1; //1A						
							if(( {c,b,a}== {ans3,ans1,ans2})||( {b,a,c}== {ans3,ans1,ans2})) 
								Y<=3'd3; //3B
							else if(((a==ans1||a==ans2)&&(c==ans3||c==ans2))||((a==ans1||a==ans2)&&(b==ans3||b==ans1))||((b==ans1||b==ans3)&&(c==ans3||c==ans2))) 
								Y<=3'd2; //2B
							else if( a==ans1||a==ans2||c==ans3||c==ans2||b==ans1||b==ans3 ) 
								Y<=3'd1; //1B
							else	
								Y<=3'd0; //0B
						end
			/***0A***/
						else begin //____
							answer_flag<=2'd2;
							X<=3'd0; //0A
							if({a,b,c,d}=={ans2,ans3,ans0,ans1}|| {a,b,c,d}=={ans2,ans1,ans0,ans3}|| 
								{a,b,c,d}=={ans2,ans0,ans3,ans1}|| {a,b,c,d}=={ans1,ans3,ans0,ans2}||
								{a,b,c,d}=={ans1,ans0,ans3,ans2}||	{a,b,c,d}=={ans1,ans0,ans2,ans3}||
								{a,b,c,d}=={ans0,ans3,ans2,ans1}||	{a,b,c,d}=={ans0,ans1,ans3,ans2}||
								{a,b,c,d}=={ans0,ans1,ans2,ans3} ) 
								Y<=3'd4; //4B
							else if( {a,b,c}=={ans2,ans3,ans0}||{a,b,c}=={ans2,ans1,ans0} 
								|| {a,b,c}=={ans2,ans0,ans3}||{a,b,c}=={ans1,ans3,ans0} 
								|| {a,b,c}=={ans1,ans0,ans3}||{a,b,c}=={ans1,ans0,ans2} 
								|| {a,b,c}=={ans0,ans3,ans2}||{a,b,c}=={ans0,ans1,ans3} 
								|| {a,b,c}=={ans0,ans1,ans2} 
								|| {a,b,d}=={ans2,ans3 ,ans1}
								|| {a,b,d}=={ans2,ans1 ,ans3}
								|| {a,b,d}=={ans2,ans0 ,ans1}
								|| {a,b,d}=={ans1,ans3 ,ans2}
								|| {a,b,d}=={ans1,ans0 ,ans2}
								|| {a,b,d}=={ans1,ans0 ,ans3}
								|| {a,b,d}=={ans0,ans3 ,ans1}
								|| {a,b,d}=={ans0,ans1 ,ans2}
								|| {a,b,d}=={ans0,ans1 ,ans3}
								|| {a,c,d}=={ans2 ,ans0,ans1}
								|| {a,c,d}=={ans2 ,ans0,ans3}
								|| {a,c,d}=={ans2 ,ans3,ans1}
								|| {a,c,d}=={ans1 ,ans0,ans2}
								|| {a,c,d}=={ans1 ,ans3,ans2}
								|| {a,c,d}=={ans1 ,ans2,ans3}
								|| {a,c,d}=={ans0 ,ans2,ans1}
								|| {a,c,d}=={ans0 ,ans3,ans2}
								|| {a,c,d}=={ans0 ,ans2,ans3}
								|| {b,c,d}== {ans3,ans0,ans1}||{b,c,d}== {ans1,ans0,ans3}
								|| {b,c,d}== {ans0,ans3,ans1}||{b,c,d}== {ans3,ans0,ans2}
								|| {b,c,d}== {ans0,ans3,ans2}||{b,c,d}== {ans0,ans2,ans3}
								|| {b,c,d}== {ans3,ans2,ans1}||{b,c,d}== {ans1,ans3,ans2}
								|| {b,c,d}== {ans1,ans2,ans3} ) 
								Y<=3'd3; //3B
							else if(((a==ans2||a==ans1||a==ans0)&&(b==ans3||b==ans1||b==ans0))||
								((a==ans2||a==ans1||a==ans0)&&(c==ans2||c==ans3||c==ans0))||
								((a==ans2||a==ans1||a==ans0)&&(d==ans2||d==ans1||d==ans3))||
								((b==ans3||b==ans1||b==ans0)&&(c==ans2||c==ans3||c==ans0))||
								((b==ans3||b==ans1||b==ans0)&&(d==ans2||d==ans1||d==ans3))||
								((c==ans2||c==ans3||c==ans0)&&(d==ans2||d==ans1||d==ans3)) )		
								Y<=3'd2; //2B

							else if(a==ans2||a==ans1||a==ans0||
									b==ans3||b==ans1||b==ans0||
									c==ans2||c==ans3||c==ans0||
									d==ans2||d==ans1||d==ans3 )
								Y<=3'd1; //1B
							else
								Y<=3'd0; //0B
						end
		end	
	end
/*/////////////////////////////////////////////////////////////////////////////////////////////////*/

/*********************************************************
				* Press answer *
					亂數產生
*********************************************************/
	always@(posedge clk_15 or negedge S1_reset)begin
			if(!S1_reset)begin
				ans0<=4'd0; 
				ans1<=4'd1; 
				ans2<=4'd2; 
				ans3<=4'd3;
			end	
			/**按下KEY才會得到新答案**/
			else if(PRESS_VALID) begin 
				case(state)
					guess0_9:begin
							ans0<=tempans0;
							ans1<=tempans1;
							ans2<=tempans2;
							ans3<=tempans3;
					end
					guess0_F:begin
							ans0<=tempansA0;
							ans1<=tempansA1;
							ans2<=tempansA2;
							ans3<=tempansA3;
					end
				endcase
			end
		end
		
/*********************************************************
			*	 Debounce Circuit *
				PRESS 顯示0~9亂數
				PRESSAF 顯示0~15亂數
*********************************************************/
	always@(posedge clk or negedge S1_reset) begin
		if(!S1_reset)begin
			shift_S2 <= 5'h0;
			shift_S3 <= 5'h0;
			shift_S4 <= 5'h0;
			shift_S5 <= 5'h0;
			shift_S6 <= 5'h0;
			shift_S7 <= 5'h0;
			shift_S8 <= 5'h0;
		end
		else begin
			shift_S2[7:1] <= shift_S2[6:0];
			shift_S2[0] <= S2;
			shift_S3[7:1] <= shift_S3[6:0];
			shift_S3[0] <= S3;
			shift_S4[7:1] <= shift_S4[6:0];
			shift_S4[0] <= S4;
			shift_S5[7:1] <= shift_S5[6:0];
			shift_S5[0] <= S5;
			shift_S6[7:1] <= shift_S6[6:0];
			shift_S6[0] <= S6;
			shift_S7[7:1] <= shift_S7[6:0];
			shift_S7[0] <= S7;
			shift_S8[7:1] <= shift_S8[6:0];
			shift_S8[0] <= S8;
		end
	end
	assign DB_S2= ((shift_S2== 8'b00000000) ? 1'b0 : 1'b1);
	assign DB_S3= ((shift_S3== 8'b00000000) ? 1'b0 : 1'b1);
	assign DB_S4= ((shift_S4== 8'b00000000) ? 1'b0 : 1'b1);
	assign DB_S5= ((shift_S5== 8'b00000000) ? 1'b0 : 1'b1);
	assign DB_S6= ((shift_S6== 8'b00000000) ? 1'b0 : 1'b1);
	assign DB_S7= ((shift_S7== 8'b00000000) ? 1'b0 : 1'b1);
	assign DB_S8= ((shift_S8== 8'b00000000) ? 1'b0 : 1'b1);
	
/*********************************************************
			*	number counter 0~9	*
				0~9亂數計數器
**********************************************************/	
	always@(posedge clk or negedge S1_reset)begin
		if(!S1_reset)begin
			b0<=4'd0 ; b1<=4'd1 ; b2<=4'd2 ; b3<=4'd3;
			tempans0<=4'd0 ; tempans1<=4'd1 ; tempans2<=4'd2 ; tempans3<=4'd3;
		end
		else begin
			//已經用過最後一種可能答案了
			if(b0==4'd9 && b1==4'd8 && b2==4'd7 && b3==4'd7)begin
				b0<=4'd0 ; b1<=4'd1 ; b2<=4'd2 ; b3<=4'd3;
			end
			else if(b0<4'd10)begin
				if(b1<4'd10)begin
					if(b2<4'd10)begin
						if(b3<4'd10)begin
							if(b0!=b1 && b0!=b2 && b0!=b3 && b1!=b2 && b1!=b3 && b2!=b3)begin
								tempans0<=b0;
								tempans1<=b1;
								tempans2<=b2;
								tempans3<=b3;
							end	
							b3<=b3+1;
						end
						else begin
						//當小於前一位數加到10時，前一位歸零，這一位加1
							b3<=4'd0;
							b2<=b2+1;
						end
					end
					else begin
						b2<=4'd0;
						b1<=b1+1;
					end
				end
				else begin
					b1<=4'd0;
					b0<=b0+1;
				end
			end
			else begin//最高位加到10時，回歸第一種可能
				b0<=4'd0 ; b1<=4'd1 ; b2<=4'd2 ; b3<=4'd3;
			end
		end
	end
	
/*********************************************************
			*	number counter 0~9+A~F	 *
				0~15亂數計數器	
**********************************************************/	
	always@(posedge clk or negedge S1_reset)begin	
		if(!S1_reset)begin
			a0<=5'd0 ; a1<=5'd1 ; a2<=5'd2 ; a3<=5'd3;
			tempansA0<=5'd0 ; tempansA1<=5'd1 ; tempansA2<=5'd2 ; tempansA3<=5'd3;
		end
		else begin
			//已經用過最後一種可能答案了
			if(a0==5'd9 && a1==5'd8 && a2==5'd7 && a3==5'd7)begin
				a0<=5'd0 ; a1<=5'd1 ; a2<=5'd2 ; a3<=5'd3;
			end
			else if(a0<5'd16)begin
				if(a1<5'd16)begin
					if(a2<5'd16)begin
						if(a3<5'd16)begin
							if(a0!=a1 && a0!=a2 && a0!=a3 && a1!=a2 && a1!=a3 && a2!=a3)begin
								tempansA0<=a0;
								tempansA1<=a1;
								tempansA2<=a2;
								tempansA3<=a3;
							end	
							a3<=a3+1;
						end
						else begin
						//當小於前一位數加到10時，前一位歸零，這一位加1
							a3<=5'd0;
							a2<=a2+1;
						end
					end
					else begin
						a2<=5'd0;
						a1<=a1+1;
					end
				end
				else begin
					a1<=5'd0;
					a0<=a0+1;
				end
			end
			else begin//最高位加到10時，回歸第一種可能
				a0<=5'd0 ; a1<=5'd1 ; a2<=5'd2 ; a3<=5'd3;
			end
		end
	end
/*********************************************************
				* LED *
*********************************************************/
		always@(posedge clk or negedge S1_reset)begin
			if(!S1_reset)
				LED <= 16'b1111111111111111;//all light
			else if(state>choose_level)begin
				case(chances)
					5'd0: LED <= 16'b0000000000000000;
					5'd1: LED <= 16'b0000000000000001;
					5'd2: LED <= 16'b0000000000000011;
					5'd3: LED <= 16'b0000000000000111;
					5'd4: LED <= 16'b0000000000001111;
					5'd5: LED <= 16'b0000000000011111;
					5'd6: LED <= 16'b0000000000111111;
					5'd7: LED <= 16'b0000000001111111;
					5'd8: LED <= 16'b0000000011111111;
					5'd9: LED <= 16'b0000000111111111;
					5'd10: LED <= 16'b0000001111111111;
					5'd11: LED <= 16'b0000011111111111;
					5'd12: LED <= 16'b0000111111111111;
					5'd13: LED <= 16'b0001111111111111;
					5'd14: LED <= 16'b0011111111111111;
					5'd15: LED <= 16'b0111111111111111;
					5'd16: LED <= 16'b1111111111111111;
				default: LED <= 16'b1111111111111111;
				endcase
			end	
			else
				LED <= 16'b0000000000000000;
		end
/*********************************************************
				*	data display	*
					四個分別顯示
**********************************************************/
	always@(*) begin
		if(!DB_S7 && state>input3 )begin//按下顯示答案
			case(DIGIT)
				4'b0111: BCD=ans3;
				4'b1011: BCD=ans2;
				4'b1101: BCD=ans1;
				4'b1110: BCD=ans0;
				default: BCD=5'd0;
			endcase
		end
		else if(state==choose_level)begin
			case(DIGIT)
				4'b0111: BCD=5'd19;//L
				4'b1011: BCD=5'd21;//v
				4'b1101: BCD=5'd0;
				4'b1110: BCD=level;
				default: BCD=5'd20;
			endcase
		end
		else if(state==guess0_9)begin
			case(DIGIT)
				4'b0111: BCD=5'd0; //0
				4'b1011: BCD=5'd22;//-
				4'b1101: BCD=5'd22;//-
				4'b1110: BCD=5'd9; //9
				default: BCD=5'd20;
			endcase
		end
		else if(state==guess0_F)begin
			case(DIGIT)
				4'b0111: BCD=5'd0; //0
				4'b1011: BCD=5'd9; //9
				4'b1101: BCD=5'd10;//A
				4'b1110: BCD=5'd15;//F
				default: BCD=5'd20;
			endcase
		end
		else if(state==XAYB)begin
			case(DIGIT)
				4'b0111: BCD=X;
				4'b1011: BCD=5'hA;
				4'b1101: BCD=Y;
				4'b1110: BCD=5'hB;
				default: BCD=5'd0;
		endcase
		end
		else if(state==win) begin
			case(DIGIT)
				4'b0111: BCD=5'd16; //W
				4'b1011: BCD=5'd17; //I
				4'b1101: BCD=5'd18; //N
				4'b1110: BCD=5'd20;
				default: BCD=5'd20;
			endcase
		end
		else if(state==fail) begin
			case(DIGIT)
				4'b0111: BCD=5'hF;//F
				4'b1011: BCD=5'hA;//A
				4'b1101: BCD=5'd17;//I
				4'b1110: BCD=5'd19;//L
				default: BCD=5'd20;
			endcase
		end
		else begin
			case(DIGIT)
				4'b0111: BCD=KEY_BUFFER[15:12];
				4'b1011: BCD=KEY_BUFFER[11:8];
				4'b1101: BCD=KEY_BUFFER[7:4];
				4'b1110: BCD=KEY_BUFFER[3:0];
				default: BCD=5'd20;
			endcase
		end
	end

/*********************************************************
				*	enale DIGIT 	*
				   四個輪流亮起來	
**********************************************************/
	always@(posedge clk_15 or negedge S1_reset)begin
		if (!S1_reset)
			DIGIT <= 4'b0000;
		else begin
			case(state)
				input0:DIGIT<=4'b1111;
				input1:DIGIT<=4'b0111;
				input2:begin
					case(DIGIT)
						4'b0111: DIGIT<=4'b1011;
						4'b1011: DIGIT<=4'b0111;
						default: DIGIT<={DIGIT[2],DIGIT[3],1,1};
					endcase
				end
				input3:begin
					case(DIGIT)
						4'b0111: DIGIT<=4'b1011;
						4'b1011: DIGIT<=4'b1101;
						4'b1101: DIGIT<=4'b0111;
						default: DIGIT<={DIGIT[2],DIGIT[1],DIGIT[3],1};
					endcase
				end
				default:begin
					case(DIGIT)
						4'b0000: DIGIT<=4'b0111;
						default: DIGIT<={DIGIT[2],DIGIT[1],DIGIT[0],DIGIT[3]};
					endcase
				end
			endcase
		end
	end
	
/*********************************************************
					seven segment
**********************************************************/
	always@(BCD) begin
			case(BCD)
				5'h0 : DISPLAY = 15'b111111100000011;//0
				5'h1 : DISPLAY = 15'b111111110011111;//1
				5'h2 : DISPLAY = 15'b111111100100100;//2
				5'h3 : DISPLAY = 15'b111111100001100;//3
				5'h4 : DISPLAY = 15'b111111110011000;//4
				5'h5 : DISPLAY = 15'b111111101001000;//5
				5'h6 : DISPLAY = 15'b111111101000000;//6
				5'h7 : DISPLAY = 15'b111111100011111;//7
				5'h8 : DISPLAY = 15'b111111100000000;//8
				5'h9 : DISPLAY = 15'b111111100011000;//9
				5'hA : DISPLAY = 15'b111111100010000;//A
				5'hB : DISPLAY = 15'b111111111000000;//B
				5'hC : DISPLAY = 15'b111111101100011;//C
				5'hD : DISPLAY = 15'b111111110000100;//D
				5'hE : DISPLAY = 15'b111111101100000;//E
				5'hF : DISPLAY = 15'b111111101110000;//F
				5'd16: DISPLAY = 15'b101011110010011;//W
				5'd17: DISPLAY = 15'b110110101101111;//I
				5'd18: DISPLAY = 15'b101111010010011;//N
				5'd19: DISPLAY = 15'b111111111100011;//L
				5'd21: DISPLAY = 15'b111111111000111;//V
				5'd22: DISPLAY = 15'b111111111111100;//-
				5'd20: DISPLAY = 15'b111111111111111;//NULL
				default:DISPLAY = 15'b111111100000011;//0
			endcase
	end
	
/*********************************************************
					* Display Patterns *
**********************************************************/
	always@(INDEX)begin
		if(state==guess0_9 || state==guess0_F || state==input3)begin//pic1
			case(X_PAGE)		
			3'o0: begin //0
			case(INDEX)
			8'h0 : PATTERN = 8'hF;
			8'h1 : PATTERN = 8'h01;
			8'h2 : PATTERN = 8'h01;
			8'h3 : PATTERN = 8'h01;
			8'h4 : PATTERN = 8'h01;
			8'h5 : PATTERN = 8'h01;
			8'h6 : PATTERN = 8'h01;
			8'h7 : PATTERN = 8'h01;
			8'h8 : PATTERN = 8'h01;
			8'h9 : PATTERN = 8'h01;
			8'ha : PATTERN = 8'h01;
			8'hb : PATTERN = 8'h01;
			8'hc : PATTERN = 8'h01;
			8'hd : PATTERN = 8'h01;
			8'he : PATTERN = 8'h81;
			8'hf : PATTERN = 8'h81;
			8'h10 : PATTERN = 8'h81;
			8'h11 : PATTERN = 8'h81;
			8'h12 : PATTERN = 8'h81;
			8'h13 : PATTERN = 8'h81;
			8'h14 : PATTERN = 8'h01;
			8'h15 : PATTERN = 8'h01;
			8'h16 : PATTERN = 8'h81;
			8'h17 : PATTERN = 8'h81;
			8'h18 : PATTERN = 8'h81;
			8'h19 : PATTERN = 8'h81;
			8'h1a : PATTERN = 8'h81;
			8'h1b : PATTERN = 8'h01;
			8'h1c : PATTERN = 8'h01;
			8'h1d : PATTERN = 8'h01;
			8'h1e : PATTERN = 8'h81;
			8'h1f : PATTERN = 8'h81;
			8'h20 : PATTERN = 8'h81;
			8'h21 : PATTERN = 8'h81;
			8'h22 : PATTERN = 8'h81;
			8'h23 : PATTERN = 8'h01;
			8'h24 : PATTERN = 8'h01;
			8'h25 : PATTERN = 8'h01;
			8'h26 : PATTERN = 8'h81;
			8'h27 : PATTERN = 8'h81;
			8'h28 : PATTERN = 8'h81;
			8'h29 : PATTERN = 8'h81;
			8'h2a : PATTERN = 8'h01;
			8'h2b : PATTERN = 8'h01;
			8'h2c : PATTERN = 8'h01;
			8'h2d : PATTERN = 8'h81;
			8'h2e : PATTERN = 8'h81;
			8'h2f : PATTERN = 8'h81;
			8'h30 : PATTERN = 8'h81;
			8'h31 : PATTERN = 8'h01;
			8'h32 : PATTERN = 8'h01;
			8'h33 : PATTERN = 8'h01;
			8'h34 : PATTERN = 8'h01;
			8'h35 : PATTERN = 8'h01;
			8'h36 : PATTERN = 8'h01;
			8'h37 : PATTERN = 8'h01;
			8'h38 : PATTERN = 8'h01;
			8'h39 : PATTERN = 8'h01;
			8'h3a : PATTERN = 8'h01;
			8'h3b : PATTERN = 8'h01;
			8'h3c : PATTERN = 8'h01;
			8'h3d : PATTERN = 8'h01;
			8'h3e : PATTERN = 8'h01;
			8'h3f : PATTERN = 8'h01;
			8'h40 : PATTERN = 8'h01;
			8'h41 : PATTERN = 8'h01;
			8'h42 : PATTERN = 8'h01;
			8'h43 : PATTERN = 8'h01;
			8'h44 : PATTERN = 8'h01;
			8'h45 : PATTERN = 8'h01;
			8'h46 : PATTERN = 8'h01;
			8'h47 : PATTERN = 8'h01;
			8'h48 : PATTERN = 8'h01;
			8'h49 : PATTERN = 8'h01;
			8'h4a : PATTERN = 8'h01;
			8'h4b : PATTERN = 8'h01;
			8'h4c : PATTERN = 8'h01;
			8'h4d : PATTERN = 8'h01;
			8'h4e : PATTERN = 8'h01;
			8'h4f : PATTERN = 8'h01;
			8'h50 : PATTERN = 8'h01;
			8'h51 : PATTERN = 8'h01;
			8'h52 : PATTERN = 8'h01;
			8'h53 : PATTERN = 8'h01;
			8'h54 : PATTERN = 8'h01;
			8'h55 : PATTERN = 8'h01;
			8'h56 : PATTERN = 8'h01;
			8'h57 : PATTERN = 8'h01;
			8'h58 : PATTERN = 8'h01;
			8'h59 : PATTERN = 8'h01;
			8'h5a : PATTERN = 8'h01;
			8'h5b : PATTERN = 8'h01;
			8'h5c : PATTERN = 8'h01;
			8'h5d : PATTERN = 8'h01;
			8'h5e : PATTERN = 8'h01;
			8'h5f : PATTERN = 8'h01;
			8'h60 : PATTERN = 8'h01;
			8'h61 : PATTERN = 8'h01;
			8'h62 : PATTERN = 8'h01;
			8'h63 : PATTERN = 8'h01;
			8'h64 : PATTERN = 8'h01;
			8'h65 : PATTERN = 8'h01;
			8'h66 : PATTERN = 8'h01;
			8'h67 : PATTERN = 8'h01;
			8'h68 : PATTERN = 8'h01;
			8'h69 : PATTERN = 8'h01;
			8'h6a : PATTERN = 8'h01;
			8'h6b : PATTERN = 8'h01;
			8'h6c : PATTERN = 8'h01;
			8'h6d : PATTERN = 8'h01;
			8'h6e : PATTERN = 8'h01;
			8'h6f : PATTERN = 8'h01;
			8'h70 : PATTERN = 8'h01;
			8'h71 : PATTERN = 8'h01;
			8'h72 : PATTERN = 8'h01;
			8'h73 : PATTERN = 8'h01;
			8'h74 : PATTERN = 8'h01;
			8'h75 : PATTERN = 8'h01;
			8'h76 : PATTERN = 8'h01;
			8'h77 : PATTERN = 8'h01;
			8'h78 : PATTERN = 8'h01;
			8'h79 : PATTERN = 8'h01;
			8'h7a : PATTERN = 8'h01;
			8'h7b : PATTERN = 8'h01;
			8'h7c : PATTERN = 8'h01;
			8'h7d : PATTERN = 8'h01;
			8'h7e : PATTERN = 8'h01;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o1: begin //1
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h00;
			8'h5 : PATTERN = 8'h00;
			8'h6 : PATTERN = 8'h00;
			8'h7 : PATTERN = 8'h00;
			8'h8 : PATTERN = 8'h00;
			8'h9 : PATTERN = 8'h00;
			8'ha : PATTERN = 8'h00;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'h00;
			8'hd : PATTERN = 8'h00;
			8'he : PATTERN = 8'hFF;
			8'hf : PATTERN = 8'hFF;
			8'h10 : PATTERN = 8'h10;
			8'h11 : PATTERN = 8'h10;
			8'h12 : PATTERN = 8'h19;
			8'h13 : PATTERN = 8'h0F;
			8'h14 : PATTERN = 8'h06;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'hFF;
			8'h17 : PATTERN = 8'hFF;
			8'h18 : PATTERN = 8'h08;
			8'h19 : PATTERN = 8'h18;
			8'h1a : PATTERN = 8'h3F;
			8'h1b : PATTERN = 8'hE7;
			8'h1c : PATTERN = 8'hC0;
			8'h1d : PATTERN = 8'h00;
			8'h1e : PATTERN = 8'hFF;
			8'h1f : PATTERN = 8'hFF;
			8'h20 : PATTERN = 8'h88;
			8'h21 : PATTERN = 8'h88;
			8'h22 : PATTERN = 8'h88;
			8'h23 : PATTERN = 8'h80;
			8'h24 : PATTERN = 8'h00;
			8'h25 : PATTERN = 8'hCF;
			8'h26 : PATTERN = 8'h8D;
			8'h27 : PATTERN = 8'h98;
			8'h28 : PATTERN = 8'h98;
			8'h29 : PATTERN = 8'hF1;
			8'h2a : PATTERN = 8'h60;
			8'h2b : PATTERN = 8'h00;
			8'h2c : PATTERN = 8'hCF;
			8'h2d : PATTERN = 8'h8D;
			8'h2e : PATTERN = 8'h98;
			8'h2f : PATTERN = 8'h98;
			8'h30 : PATTERN = 8'hF1;
			8'h31 : PATTERN = 8'h60;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'h00;
			8'h34 : PATTERN = 8'h00;
			8'h35 : PATTERN = 8'h00;
			8'h36 : PATTERN = 8'h00;
			8'h37 : PATTERN = 8'h00;
			8'h38 : PATTERN = 8'h00;
			8'h39 : PATTERN = 8'h00;
			8'h3a : PATTERN = 8'h00;
			8'h3b : PATTERN = 8'h00;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'h00;
			8'h40 : PATTERN = 8'h00;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h00;
			8'h47 : PATTERN = 8'h00;
			8'h48 : PATTERN = 8'h00;
			8'h49 : PATTERN = 8'h00;
			8'h4a : PATTERN = 8'h00;
			8'h4b : PATTERN = 8'h00;
			8'h4c : PATTERN = 8'h00;
			8'h4d : PATTERN = 8'h80;
			8'h4e : PATTERN = 8'hC0;
			8'h4f : PATTERN = 8'hC0;
			8'h50 : PATTERN = 8'hC0;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h00;
			8'h53 : PATTERN = 8'h00;
			8'h54 : PATTERN = 8'h00;
			8'h55 : PATTERN = 8'h00;
			8'h56 : PATTERN = 8'h00;
			8'h57 : PATTERN = 8'h00;
			8'h58 : PATTERN = 8'h80;
			8'h59 : PATTERN = 8'hC0;
			8'h5a : PATTERN = 8'hC0;
			8'h5b : PATTERN = 8'h80;
			8'h5c : PATTERN = 8'h00;
			8'h5d : PATTERN = 8'h00;
			8'h5e : PATTERN = 8'h00;
			8'h5f : PATTERN = 8'h00;
			8'h60 : PATTERN = 8'h00;
			8'h61 : PATTERN = 8'h00;
			8'h62 : PATTERN = 8'h00;
			8'h63 : PATTERN = 8'h00;
			8'h64 : PATTERN = 8'h00;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h00;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'h00;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o2: begin //2
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h80;
			8'h5 : PATTERN = 8'hC0;
			8'h6 : PATTERN = 8'h40;
			8'h7 : PATTERN = 8'h40;
			8'h8 : PATTERN = 8'hC0;
			8'h9 : PATTERN = 8'h80;
			8'ha : PATTERN = 8'h00;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'h00;
			8'hd : PATTERN = 8'h00;
			8'he : PATTERN = 8'hC0;
			8'hf : PATTERN = 8'hC0;
			8'h10 : PATTERN = 8'hC0;
			8'h11 : PATTERN = 8'h00;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h00;
			8'h14 : PATTERN = 8'h00;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h00;
			8'h1a : PATTERN = 8'h80;
			8'h1b : PATTERN = 8'hC0;
			8'h1c : PATTERN = 8'h40;
			8'h1d : PATTERN = 8'h40;
			8'h1e : PATTERN = 8'hC0;
			8'h1f : PATTERN = 8'h80;
			8'h20 : PATTERN = 8'h00;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'hC0;
			8'h23 : PATTERN = 8'hC0;
			8'h24 : PATTERN = 8'h40;
			8'h25 : PATTERN = 8'h40;
			8'h26 : PATTERN = 8'h40;
			8'h27 : PATTERN = 8'h40;
			8'h28 : PATTERN = 8'h40;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'hC0;
			8'h2b : PATTERN = 8'hC0;
			8'h2c : PATTERN = 8'hC0;
			8'h2d : PATTERN = 8'h80;
			8'h2e : PATTERN = 8'h00;
			8'h2f : PATTERN = 8'h00;
			8'h30 : PATTERN = 8'hC0;
			8'h31 : PATTERN = 8'hC0;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'hC0;
			8'h34 : PATTERN = 8'hC0;
			8'h35 : PATTERN = 8'h40;
			8'h36 : PATTERN = 8'h40;
			8'h37 : PATTERN = 8'hC0;
			8'h38 : PATTERN = 8'hC0;
			8'h39 : PATTERN = 8'h80;
			8'h3a : PATTERN = 8'h00;
			8'h3b : PATTERN = 8'h00;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'h00;
			8'h40 : PATTERN = 8'h00;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h8C;
			8'h47 : PATTERN = 8'h8C;
			8'h48 : PATTERN = 8'h8C;
			8'h49 : PATTERN = 8'hC8;
			8'h4a : PATTERN = 8'hD8;
			8'h4b : PATTERN = 8'h78;
			8'h4c : PATTERN = 8'h07;
			8'h4d : PATTERN = 8'h03;
			8'h4e : PATTERN = 8'h81;
			8'h4f : PATTERN = 8'h81;
			8'h50 : PATTERN = 8'h01;
			8'h51 : PATTERN = 8'h03;
			8'h52 : PATTERN = 8'h0C;
			8'h53 : PATTERN = 8'h0C;
			8'h54 : PATTERN = 8'h0C;
			8'h55 : PATTERN = 8'h0C;
			8'h56 : PATTERN = 8'h0C;
			8'h57 : PATTERN = 8'h03;
			8'h58 : PATTERN = 8'h81;
			8'h59 : PATTERN = 8'h83;
			8'h5a : PATTERN = 8'h01;
			8'h5b : PATTERN = 8'h03;
			8'h5c : PATTERN = 8'h07;
			8'h5d : PATTERN = 8'hBC;
			8'h5e : PATTERN = 8'h98;
			8'h5f : PATTERN = 8'h88;
			8'h60 : PATTERN = 8'hCC;
			8'h61 : PATTERN = 8'h8E;
			8'h62 : PATTERN = 8'h8A;
			8'h63 : PATTERN = 8'h78;
			8'h64 : PATTERN = 8'h78;
			8'h65 : PATTERN = 8'h18;
			8'h66 : PATTERN = 8'h18;
			8'h67 : PATTERN = 8'hF0;
			8'h68 : PATTERN = 8'h70;
			8'h69 : PATTERN = 8'h20;
			8'h6a : PATTERN = 8'h40;
			8'h6b : PATTERN = 8'hC0;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o3: begin //3
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h10;
			8'h4 : PATTERN = 8'h33;
			8'h5 : PATTERN = 8'h67;
			8'h6 : PATTERN = 8'h44;
			8'h7 : PATTERN = 8'h44;
			8'h8 : PATTERN = 8'h6D;
			8'h9 : PATTERN = 8'h39;
			8'ha : PATTERN = 8'h10;
			8'hb : PATTERN = 8'h10;
			8'hc : PATTERN = 8'h1C;
			8'hd : PATTERN = 8'h17;
			8'he : PATTERN = 8'h11;
			8'hf : PATTERN = 8'h7F;
			8'h10 : PATTERN = 8'h7F;
			8'h11 : PATTERN = 8'h10;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h63;
			8'h14 : PATTERN = 8'h63;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h10;
			8'h1a : PATTERN = 8'h33;
			8'h1b : PATTERN = 8'h67;
			8'h1c : PATTERN = 8'h44;
			8'h1d : PATTERN = 8'h44;
			8'h1e : PATTERN = 8'h6D;
			8'h1f : PATTERN = 8'h39;
			8'h20 : PATTERN = 8'h10;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'h7F;
			8'h23 : PATTERN = 8'h7F;
			8'h24 : PATTERN = 8'h44;
			8'h25 : PATTERN = 8'h44;
			8'h26 : PATTERN = 8'h44;
			8'h27 : PATTERN = 8'h40;
			8'h28 : PATTERN = 8'h40;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'h7F;
			8'h2b : PATTERN = 8'h7F;
			8'h2c : PATTERN = 8'h01;
			8'h2d : PATTERN = 8'h07;
			8'h2e : PATTERN = 8'h1E;
			8'h2f : PATTERN = 8'h78;
			8'h30 : PATTERN = 8'h7F;
			8'h31 : PATTERN = 8'h7F;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'h7F;
			8'h34 : PATTERN = 8'h7F;
			8'h35 : PATTERN = 8'h40;
			8'h36 : PATTERN = 8'h40;
			8'h37 : PATTERN = 8'h60;
			8'h38 : PATTERN = 8'h71;
			8'h39 : PATTERN = 8'h3F;
			8'h3a : PATTERN = 8'h1F;
			8'h3b : PATTERN = 8'h00;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'h00;
			8'h40 : PATTERN = 8'h00;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h01;
			8'h47 : PATTERN = 8'h00;
			8'h48 : PATTERN = 8'h00;
			8'h49 : PATTERN = 8'h00;
			8'h4a : PATTERN = 8'hFF;
			8'h4b : PATTERN = 8'h06;
			8'h4c : PATTERN = 8'h07;
			8'h4d : PATTERN = 8'h07;
			8'h4e : PATTERN = 8'h01;
			8'h4f : PATTERN = 8'h01;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h02;
			8'h53 : PATTERN = 8'h03;
			8'h54 : PATTERN = 8'h03;
			8'h55 : PATTERN = 8'h02;
			8'h56 : PATTERN = 8'h00;
			8'h57 : PATTERN = 8'h00;
			8'h58 : PATTERN = 8'h01;
			8'h59 : PATTERN = 8'h03;
			8'h5a : PATTERN = 8'h07;
			8'h5b : PATTERN = 8'h0F;
			8'h5c : PATTERN = 8'h06;
			8'h5d : PATTERN = 8'h00;
			8'h5e : PATTERN = 8'h00;
			8'h5f : PATTERN = 8'h00;
			8'h60 : PATTERN = 8'h00;
			8'h61 : PATTERN = 8'h00;
			8'h62 : PATTERN = 8'h00;
			8'h63 : PATTERN = 8'h00;
			8'h64 : PATTERN = 8'h00;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h00;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'h00;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h03;
			8'h6d : PATTERN = 8'h0E;
			8'h6e : PATTERN = 8'hF8;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h80;
			8'h71 : PATTERN = 8'h80;
			8'h72 : PATTERN = 8'h80;
			8'h73 : PATTERN = 8'h80;
			8'h74 : PATTERN = 8'hFF;
			8'h75 : PATTERN = 8'h7F;
			8'h76 : PATTERN = 8'hFD;
			8'h77 : PATTERN = 8'hF1;
			8'h78 : PATTERN = 8'hE3;
			8'h79 : PATTERN = 8'h3F;
			8'h7a : PATTERN = 8'h3F;
			8'h7b : PATTERN = 8'h3F;
			8'h7c : PATTERN = 8'h3F;
			8'h7d : PATTERN = 8'h3F;
			8'h7e : PATTERN = 8'h1F;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o4: begin //4
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h70;
			8'h5 : PATTERN = 8'hF8;
			8'h6 : PATTERN = 8'h88;
			8'h7 : PATTERN = 8'h88;
			8'h8 : PATTERN = 8'hB8;
			8'h9 : PATTERN = 8'h30;
			8'ha : PATTERN = 8'h00;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'hF8;
			8'hd : PATTERN = 8'hC8;
			8'he : PATTERN = 8'h48;
			8'hf : PATTERN = 8'hC8;
			8'h10 : PATTERN = 8'h88;
			8'h11 : PATTERN = 8'h00;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h60;
			8'h14 : PATTERN = 8'h60;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h00;
			8'h1a : PATTERN = 8'hF0;
			8'h1b : PATTERN = 8'hF8;
			8'h1c : PATTERN = 8'h18;
			8'h1d : PATTERN = 8'h08;
			8'h1e : PATTERN = 8'h08;
			8'h1f : PATTERN = 8'h38;
			8'h20 : PATTERN = 8'h30;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'h00;
			8'h23 : PATTERN = 8'hF8;
			8'h24 : PATTERN = 8'hF8;
			8'h25 : PATTERN = 8'h00;
			8'h26 : PATTERN = 8'h00;
			8'h27 : PATTERN = 8'h00;
			8'h28 : PATTERN = 8'h00;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'hF8;
			8'h2b : PATTERN = 8'hF8;
			8'h2c : PATTERN = 8'h88;
			8'h2d : PATTERN = 8'h88;
			8'h2e : PATTERN = 8'h88;
			8'h2f : PATTERN = 8'h08;
			8'h30 : PATTERN = 8'h08;
			8'h31 : PATTERN = 8'h00;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'hE0;
			8'h34 : PATTERN = 8'h78;
			8'h35 : PATTERN = 8'h38;
			8'h36 : PATTERN = 8'hF8;
			8'h37 : PATTERN = 8'h80;
			8'h38 : PATTERN = 8'h00;
			8'h39 : PATTERN = 8'h00;
			8'h3a : PATTERN = 8'hF8;
			8'h3b : PATTERN = 8'hF8;
			8'h3c : PATTERN = 8'h88;
			8'h3d : PATTERN = 8'h88;
			8'h3e : PATTERN = 8'h88;
			8'h3f : PATTERN = 8'hF8;
			8'h40 : PATTERN = 8'h70;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h00;
			8'h47 : PATTERN = 8'h00;
			8'h48 : PATTERN = 8'h00;
			8'h49 : PATTERN = 8'h00;
			8'h4a : PATTERN = 8'h07;
			8'h4b : PATTERN = 8'h18;
			8'h4c : PATTERN = 8'h20;
			8'h4d : PATTERN = 8'hC0;
			8'h4e : PATTERN = 8'h00;
			8'h4f : PATTERN = 8'h80;
			8'h50 : PATTERN = 8'h80;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h00;
			8'h53 : PATTERN = 8'h00;
			8'h54 : PATTERN = 8'h00;
			8'h55 : PATTERN = 8'h00;
			8'h56 : PATTERN = 8'h00;
			8'h57 : PATTERN = 8'h00;
			8'h58 : PATTERN = 8'h00;
			8'h59 : PATTERN = 8'h00;
			8'h5a : PATTERN = 8'h00;
			8'h5b : PATTERN = 8'h00;
			8'h5c : PATTERN = 8'h00;
			8'h5d : PATTERN = 8'h00;
			8'h5e : PATTERN = 8'h00;
			8'h5f : PATTERN = 8'h00;
			8'h60 : PATTERN = 8'h00;
			8'h61 : PATTERN = 8'h00;
			8'h62 : PATTERN = 8'h00;
			8'h63 : PATTERN = 8'h00;
			8'h64 : PATTERN = 8'h00;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h00;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'h80;
			8'h6b : PATTERN = 8'h60;
			8'h6c : PATTERN = 8'h30;
			8'h6d : PATTERN = 8'h0E;
			8'h6e : PATTERN = 8'h07;
			8'h6f : PATTERN = 8'h07;
			8'h70 : PATTERN = 8'h07;
			8'h71 : PATTERN = 8'h04;
			8'h72 : PATTERN = 8'h07;
			8'h73 : PATTERN = 8'h07;
			8'h74 : PATTERN = 8'h07;
			8'h75 : PATTERN = 8'h07;
			8'h76 : PATTERN = 8'h02;
			8'h77 : PATTERN = 8'h02;
			8'h78 : PATTERN = 8'h03;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o5: begin //5
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h02;
			8'h4 : PATTERN = 8'h06;
			8'h5 : PATTERN = 8'h0C;
			8'h6 : PATTERN = 8'h08;
			8'h7 : PATTERN = 8'h08;
			8'h8 : PATTERN = 8'h0D;
			8'h9 : PATTERN = 8'h07;
			8'ha : PATTERN = 8'h02;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'h0C;
			8'hd : PATTERN = 8'h0C;
			8'he : PATTERN = 8'h08;
			8'hf : PATTERN = 8'h0C;
			8'h10 : PATTERN = 8'h07;
			8'h11 : PATTERN = 8'h00;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h0C;
			8'h14 : PATTERN = 8'h0C;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h00;
			8'h1a : PATTERN = 8'h07;
			8'h1b : PATTERN = 8'h0F;
			8'h1c : PATTERN = 8'h0C;
			8'h1d : PATTERN = 8'h08;
			8'h1e : PATTERN = 8'h08;
			8'h1f : PATTERN = 8'h0E;
			8'h20 : PATTERN = 8'h06;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'h00;
			8'h23 : PATTERN = 8'h0F;
			8'h24 : PATTERN = 8'h0F;
			8'h25 : PATTERN = 8'h08;
			8'h26 : PATTERN = 8'h08;
			8'h27 : PATTERN = 8'h08;
			8'h28 : PATTERN = 8'h08;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'h0F;
			8'h2b : PATTERN = 8'h0F;
			8'h2c : PATTERN = 8'h08;
			8'h2d : PATTERN = 8'h08;
			8'h2e : PATTERN = 8'h08;
			8'h2f : PATTERN = 8'h08;
			8'h30 : PATTERN = 8'h08;
			8'h31 : PATTERN = 8'h08;
			8'h32 : PATTERN = 8'h0F;
			8'h33 : PATTERN = 8'h03;
			8'h34 : PATTERN = 8'h01;
			8'h35 : PATTERN = 8'h01;
			8'h36 : PATTERN = 8'h03;
			8'h37 : PATTERN = 8'h0F;
			8'h38 : PATTERN = 8'h0C;
			8'h39 : PATTERN = 8'h00;
			8'h3a : PATTERN = 8'h0F;
			8'h3b : PATTERN = 8'h0F;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h03;
			8'h3f : PATTERN = 8'h0E;
			8'h40 : PATTERN = 8'h0C;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h00;
			8'h47 : PATTERN = 8'h00;
			8'h48 : PATTERN = 8'h00;
			8'h49 : PATTERN = 8'h00;
			8'h4a : PATTERN = 8'h00;
			8'h4b : PATTERN = 8'h00;
			8'h4c : PATTERN = 8'h00;
			8'h4d : PATTERN = 8'h01;
			8'h4e : PATTERN = 8'h03;
			8'h4f : PATTERN = 8'h01;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h01;
			8'h52 : PATTERN = 8'h01;
			8'h53 : PATTERN = 8'h81;
			8'h54 : PATTERN = 8'hE1;
			8'h55 : PATTERN = 8'hFB;
			8'h56 : PATTERN = 8'hFF;
			8'h57 : PATTERN = 8'hFC;
			8'h58 : PATTERN = 8'hFE;
			8'h59 : PATTERN = 8'hFF;
			8'h5a : PATTERN = 8'hFF;
			8'h5b : PATTERN = 8'hFF;
			8'h5c : PATTERN = 8'hFF;
			8'h5d : PATTERN = 8'hFF;
			8'h5e : PATTERN = 8'hFF;
			8'h5f : PATTERN = 8'hFF;
			8'h60 : PATTERN = 8'hFF;
			8'h61 : PATTERN = 8'hFF;
			8'h62 : PATTERN = 8'hFE;
			8'h63 : PATTERN = 8'hF3;
			8'h64 : PATTERN = 8'hE2;
			8'h65 : PATTERN = 8'h02;
			8'h66 : PATTERN = 8'h07;
			8'h67 : PATTERN = 8'h07;
			8'h68 : PATTERN = 8'h06;
			8'h69 : PATTERN = 8'h03;
			8'h6a : PATTERN = 8'h00;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o6: begin //6
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h00;
			8'h5 : PATTERN = 8'h9E;
			8'h6 : PATTERN = 8'h1B;
			8'h7 : PATTERN = 8'h31;
			8'h8 : PATTERN = 8'h31;
			8'h9 : PATTERN = 8'hE3;
			8'ha : PATTERN = 8'hC0;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'hEE;
			8'hd : PATTERN = 8'hBF;
			8'he : PATTERN = 8'h11;
			8'hf : PATTERN = 8'h39;
			8'h10 : PATTERN = 8'hEF;
			8'h11 : PATTERN = 8'hE0;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h8C;
			8'h14 : PATTERN = 8'h8C;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'hFF;
			8'h1a : PATTERN = 8'hFF;
			8'h1b : PATTERN = 8'h11;
			8'h1c : PATTERN = 8'h31;
			8'h1d : PATTERN = 8'h7F;
			8'h1e : PATTERN = 8'hCE;
			8'h1f : PATTERN = 8'h80;
			8'h20 : PATTERN = 8'h00;
			8'h21 : PATTERN = 8'hFF;
			8'h22 : PATTERN = 8'hFF;
			8'h23 : PATTERN = 8'h11;
			8'h24 : PATTERN = 8'h11;
			8'h25 : PATTERN = 8'h11;
			8'h26 : PATTERN = 8'h00;
			8'h27 : PATTERN = 8'h00;
			8'h28 : PATTERN = 8'h9E;
			8'h29 : PATTERN = 8'h1B;
			8'h2a : PATTERN = 8'h31;
			8'h2b : PATTERN = 8'h31;
			8'h2c : PATTERN = 8'hE3;
			8'h2d : PATTERN = 8'hC0;
			8'h2e : PATTERN = 8'h01;
			8'h2f : PATTERN = 8'h01;
			8'h30 : PATTERN = 8'h01;
			8'h31 : PATTERN = 8'hFF;
			8'h32 : PATTERN = 8'h01;
			8'h33 : PATTERN = 8'h01;
			8'h34 : PATTERN = 8'h01;
			8'h35 : PATTERN = 8'h80;
			8'h36 : PATTERN = 8'hE0;
			8'h37 : PATTERN = 8'h38;
			8'h38 : PATTERN = 8'h2F;
			8'h39 : PATTERN = 8'h23;
			8'h3a : PATTERN = 8'h2F;
			8'h3b : PATTERN = 8'h3C;
			8'h3c : PATTERN = 8'hE0;
			8'h3d : PATTERN = 8'h80;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'hFF;
			8'h40 : PATTERN = 8'hFF;
			8'h41 : PATTERN = 8'h11;
			8'h42 : PATTERN = 8'h31;
			8'h43 : PATTERN = 8'h7F;
			8'h44 : PATTERN = 8'hCE;
			8'h45 : PATTERN = 8'h80;
			8'h46 : PATTERN = 8'h01;
			8'h47 : PATTERN = 8'h01;
			8'h48 : PATTERN = 8'h01;
			8'h49 : PATTERN = 8'hFF;
			8'h4a : PATTERN = 8'h01;
			8'h4b : PATTERN = 8'h01;
			8'h4c : PATTERN = 8'h01;
			8'h4d : PATTERN = 8'h00;
			8'h4e : PATTERN = 8'h00;
			8'h4f : PATTERN = 8'h00;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h00;
			8'h53 : PATTERN = 8'h0F;
			8'h54 : PATTERN = 8'h3B;
			8'h55 : PATTERN = 8'h43;
			8'h56 : PATTERN = 8'h83;
			8'h57 : PATTERN = 8'h83;
			8'h58 : PATTERN = 8'h03;
			8'h59 : PATTERN = 8'h07;
			8'h5a : PATTERN = 8'h0F;
			8'h5b : PATTERN = 8'h08;
			8'h5c : PATTERN = 8'h08;
			8'h5d : PATTERN = 8'h08;
			8'h5e : PATTERN = 8'h0F;
			8'h5f : PATTERN = 8'h0F;
			8'h60 : PATTERN = 8'h0F;
			8'h61 : PATTERN = 8'h8F;
			8'h62 : PATTERN = 8'hCF;
			8'h63 : PATTERN = 8'h3F;
			8'h64 : PATTERN = 8'h0F;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h00;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'h00;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o7: begin //7
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h80;
			8'h2 : PATTERN = 8'h80;
			8'h3 : PATTERN = 8'h80;
			8'h4 : PATTERN = 8'h80;
			8'h5 : PATTERN = 8'h81;
			8'h6 : PATTERN = 8'h81;
			8'h7 : PATTERN = 8'h81;
			8'h8 : PATTERN = 8'h81;
			8'h9 : PATTERN = 8'h81;
			8'ha : PATTERN = 8'h80;
			8'hb : PATTERN = 8'h80;
			8'hc : PATTERN = 8'h81;
			8'hd : PATTERN = 8'h81;
			8'he : PATTERN = 8'h81;
			8'hf : PATTERN = 8'h81;
			8'h10 : PATTERN = 8'h81;
			8'h11 : PATTERN = 8'h80;
			8'h12 : PATTERN = 8'h80;
			8'h13 : PATTERN = 8'h81;
			8'h14 : PATTERN = 8'h81;
			8'h15 : PATTERN = 8'h80;
			8'h16 : PATTERN = 8'h80;
			8'h17 : PATTERN = 8'h80;
			8'h18 : PATTERN = 8'h80;
			8'h19 : PATTERN = 8'h81;
			8'h1a : PATTERN = 8'h81;
			8'h1b : PATTERN = 8'h80;
			8'h1c : PATTERN = 8'h80;
			8'h1d : PATTERN = 8'h80;
			8'h1e : PATTERN = 8'h81;
			8'h1f : PATTERN = 8'h81;
			8'h20 : PATTERN = 8'h80;
			8'h21 : PATTERN = 8'h81;
			8'h22 : PATTERN = 8'h81;
			8'h23 : PATTERN = 8'h81;
			8'h24 : PATTERN = 8'h81;
			8'h25 : PATTERN = 8'h81;
			8'h26 : PATTERN = 8'h81;
			8'h27 : PATTERN = 8'h80;
			8'h28 : PATTERN = 8'h81;
			8'h29 : PATTERN = 8'h81;
			8'h2a : PATTERN = 8'h81;
			8'h2b : PATTERN = 8'h81;
			8'h2c : PATTERN = 8'h81;
			8'h2d : PATTERN = 8'h80;
			8'h2e : PATTERN = 8'h80;
			8'h2f : PATTERN = 8'h80;
			8'h30 : PATTERN = 8'h80;
			8'h31 : PATTERN = 8'h81;
			8'h32 : PATTERN = 8'h80;
			8'h33 : PATTERN = 8'h80;
			8'h34 : PATTERN = 8'h80;
			8'h35 : PATTERN = 8'h81;
			8'h36 : PATTERN = 8'h81;
			8'h37 : PATTERN = 8'h80;
			8'h38 : PATTERN = 8'h80;
			8'h39 : PATTERN = 8'h80;
			8'h3a : PATTERN = 8'h80;
			8'h3b : PATTERN = 8'h80;
			8'h3c : PATTERN = 8'h81;
			8'h3d : PATTERN = 8'h81;
			8'h3e : PATTERN = 8'h80;
			8'h3f : PATTERN = 8'h81;
			8'h40 : PATTERN = 8'h81;
			8'h41 : PATTERN = 8'h80;
			8'h42 : PATTERN = 8'h80;
			8'h43 : PATTERN = 8'h80;
			8'h44 : PATTERN = 8'h81;
			8'h45 : PATTERN = 8'h81;
			8'h46 : PATTERN = 8'h80;
			8'h47 : PATTERN = 8'h80;
			8'h48 : PATTERN = 8'h80;
			8'h49 : PATTERN = 8'h81;
			8'h4a : PATTERN = 8'h80;
			8'h4b : PATTERN = 8'h80;
			8'h4c : PATTERN = 8'h80;
			8'h4d : PATTERN = 8'h80;
			8'h4e : PATTERN = 8'h80;
			8'h4f : PATTERN = 8'h80;
			8'h50 : PATTERN = 8'h80;
			8'h51 : PATTERN = 8'h80;
			8'h52 : PATTERN = 8'h80;
			8'h53 : PATTERN = 8'h80;
			8'h54 : PATTERN = 8'h80;
			8'h55 : PATTERN = 8'h80;
			8'h56 : PATTERN = 8'h80;
			8'h57 : PATTERN = 8'h81;
			8'h58 : PATTERN = 8'h81;
			8'h59 : PATTERN = 8'h81;
			8'h5a : PATTERN = 8'h83;
			8'h5b : PATTERN = 8'h82;
			8'h5c : PATTERN = 8'h82;
			8'h5d : PATTERN = 8'h82;
			8'h5e : PATTERN = 8'h81;
			8'h5f : PATTERN = 8'h81;
			8'h60 : PATTERN = 8'h81;
			8'h61 : PATTERN = 8'h80;
			8'h62 : PATTERN = 8'h80;
			8'h63 : PATTERN = 8'h80;
			8'h64 : PATTERN = 8'h80;
			8'h65 : PATTERN = 8'h80;
			8'h66 : PATTERN = 8'h80;
			8'h67 : PATTERN = 8'h80;
			8'h68 : PATTERN = 8'h80;
			8'h69 : PATTERN = 8'h80;
			8'h6a : PATTERN = 8'h80;
			8'h6b : PATTERN = 8'h80;
			8'h6c : PATTERN = 8'h80;
			8'h6d : PATTERN = 8'h80;
			8'h6e : PATTERN = 8'h80;
			8'h6f : PATTERN = 8'h80;
			8'h70 : PATTERN = 8'h80;
			8'h71 : PATTERN = 8'h80;
			8'h72 : PATTERN = 8'h80;
			8'h73 : PATTERN = 8'h80;
			8'h74 : PATTERN = 8'h80;
			8'h75 : PATTERN = 8'h80;
			8'h76 : PATTERN = 8'h80;
			8'h77 : PATTERN = 8'h80;
			8'h78 : PATTERN = 8'h80;
			8'h79 : PATTERN = 8'h80;
			8'h7a : PATTERN = 8'h80;
			8'h7b : PATTERN = 8'h80;
			8'h7c : PATTERN = 8'h80;
			8'h7d : PATTERN = 8'h80;
			8'h7e : PATTERN = 8'h80;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			endcase
		end
		else if(state==input0 || state==input2 || state==input4)begin//pic0
			case(X_PAGE)
			3'o0: begin //0
			case(INDEX)
			8'h0 : PATTERN = 8'hF;
			8'h1 : PATTERN = 8'h01;
			8'h2 : PATTERN = 8'h01;
			8'h3 : PATTERN = 8'h01;
			8'h4 : PATTERN = 8'h01;
			8'h5 : PATTERN = 8'h01;
			8'h6 : PATTERN = 8'h01;
			8'h7 : PATTERN = 8'h01;
			8'h8 : PATTERN = 8'h01;
			8'h9 : PATTERN = 8'h01;
			8'ha : PATTERN = 8'h01;
			8'hb : PATTERN = 8'h01;
			8'hc : PATTERN = 8'h01;
			8'hd : PATTERN = 8'h01;
			8'he : PATTERN = 8'h81;
			8'hf : PATTERN = 8'h81;
			8'h10 : PATTERN = 8'h81;
			8'h11 : PATTERN = 8'h81;
			8'h12 : PATTERN = 8'h81;
			8'h13 : PATTERN = 8'h81;
			8'h14 : PATTERN = 8'h01;
			8'h15 : PATTERN = 8'h01;
			8'h16 : PATTERN = 8'h81;
			8'h17 : PATTERN = 8'h81;
			8'h18 : PATTERN = 8'h81;
			8'h19 : PATTERN = 8'h81;
			8'h1a : PATTERN = 8'h81;
			8'h1b : PATTERN = 8'h01;
			8'h1c : PATTERN = 8'h01;
			8'h1d : PATTERN = 8'h01;
			8'h1e : PATTERN = 8'h81;
			8'h1f : PATTERN = 8'h81;
			8'h20 : PATTERN = 8'h81;
			8'h21 : PATTERN = 8'h81;
			8'h22 : PATTERN = 8'h81;
			8'h23 : PATTERN = 8'h01;
			8'h24 : PATTERN = 8'h01;
			8'h25 : PATTERN = 8'h01;
			8'h26 : PATTERN = 8'h81;
			8'h27 : PATTERN = 8'h81;
			8'h28 : PATTERN = 8'h81;
			8'h29 : PATTERN = 8'h81;
			8'h2a : PATTERN = 8'h01;
			8'h2b : PATTERN = 8'h01;
			8'h2c : PATTERN = 8'h01;
			8'h2d : PATTERN = 8'h81;
			8'h2e : PATTERN = 8'h81;
			8'h2f : PATTERN = 8'h81;
			8'h30 : PATTERN = 8'h81;
			8'h31 : PATTERN = 8'h01;
			8'h32 : PATTERN = 8'h01;
			8'h33 : PATTERN = 8'h01;
			8'h34 : PATTERN = 8'h01;
			8'h35 : PATTERN = 8'h01;
			8'h36 : PATTERN = 8'h01;
			8'h37 : PATTERN = 8'h01;
			8'h38 : PATTERN = 8'h01;
			8'h39 : PATTERN = 8'h01;
			8'h3a : PATTERN = 8'h01;
			8'h3b : PATTERN = 8'h01;
			8'h3c : PATTERN = 8'h01;
			8'h3d : PATTERN = 8'h01;
			8'h3e : PATTERN = 8'h01;
			8'h3f : PATTERN = 8'h01;
			8'h40 : PATTERN = 8'h01;
			8'h41 : PATTERN = 8'h01;
			8'h42 : PATTERN = 8'h01;
			8'h43 : PATTERN = 8'h01;
			8'h44 : PATTERN = 8'h01;
			8'h45 : PATTERN = 8'h01;
			8'h46 : PATTERN = 8'h01;
			8'h47 : PATTERN = 8'h01;
			8'h48 : PATTERN = 8'h01;
			8'h49 : PATTERN = 8'h01;
			8'h4a : PATTERN = 8'h01;
			8'h4b : PATTERN = 8'h01;
			8'h4c : PATTERN = 8'h01;
			8'h4d : PATTERN = 8'h01;
			8'h4e : PATTERN = 8'h01;
			8'h4f : PATTERN = 8'h01;
			8'h50 : PATTERN = 8'h01;
			8'h51 : PATTERN = 8'h01;
			8'h52 : PATTERN = 8'h01;
			8'h53 : PATTERN = 8'h01;
			8'h54 : PATTERN = 8'h01;
			8'h55 : PATTERN = 8'h01;
			8'h56 : PATTERN = 8'h01;
			8'h57 : PATTERN = 8'h01;
			8'h58 : PATTERN = 8'h01;
			8'h59 : PATTERN = 8'h01;
			8'h5a : PATTERN = 8'h01;
			8'h5b : PATTERN = 8'h01;
			8'h5c : PATTERN = 8'h01;
			8'h5d : PATTERN = 8'h01;
			8'h5e : PATTERN = 8'h01;
			8'h5f : PATTERN = 8'h01;
			8'h60 : PATTERN = 8'h01;
			8'h61 : PATTERN = 8'h01;
			8'h62 : PATTERN = 8'h01;
			8'h63 : PATTERN = 8'h01;
			8'h64 : PATTERN = 8'h01;
			8'h65 : PATTERN = 8'h01;
			8'h66 : PATTERN = 8'h01;
			8'h67 : PATTERN = 8'h01;
			8'h68 : PATTERN = 8'h01;
			8'h69 : PATTERN = 8'h01;
			8'h6a : PATTERN = 8'h01;
			8'h6b : PATTERN = 8'h01;
			8'h6c : PATTERN = 8'h01;
			8'h6d : PATTERN = 8'h01;
			8'h6e : PATTERN = 8'h01;
			8'h6f : PATTERN = 8'h01;
			8'h70 : PATTERN = 8'h01;
			8'h71 : PATTERN = 8'h01;
			8'h72 : PATTERN = 8'h01;
			8'h73 : PATTERN = 8'h01;
			8'h74 : PATTERN = 8'h01;
			8'h75 : PATTERN = 8'h01;
			8'h76 : PATTERN = 8'h01;
			8'h77 : PATTERN = 8'h01;
					8'h8 : PATTERN = 8'hFE;
					79 : PATTERN = 8'h01;
			8'h7a : PATTERN = 8'h01;
			8'h7b : PATTERN = 8'h01;
			8'h7c : PATTERN = 8'h01;
			8'h7d : PATTERN = 8'h01;
			8'h7e : PATTERN = 8'h01;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o1: begin //1
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h00;
			8'h5 : PATTERN = 8'h00;
			8'h6 : PATTERN = 8'h00;
			8'h7 : PATTERN = 8'h00;
			8'h8 : PATTERN = 8'h00;
			8'h9 : PATTERN = 8'h00;
			8'ha : PATTERN = 8'h00;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'h00;
			8'hd : PATTERN = 8'h00;
			8'he : PATTERN = 8'hFF;
			8'hf : PATTERN = 8'hFF;
			8'h10 : PATTERN = 8'h10;
			8'h11 : PATTERN = 8'h10;
			8'h12 : PATTERN = 8'h19;
			8'h13 : PATTERN = 8'h0F;
			8'h14 : PATTERN = 8'h06;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'hFF;
			8'h17 : PATTERN = 8'hFF;
			8'h18 : PATTERN = 8'h08;
			8'h19 : PATTERN = 8'h18;
			8'h1a : PATTERN = 8'h3F;
			8'h1b : PATTERN = 8'hE7;
			8'h1c : PATTERN = 8'hC0;
			8'h1d : PATTERN = 8'h00;
			8'h1e : PATTERN = 8'hFF;
			8'h1f : PATTERN = 8'hFF;
			8'h20 : PATTERN = 8'h88;
			8'h21 : PATTERN = 8'h88;
			8'h22 : PATTERN = 8'h88;
			8'h23 : PATTERN = 8'h80;
			8'h24 : PATTERN = 8'h00;
			8'h25 : PATTERN = 8'hCF;
			8'h26 : PATTERN = 8'h8D;
			8'h27 : PATTERN = 8'h98;
			8'h28 : PATTERN = 8'h98;
			8'h29 : PATTERN = 8'hF1;
			8'h2a : PATTERN = 8'h60;
			8'h2b : PATTERN = 8'h00;
			8'h2c : PATTERN = 8'hCF;
			8'h2d : PATTERN = 8'h8D;
			8'h2e : PATTERN = 8'h98;
			8'h2f : PATTERN = 8'h98;
			8'h30 : PATTERN = 8'hF1;
			8'h31 : PATTERN = 8'h60;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'h00;
			8'h34 : PATTERN = 8'h00;
			8'h35 : PATTERN = 8'h00;
			8'h36 : PATTERN = 8'h00;
			8'h37 : PATTERN = 8'h00;
			8'h38 : PATTERN = 8'h00;
			8'h39 : PATTERN = 8'h00;
			8'h3a : PATTERN = 8'h00;
			8'h3b : PATTERN = 8'h00;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'h00;
			8'h40 : PATTERN = 8'h00;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h00;
			8'h47 : PATTERN = 8'h00;
			8'h48 : PATTERN = 8'h00;
			8'h49 : PATTERN = 8'h00;
			8'h4a : PATTERN = 8'h00;
			8'h4b : PATTERN = 8'h00;
			8'h4c : PATTERN = 8'h80;
			8'h4d : PATTERN = 8'hC0;
			8'h4e : PATTERN = 8'h80;
			8'h4f : PATTERN = 8'h00;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h00;
			8'h53 : PATTERN = 8'h00;
			8'h54 : PATTERN = 8'h00;
			8'h55 : PATTERN = 8'h00;
			8'h56 : PATTERN = 8'h80;
			8'h57 : PATTERN = 8'hC0;
			8'h58 : PATTERN = 8'hC0;
			8'h59 : PATTERN = 8'hC0;
			8'h5a : PATTERN = 8'h80;
			8'h5b : PATTERN = 8'h00;
			8'h5c : PATTERN = 8'h00;
			8'h5d : PATTERN = 8'h00;
			8'h5e : PATTERN = 8'h00;
			8'h5f : PATTERN = 8'h00;
			8'h60 : PATTERN = 8'h00;
			8'h61 : PATTERN = 8'h00;
			8'h62 : PATTERN = 8'h00;
			8'h63 : PATTERN = 8'h00;
			8'h64 : PATTERN = 8'h00;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h00;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'h00;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o2: begin //2
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h80;
			8'h5 : PATTERN = 8'hC0;
			8'h6 : PATTERN = 8'h40;
			8'h7 : PATTERN = 8'h40;
			8'h8 : PATTERN = 8'hC0;
			8'h9 : PATTERN = 8'h80;
			8'ha : PATTERN = 8'h00;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'h00;
			8'hd : PATTERN = 8'h00;
			8'he : PATTERN = 8'hC0;
			8'hf : PATTERN = 8'hC0;
			8'h10 : PATTERN = 8'hC0;
			8'h11 : PATTERN = 8'h00;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h00;
			8'h14 : PATTERN = 8'h00;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h00;
			8'h1a : PATTERN = 8'h80;
			8'h1b : PATTERN = 8'hC0;
			8'h1c : PATTERN = 8'h40;
			8'h1d : PATTERN = 8'h40;
			8'h1e : PATTERN = 8'hC0;
			8'h1f : PATTERN = 8'h80;
			8'h20 : PATTERN = 8'h00;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'hC0;
			8'h23 : PATTERN = 8'hC0;
			8'h24 : PATTERN = 8'h40;
			8'h25 : PATTERN = 8'h40;
			8'h26 : PATTERN = 8'h40;
			8'h27 : PATTERN = 8'h40;
			8'h28 : PATTERN = 8'h40;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'hC0;
			8'h2b : PATTERN = 8'hC0;
			8'h2c : PATTERN = 8'hC0;
			8'h2d : PATTERN = 8'h80;
			8'h2e : PATTERN = 8'h00;
			8'h2f : PATTERN = 8'h00;
			8'h30 : PATTERN = 8'hC0;
			8'h31 : PATTERN = 8'hC0;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'hC0;
			8'h34 : PATTERN = 8'hC0;
			8'h35 : PATTERN = 8'h40;
			8'h36 : PATTERN = 8'h40;
			8'h37 : PATTERN = 8'hC0;
			8'h38 : PATTERN = 8'hC0;
			8'h39 : PATTERN = 8'h80;
			8'h3a : PATTERN = 8'h00;
			8'h3b : PATTERN = 8'h00;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'h00;
			8'h40 : PATTERN = 8'h00;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h18;
			8'h46 : PATTERN = 8'h18;
			8'h47 : PATTERN = 8'h10;
			8'h48 : PATTERN = 8'h90;
			8'h49 : PATTERN = 8'hB0;
			8'h4a : PATTERN = 8'hF8;
			8'h4b : PATTERN = 8'h0F;
			8'h4c : PATTERN = 8'h03;
			8'h4d : PATTERN = 8'h83;
			8'h4e : PATTERN = 8'h03;
			8'h4f : PATTERN = 8'h03;
			8'h50 : PATTERN = 8'h0E;
			8'h51 : PATTERN = 8'h1C;
			8'h52 : PATTERN = 8'h0C;
			8'h53 : PATTERN = 8'h1C;
			8'h54 : PATTERN = 8'h1C;
			8'h55 : PATTERN = 8'h0E;
			8'h56 : PATTERN = 8'h03;
			8'h57 : PATTERN = 8'h81;
			8'h58 : PATTERN = 8'h81;
			8'h59 : PATTERN = 8'h81;
			8'h5a : PATTERN = 8'h01;
			8'h5b : PATTERN = 8'h06;
			8'h5c : PATTERN = 8'hDC;
			8'h5d : PATTERN = 8'h4C;
			8'h5e : PATTERN = 8'h46;
			8'h5f : PATTERN = 8'h67;
			8'h60 : PATTERN = 8'h67;
			8'h61 : PATTERN = 8'h26;
			8'h62 : PATTERN = 8'h3E;
			8'h63 : PATTERN = 8'h3E;
			8'h64 : PATTERN = 8'h04;
			8'h65 : PATTERN = 8'h04;
			8'h66 : PATTERN = 8'h3C;
			8'h67 : PATTERN = 8'h3C;
			8'h68 : PATTERN = 8'h08;
			8'h69 : PATTERN = 8'h10;
			8'h6a : PATTERN = 8'h20;
			8'h6b : PATTERN = 8'hC0;
			8'h6c : PATTERN = 8'h80;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h20;
			8'h72 : PATTERN = 8'hF0;
			8'h73 : PATTERN = 8'hD0;
			8'h74 : PATTERN = 8'h90;
			8'h75 : PATTERN = 8'h18;
			8'h76 : PATTERN = 8'h38;
			8'h77 : PATTERN = 8'h78;
			8'h78 : PATTERN = 8'hF8;
			8'h79 : PATTERN = 8'hF8;
			8'h7a : PATTERN = 8'hFC;
			8'h7b : PATTERN = 8'hFC;
			8'h7c : PATTERN = 8'h7C;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o3: begin //3
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h10;
			8'h4 : PATTERN = 8'h33;
			8'h5 : PATTERN = 8'h67;
			8'h6 : PATTERN = 8'h44;
			8'h7 : PATTERN = 8'h44;
			8'h8 : PATTERN = 8'h6D;
			8'h9 : PATTERN = 8'h39;
			8'ha : PATTERN = 8'h10;
			8'hb : PATTERN = 8'h10;
			8'hc : PATTERN = 8'h1C;
			8'hd : PATTERN = 8'h17;
			8'he : PATTERN = 8'h11;
			8'hf : PATTERN = 8'h7F;
			8'h10 : PATTERN = 8'h7F;
			8'h11 : PATTERN = 8'h10;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h63;
			8'h14 : PATTERN = 8'h63;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h10;
			8'h1a : PATTERN = 8'h33;
			8'h1b : PATTERN = 8'h67;
			8'h1c : PATTERN = 8'h44;
			8'h1d : PATTERN = 8'h44;
			8'h1e : PATTERN = 8'h6D;
			8'h1f : PATTERN = 8'h39;
			8'h20 : PATTERN = 8'h10;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'h7F;
			8'h23 : PATTERN = 8'h7F;
			8'h24 : PATTERN = 8'h44;
			8'h25 : PATTERN = 8'h44;
			8'h26 : PATTERN = 8'h44;
			8'h27 : PATTERN = 8'h40;
			8'h28 : PATTERN = 8'h40;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'h7F;
			8'h2b : PATTERN = 8'h7F;
			8'h2c : PATTERN = 8'h01;
			8'h2d : PATTERN = 8'h07;
			8'h2e : PATTERN = 8'h1E;
			8'h2f : PATTERN = 8'h78;
			8'h30 : PATTERN = 8'h7F;
			8'h31 : PATTERN = 8'h7F;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'h7F;
			8'h34 : PATTERN = 8'h7F;
			8'h35 : PATTERN = 8'h40;
			8'h36 : PATTERN = 8'h40;
			8'h37 : PATTERN = 8'h60;
			8'h38 : PATTERN = 8'h71;
			8'h39 : PATTERN = 8'h3F;
			8'h3a : PATTERN = 8'h1F;
			8'h3b : PATTERN = 8'h00;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'h00;
			8'h40 : PATTERN = 8'h00;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h02;
			8'h46 : PATTERN = 8'h01;
			8'h47 : PATTERN = 8'h01;
			8'h48 : PATTERN = 8'h01;
			8'h49 : PATTERN = 8'hFF;
			8'h4a : PATTERN = 8'h05;
			8'h4b : PATTERN = 8'h0E;
			8'h4c : PATTERN = 8'h0E;
			8'h4d : PATTERN = 8'h07;
			8'h4e : PATTERN = 8'h03;
			8'h4f : PATTERN = 8'h00;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h02;
			8'h53 : PATTERN = 8'h03;
			8'h54 : PATTERN = 8'h02;
			8'h55 : PATTERN = 8'h00;
			8'h56 : PATTERN = 8'h00;
			8'h57 : PATTERN = 8'h01;
			8'h58 : PATTERN = 8'h01;
			8'h59 : PATTERN = 8'h07;
			8'h5a : PATTERN = 8'h07;
			8'h5b : PATTERN = 8'h06;
			8'h5c : PATTERN = 8'h00;
			8'h5d : PATTERN = 8'h00;
			8'h5e : PATTERN = 8'h00;
			8'h5f : PATTERN = 8'h00;
			8'h60 : PATTERN = 8'h00;
			8'h61 : PATTERN = 8'h00;
			8'h62 : PATTERN = 8'h00;
			8'h63 : PATTERN = 8'h00;
			8'h64 : PATTERN = 8'h00;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h00;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'h00;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h03;
			8'h6d : PATTERN = 8'hFE;
			8'h6e : PATTERN = 8'hE0;
			8'h6f : PATTERN = 8'hE0;
			8'h70 : PATTERN = 8'hE0;
			8'h71 : PATTERN = 8'hB0;
			8'h72 : PATTERN = 8'hF1;
			8'h73 : PATTERN = 8'h7F;
			8'h74 : PATTERN = 8'h77;
			8'h75 : PATTERN = 8'h67;
			8'h76 : PATTERN = 8'h2F;
			8'h77 : PATTERN = 8'h39;
			8'h78 : PATTERN = 8'h01;
			8'h79 : PATTERN = 8'h01;
			8'h7a : PATTERN = 8'h01;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o4: begin //4
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h70;
			8'h5 : PATTERN = 8'hF8;
			8'h6 : PATTERN = 8'h88;
			8'h7 : PATTERN = 8'h88;
			8'h8 : PATTERN = 8'hB8;
			8'h9 : PATTERN = 8'h30;
			8'ha : PATTERN = 8'h00;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'hF8;
			8'hd : PATTERN = 8'hC8;
			8'he : PATTERN = 8'h48;
			8'hf : PATTERN = 8'hC8;
			8'h10 : PATTERN = 8'h88;
			8'h11 : PATTERN = 8'h00;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h60;
			8'h14 : PATTERN = 8'h60;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h00;
			8'h1a : PATTERN = 8'hF0;
			8'h1b : PATTERN = 8'hF8;
			8'h1c : PATTERN = 8'h18;
			8'h1d : PATTERN = 8'h08;
			8'h1e : PATTERN = 8'h08;
			8'h1f : PATTERN = 8'h38;
			8'h20 : PATTERN = 8'h30;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'h00;
			8'h23 : PATTERN = 8'hF8;
			8'h24 : PATTERN = 8'hF8;
			8'h25 : PATTERN = 8'h00;
			8'h26 : PATTERN = 8'h00;
			8'h27 : PATTERN = 8'h00;
			8'h28 : PATTERN = 8'h00;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'hF8;
			8'h2b : PATTERN = 8'hF8;
			8'h2c : PATTERN = 8'h88;
			8'h2d : PATTERN = 8'h88;
			8'h2e : PATTERN = 8'h88;
			8'h2f : PATTERN = 8'h08;
			8'h30 : PATTERN = 8'h08;
			8'h31 : PATTERN = 8'h00;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'hE0;
			8'h34 : PATTERN = 8'h78;
			8'h35 : PATTERN = 8'h38;
			8'h36 : PATTERN = 8'hF8;
			8'h37 : PATTERN = 8'h80;
			8'h38 : PATTERN = 8'h00;
			8'h39 : PATTERN = 8'h00;
			8'h3a : PATTERN = 8'hF8;
			8'h3b : PATTERN = 8'hF8;
			8'h3c : PATTERN = 8'h88;
			8'h3d : PATTERN = 8'h88;
			8'h3e : PATTERN = 8'h88;
			8'h3f : PATTERN = 8'hF8;
			8'h40 : PATTERN = 8'h70;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h00;
			8'h47 : PATTERN = 8'h00;
			8'h48 : PATTERN = 8'h00;
			8'h49 : PATTERN = 8'h01;
			8'h4a : PATTERN = 8'h0F;
			8'h4b : PATTERN = 8'h30;
			8'h4c : PATTERN = 8'hE0;
			8'h4d : PATTERN = 8'hC0;
			8'h4e : PATTERN = 8'h00;
			8'h4f : PATTERN = 8'h80;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h00;
			8'h53 : PATTERN = 8'h00;
			8'h54 : PATTERN = 8'h00;
			8'h55 : PATTERN = 8'h00;
			8'h56 : PATTERN = 8'h00;
			8'h57 : PATTERN = 8'h00;
			8'h58 : PATTERN = 8'h00;
			8'h59 : PATTERN = 8'h00;
			8'h5a : PATTERN = 8'h00;
			8'h5b : PATTERN = 8'h00;
			8'h5c : PATTERN = 8'h00;
			8'h5d : PATTERN = 8'h00;
			8'h5e : PATTERN = 8'h00;
			8'h5f : PATTERN = 8'h00;
			8'h60 : PATTERN = 8'h00;
			8'h61 : PATTERN = 8'h00;
			8'h62 : PATTERN = 8'h00;
			8'h63 : PATTERN = 8'h00;
			8'h64 : PATTERN = 8'h00;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h80;
			8'h67 : PATTERN = 8'h80;
			8'h68 : PATTERN = 8'h80;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'hC0;
			8'h6b : PATTERN = 8'h30;
			8'h6c : PATTERN = 8'h1C;
			8'h6d : PATTERN = 8'h07;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o5: begin //5
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h02;
			8'h4 : PATTERN = 8'h06;
			8'h5 : PATTERN = 8'h0C;
			8'h6 : PATTERN = 8'h08;
			8'h7 : PATTERN = 8'h08;
			8'h8 : PATTERN = 8'h0D;
			8'h9 : PATTERN = 8'h07;
			8'ha : PATTERN = 8'h02;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'h0C;
			8'hd : PATTERN = 8'h0C;
			8'he : PATTERN = 8'h08;
			8'hf : PATTERN = 8'h0C;
			8'h10 : PATTERN = 8'h07;
			8'h11 : PATTERN = 8'h00;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h0C;
			8'h14 : PATTERN = 8'h0C;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h00;
			8'h1a : PATTERN = 8'h07;
			8'h1b : PATTERN = 8'h0F;
			8'h1c : PATTERN = 8'h0C;
			8'h1d : PATTERN = 8'h08;
			8'h1e : PATTERN = 8'h08;
			8'h1f : PATTERN = 8'h0E;
			8'h20 : PATTERN = 8'h06;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'h00;
			8'h23 : PATTERN = 8'h0F;
			8'h24 : PATTERN = 8'h0F;
			8'h25 : PATTERN = 8'h08;
			8'h26 : PATTERN = 8'h08;
			8'h27 : PATTERN = 8'h08;
			8'h28 : PATTERN = 8'h08;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'h0F;
			8'h2b : PATTERN = 8'h0F;
			8'h2c : PATTERN = 8'h08;
			8'h2d : PATTERN = 8'h08;
			8'h2e : PATTERN = 8'h08;
			8'h2f : PATTERN = 8'h08;
			8'h30 : PATTERN = 8'h08;
			8'h31 : PATTERN = 8'h08;
			8'h32 : PATTERN = 8'h0F;
			8'h33 : PATTERN = 8'h03;
			8'h34 : PATTERN = 8'h01;
			8'h35 : PATTERN = 8'h01;
			8'h36 : PATTERN = 8'h03;
			8'h37 : PATTERN = 8'h0F;
			8'h38 : PATTERN = 8'h0C;
			8'h39 : PATTERN = 8'h00;
			8'h3a : PATTERN = 8'h0F;
			8'h3b : PATTERN = 8'h0F;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h03;
			8'h3f : PATTERN = 8'h0E;
			8'h40 : PATTERN = 8'h0C;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h00;
			8'h47 : PATTERN = 8'h00;
			8'h48 : PATTERN = 8'h00;
			8'h49 : PATTERN = 8'h00;
			8'h4a : PATTERN = 8'h00;
			8'h4b : PATTERN = 8'h00;
			8'h4c : PATTERN = 8'h03;
			8'h4d : PATTERN = 8'h03;
			8'h4e : PATTERN = 8'h01;
			8'h4f : PATTERN = 8'h01;
			8'h50 : PATTERN = 8'h01;
			8'h51 : PATTERN = 8'h01;
			8'h52 : PATTERN = 8'h01;
			8'h53 : PATTERN = 8'h81;
			8'h54 : PATTERN = 8'hF3;
			8'h55 : PATTERN = 8'hFB;
			8'h56 : PATTERN = 8'hFE;
			8'h57 : PATTERN = 8'hFF;
			8'h58 : PATTERN = 8'hFF;
			8'h59 : PATTERN = 8'hFF;
			8'h5a : PATTERN = 8'hFF;
			8'h5b : PATTERN = 8'hFF;
			8'h5c : PATTERN = 8'hFF;
			8'h5d : PATTERN = 8'hFF;
			8'h5e : PATTERN = 8'hFF;
			8'h5f : PATTERN = 8'hFF;
			8'h60 : PATTERN = 8'hFF;
			8'h61 : PATTERN = 8'hFF;
			8'h62 : PATTERN = 8'hFF;
			8'h63 : PATTERN = 8'hF1;
			8'h64 : PATTERN = 8'hC1;
			8'h65 : PATTERN = 8'h01;
			8'h66 : PATTERN = 8'h01;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h01;
			8'h69 : PATTERN = 8'h02;
			8'h6a : PATTERN = 8'h03;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o6: begin //6
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h00;
			8'h5 : PATTERN = 8'h9E;
			8'h6 : PATTERN = 8'h1B;
			8'h7 : PATTERN = 8'h31;
			8'h8 : PATTERN = 8'h31;
			8'h9 : PATTERN = 8'hE3;
			8'ha : PATTERN = 8'hC0;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'hEE;
			8'hd : PATTERN = 8'hBF;
			8'he : PATTERN = 8'h11;
			8'hf : PATTERN = 8'h39;
			8'h10 : PATTERN = 8'hEF;
			8'h11 : PATTERN = 8'hE0;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h8C;
			8'h14 : PATTERN = 8'h8C;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'hFF;
			8'h1a : PATTERN = 8'hFF;
			8'h1b : PATTERN = 8'h11;
			8'h1c : PATTERN = 8'h31;
			8'h1d : PATTERN = 8'h7F;
			8'h1e : PATTERN = 8'hCE;
			8'h1f : PATTERN = 8'h80;
			8'h20 : PATTERN = 8'h00;
			8'h21 : PATTERN = 8'hFF;
			8'h22 : PATTERN = 8'hFF;
			8'h23 : PATTERN = 8'h11;
			8'h24 : PATTERN = 8'h11;
			8'h25 : PATTERN = 8'h11;
			8'h26 : PATTERN = 8'h00;
			8'h27 : PATTERN = 8'h00;
			8'h28 : PATTERN = 8'h9E;
			8'h29 : PATTERN = 8'h1B;
			8'h2a : PATTERN = 8'h31;
			8'h2b : PATTERN = 8'h31;
			8'h2c : PATTERN = 8'hE3;
			8'h2d : PATTERN = 8'hC0;
			8'h2e : PATTERN = 8'h01;
			8'h2f : PATTERN = 8'h01;
			8'h30 : PATTERN = 8'h01;
			8'h31 : PATTERN = 8'hFF;
			8'h32 : PATTERN = 8'h01;
			8'h33 : PATTERN = 8'h01;
			8'h34 : PATTERN = 8'h01;
			8'h35 : PATTERN = 8'h80;
			8'h36 : PATTERN = 8'hE0;
			8'h37 : PATTERN = 8'h38;
			8'h38 : PATTERN = 8'h2F;
			8'h39 : PATTERN = 8'h23;
			8'h3a : PATTERN = 8'h2F;
			8'h3b : PATTERN = 8'h3C;
			8'h3c : PATTERN = 8'hE0;
			8'h3d : PATTERN = 8'h80;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'hFF;
			8'h40 : PATTERN = 8'hFF;
			8'h41 : PATTERN = 8'h11;
			8'h42 : PATTERN = 8'h31;
			8'h43 : PATTERN = 8'h7F;
			8'h44 : PATTERN = 8'hCE;
			8'h45 : PATTERN = 8'h80;
			8'h46 : PATTERN = 8'h01;
			8'h47 : PATTERN = 8'h01;
			8'h48 : PATTERN = 8'h01;
			8'h49 : PATTERN = 8'hFF;
			8'h4a : PATTERN = 8'h01;
			8'h4b : PATTERN = 8'h01;
			8'h4c : PATTERN = 8'h01;
			8'h4d : PATTERN = 8'h00;
			8'h4e : PATTERN = 8'h00;
			8'h4f : PATTERN = 8'h00;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h00;
			8'h53 : PATTERN = 8'h07;
			8'h54 : PATTERN = 8'h3F;
			8'h55 : PATTERN = 8'h47;
			8'h56 : PATTERN = 8'h87;
			8'h57 : PATTERN = 8'h87;
			8'h58 : PATTERN = 8'h07;
			8'h59 : PATTERN = 8'h07;
			8'h5a : PATTERN = 8'h0F;
			8'h5b : PATTERN = 8'h08;
			8'h5c : PATTERN = 8'h08;
			8'h5d : PATTERN = 8'h08;
			8'h5e : PATTERN = 8'h0F;
			8'h5f : PATTERN = 8'h07;
			8'h60 : PATTERN = 8'h07;
			8'h61 : PATTERN = 8'h87;
			8'h62 : PATTERN = 8'h47;
			8'h63 : PATTERN = 8'h37;
			8'h64 : PATTERN = 8'h0F;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h00;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'h00;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o7: begin //7
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h80;
			8'h2 : PATTERN = 8'h80;
			8'h3 : PATTERN = 8'h80;
			8'h4 : PATTERN = 8'h80;
			8'h5 : PATTERN = 8'h81;
			8'h6 : PATTERN = 8'h81;
			8'h7 : PATTERN = 8'h81;
			8'h8 : PATTERN = 8'h81;
			8'h9 : PATTERN = 8'h81;
			8'ha : PATTERN = 8'h80;
			8'hb : PATTERN = 8'h80;
			8'hc : PATTERN = 8'h81;
			8'hd : PATTERN = 8'h81;
			8'he : PATTERN = 8'h81;
			8'hf : PATTERN = 8'h81;
			8'h10 : PATTERN = 8'h81;
			8'h11 : PATTERN = 8'h80;
			8'h12 : PATTERN = 8'h80;
			8'h13 : PATTERN = 8'h81;
			8'h14 : PATTERN = 8'h81;
			8'h15 : PATTERN = 8'h80;
			8'h16 : PATTERN = 8'h80;
			8'h17 : PATTERN = 8'h80;
			8'h18 : PATTERN = 8'h80;
			8'h19 : PATTERN = 8'h81;
			8'h1a : PATTERN = 8'h81;
			8'h1b : PATTERN = 8'h80;
			8'h1c : PATTERN = 8'h80;
			8'h1d : PATTERN = 8'h80;
			8'h1e : PATTERN = 8'h81;
			8'h1f : PATTERN = 8'h81;
			8'h20 : PATTERN = 8'h80;
			8'h21 : PATTERN = 8'h81;
			8'h22 : PATTERN = 8'h81;
			8'h23 : PATTERN = 8'h81;
			8'h24 : PATTERN = 8'h81;
			8'h25 : PATTERN = 8'h81;
			8'h26 : PATTERN = 8'h81;
			8'h27 : PATTERN = 8'h80;
			8'h28 : PATTERN = 8'h81;
			8'h29 : PATTERN = 8'h81;
			8'h2a : PATTERN = 8'h81;
			8'h2b : PATTERN = 8'h81;
			8'h2c : PATTERN = 8'h81;
			8'h2d : PATTERN = 8'h80;
			8'h2e : PATTERN = 8'h80;
			8'h2f : PATTERN = 8'h80;
			8'h30 : PATTERN = 8'h80;
			8'h31 : PATTERN = 8'h81;
			8'h32 : PATTERN = 8'h80;
			8'h33 : PATTERN = 8'h80;
			8'h34 : PATTERN = 8'h80;
			8'h35 : PATTERN = 8'h81;
			8'h36 : PATTERN = 8'h81;
			8'h37 : PATTERN = 8'h80;
			8'h38 : PATTERN = 8'h80;
			8'h39 : PATTERN = 8'h80;
			8'h3a : PATTERN = 8'h80;
			8'h3b : PATTERN = 8'h80;
			8'h3c : PATTERN = 8'h81;
			8'h3d : PATTERN = 8'h81;
			8'h3e : PATTERN = 8'h80;
			8'h3f : PATTERN = 8'h81;
			8'h40 : PATTERN = 8'h81;
			8'h41 : PATTERN = 8'h80;
			8'h42 : PATTERN = 8'h80;
			8'h43 : PATTERN = 8'h80;
			8'h44 : PATTERN = 8'h81;
			8'h45 : PATTERN = 8'h81;
			8'h46 : PATTERN = 8'h80;
			8'h47 : PATTERN = 8'h80;
			8'h48 : PATTERN = 8'h80;
			8'h49 : PATTERN = 8'h81;
			8'h4a : PATTERN = 8'h80;
			8'h4b : PATTERN = 8'h80;
			8'h4c : PATTERN = 8'h80;
			8'h4d : PATTERN = 8'h80;
			8'h4e : PATTERN = 8'h80;
			8'h4f : PATTERN = 8'h80;
			8'h50 : PATTERN = 8'h80;
			8'h51 : PATTERN = 8'h80;
			8'h52 : PATTERN = 8'h80;
			8'h53 : PATTERN = 8'h80;
			8'h54 : PATTERN = 8'h80;
			8'h55 : PATTERN = 8'h80;
			8'h56 : PATTERN = 8'h80;
			8'h57 : PATTERN = 8'h81;
			8'h58 : PATTERN = 8'h81;
			8'h59 : PATTERN = 8'h81;
			8'h5a : PATTERN = 8'h81;
			8'h5b : PATTERN = 8'h83;
			8'h5c : PATTERN = 8'h82;
			8'h5d : PATTERN = 8'h83;
			8'h5e : PATTERN = 8'h81;
			8'h5f : PATTERN = 8'h81;
			8'h60 : PATTERN = 8'h81;
			8'h61 : PATTERN = 8'h80;
			8'h62 : PATTERN = 8'h80;
			8'h63 : PATTERN = 8'h80;
			8'h64 : PATTERN = 8'h80;
			8'h65 : PATTERN = 8'h80;
			8'h66 : PATTERN = 8'h80;
			8'h67 : PATTERN = 8'h80;
			8'h68 : PATTERN = 8'h80;
			8'h69 : PATTERN = 8'h80;
			8'h6a : PATTERN = 8'h80;
			8'h6b : PATTERN = 8'h80;
			8'h6c : PATTERN = 8'h80;
			8'h6d : PATTERN = 8'h80;
			8'h6e : PATTERN = 8'h80;
			8'h6f : PATTERN = 8'h80;
			8'h70 : PATTERN = 8'h80;
			8'h71 : PATTERN = 8'h80;
			8'h72 : PATTERN = 8'h80;
			8'h73 : PATTERN = 8'h80;
			8'h74 : PATTERN = 8'h80;
			8'h75 : PATTERN = 8'h80;
			8'h76 : PATTERN = 8'h80;
			8'h77 : PATTERN = 8'h80;
			8'h78 : PATTERN = 8'h80;
			8'h79 : PATTERN = 8'h80;
			8'h7a : PATTERN = 8'h80;
			8'h7b : PATTERN = 8'h80;
			8'h7c : PATTERN = 8'h80;
			8'h7d : PATTERN = 8'h80;
			8'h7e : PATTERN = 8'h80;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			endcase
		end
		else if(state==input1 || state==minus || state==check_answer)begin//pic3
			case(X_PAGE)
			3'o0: begin //0
			case(INDEX)
			8'h0 : PATTERN = 8'hF;
			8'h1 : PATTERN = 8'h01;
			8'h2 : PATTERN = 8'h01;
			8'h3 : PATTERN = 8'h01;
			8'h4 : PATTERN = 8'h01;
			8'h5 : PATTERN = 8'h01;
			8'h6 : PATTERN = 8'h01;
			8'h7 : PATTERN = 8'h01;
			8'h8 : PATTERN = 8'h01;
			8'h9 : PATTERN = 8'h01;
			8'ha : PATTERN = 8'h01;
			8'hb : PATTERN = 8'h01;
			8'hc : PATTERN = 8'h01;
			8'hd : PATTERN = 8'h01;
			8'he : PATTERN = 8'h81;
			8'hf : PATTERN = 8'h81;
			8'h10 : PATTERN = 8'h81;
			8'h11 : PATTERN = 8'h81;
			8'h12 : PATTERN = 8'h81;
			8'h13 : PATTERN = 8'h81;
			8'h14 : PATTERN = 8'h01;
			8'h15 : PATTERN = 8'h01;
			8'h16 : PATTERN = 8'h81;
			8'h17 : PATTERN = 8'h81;
			8'h18 : PATTERN = 8'h81;
			8'h19 : PATTERN = 8'h81;
			8'h1a : PATTERN = 8'h81;
			8'h1b : PATTERN = 8'h01;
			8'h1c : PATTERN = 8'h01;
			8'h1d : PATTERN = 8'h01;
			8'h1e : PATTERN = 8'h81;
			8'h1f : PATTERN = 8'h81;
			8'h20 : PATTERN = 8'h81;
			8'h21 : PATTERN = 8'h81;
			8'h22 : PATTERN = 8'h81;
			8'h23 : PATTERN = 8'h01;
			8'h24 : PATTERN = 8'h01;
			8'h25 : PATTERN = 8'h01;
			8'h26 : PATTERN = 8'h81;
			8'h27 : PATTERN = 8'h81;
			8'h28 : PATTERN = 8'h81;
			8'h29 : PATTERN = 8'h81;
			8'h2a : PATTERN = 8'h01;
			8'h2b : PATTERN = 8'h01;
			8'h2c : PATTERN = 8'h01;
			8'h2d : PATTERN = 8'h81;
			8'h2e : PATTERN = 8'h81;
			8'h2f : PATTERN = 8'h81;
			8'h30 : PATTERN = 8'h81;
			8'h31 : PATTERN = 8'h01;
			8'h32 : PATTERN = 8'h01;
			8'h33 : PATTERN = 8'h01;
			8'h34 : PATTERN = 8'h01;
			8'h35 : PATTERN = 8'h01;
			8'h36 : PATTERN = 8'h01;
			8'h37 : PATTERN = 8'h01;
			8'h38 : PATTERN = 8'h01;
			8'h39 : PATTERN = 8'h01;
			8'h3a : PATTERN = 8'h01;
			8'h3b : PATTERN = 8'h01;
			8'h3c : PATTERN = 8'h01;
			8'h3d : PATTERN = 8'h01;
			8'h3e : PATTERN = 8'h01;
			8'h3f : PATTERN = 8'h01;
			8'h40 : PATTERN = 8'h01;
			8'h41 : PATTERN = 8'h01;
			8'h42 : PATTERN = 8'h01;
			8'h43 : PATTERN = 8'h01;
			8'h44 : PATTERN = 8'h01;
			8'h45 : PATTERN = 8'h01;
			8'h46 : PATTERN = 8'h01;
			8'h47 : PATTERN = 8'h01;
			8'h48 : PATTERN = 8'h01;
			8'h49 : PATTERN = 8'h01;
			8'h4a : PATTERN = 8'h01;
			8'h4b : PATTERN = 8'h01;
			8'h4c : PATTERN = 8'h01;
			8'h4d : PATTERN = 8'h01;
			8'h4e : PATTERN = 8'h01;
			8'h4f : PATTERN = 8'h01;
			8'h50 : PATTERN = 8'h01;
			8'h51 : PATTERN = 8'h01;
			8'h52 : PATTERN = 8'h01;
			8'h53 : PATTERN = 8'h01;
			8'h54 : PATTERN = 8'h01;
			8'h55 : PATTERN = 8'h01;
			8'h56 : PATTERN = 8'h01;
			8'h57 : PATTERN = 8'h01;
			8'h58 : PATTERN = 8'h01;
			8'h59 : PATTERN = 8'h01;
			8'h5a : PATTERN = 8'h01;
			8'h5b : PATTERN = 8'h01;
			8'h5c : PATTERN = 8'h01;
			8'h5d : PATTERN = 8'h01;
			8'h5e : PATTERN = 8'h01;
			8'h5f : PATTERN = 8'h01;
			8'h60 : PATTERN = 8'h01;
			8'h61 : PATTERN = 8'h01;
			8'h62 : PATTERN = 8'h01;
			8'h63 : PATTERN = 8'h01;
			8'h64 : PATTERN = 8'h01;
			8'h65 : PATTERN = 8'h01;
			8'h66 : PATTERN = 8'h01;
			8'h67 : PATTERN = 8'h01;
			8'h68 : PATTERN = 8'h01;
			8'h69 : PATTERN = 8'h01;
			8'h6a : PATTERN = 8'h01;
			8'h6b : PATTERN = 8'h01;
			8'h6c : PATTERN = 8'h01;
			8'h6d : PATTERN = 8'h01;
			8'h6e : PATTERN = 8'h01;
			8'h6f : PATTERN = 8'h01;
			8'h70 : PATTERN = 8'h01;
			8'h71 : PATTERN = 8'h01;
			8'h72 : PATTERN = 8'h01;
			8'h73 : PATTERN = 8'h01;
			8'h74 : PATTERN = 8'h01;
			8'h75 : PATTERN = 8'h01;
			8'h76 : PATTERN = 8'h01;
			8'h77 : PATTERN = 8'h01;
			8'h78 : PATTERN = 8'h01;
			8'h79 : PATTERN = 8'h01;
			8'h7a : PATTERN = 8'h01;
			8'h7b : PATTERN = 8'h01;
			8'h7c : PATTERN = 8'h01;
			8'h7d : PATTERN = 8'h01;
			8'h7e : PATTERN = 8'h01;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o1: begin //1
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h00;
			8'h5 : PATTERN = 8'h00;
			8'h6 : PATTERN = 8'h00;
			8'h7 : PATTERN = 8'h00;
			8'h8 : PATTERN = 8'h00;
			8'h9 : PATTERN = 8'h00;
			8'ha : PATTERN = 8'h00;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'h00;
			8'hd : PATTERN = 8'h00;
			8'he : PATTERN = 8'hFF;
			8'hf : PATTERN = 8'hFF;
			8'h10 : PATTERN = 8'h10;
			8'h11 : PATTERN = 8'h10;
			8'h12 : PATTERN = 8'h19;
			8'h13 : PATTERN = 8'h0F;
			8'h14 : PATTERN = 8'h06;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'hFF;
			8'h17 : PATTERN = 8'hFF;
			8'h18 : PATTERN = 8'h08;
			8'h19 : PATTERN = 8'h18;
			8'h1a : PATTERN = 8'h3F;
			8'h1b : PATTERN = 8'hE7;
			8'h1c : PATTERN = 8'hC0;
			8'h1d : PATTERN = 8'h00;
			8'h1e : PATTERN = 8'hFF;
			8'h1f : PATTERN = 8'hFF;
			8'h20 : PATTERN = 8'h88;
			8'h21 : PATTERN = 8'h88;
			8'h22 : PATTERN = 8'h88;
			8'h23 : PATTERN = 8'h80;
			8'h24 : PATTERN = 8'h00;
			8'h25 : PATTERN = 8'hCF;
			8'h26 : PATTERN = 8'h8D;
			8'h27 : PATTERN = 8'h98;
			8'h28 : PATTERN = 8'h98;
			8'h29 : PATTERN = 8'hF1;
			8'h2a : PATTERN = 8'h60;
			8'h2b : PATTERN = 8'h00;
			8'h2c : PATTERN = 8'hCF;
			8'h2d : PATTERN = 8'h8D;
			8'h2e : PATTERN = 8'h98;
			8'h2f : PATTERN = 8'h98;
			8'h30 : PATTERN = 8'hF1;
			8'h31 : PATTERN = 8'h60;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'h00;
			8'h34 : PATTERN = 8'h00;
			8'h35 : PATTERN = 8'h00;
			8'h36 : PATTERN = 8'h00;
			8'h37 : PATTERN = 8'h00;
			8'h38 : PATTERN = 8'h00;
			8'h39 : PATTERN = 8'h00;
			8'h3a : PATTERN = 8'h00;
			8'h3b : PATTERN = 8'h00;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'h00;
			8'h40 : PATTERN = 8'h00;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h00;
			8'h47 : PATTERN = 8'h00;
			8'h48 : PATTERN = 8'h00;
			8'h49 : PATTERN = 8'h00;
			8'h4a : PATTERN = 8'h00;
			8'h4b : PATTERN = 8'h00;
			8'h4c : PATTERN = 8'h80;
			8'h4d : PATTERN = 8'h80;
			8'h4e : PATTERN = 8'h00;
			8'h4f : PATTERN = 8'h00;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h00;
			8'h53 : PATTERN = 8'h00;
			8'h54 : PATTERN = 8'h00;
			8'h55 : PATTERN = 8'h00;
			8'h56 : PATTERN = 8'h80;
			8'h57 : PATTERN = 8'hC0;
			8'h58 : PATTERN = 8'hC0;
			8'h59 : PATTERN = 8'h80;
			8'h5a : PATTERN = 8'h00;
			8'h5b : PATTERN = 8'h00;
			8'h5c : PATTERN = 8'h00;
			8'h5d : PATTERN = 8'h00;
			8'h5e : PATTERN = 8'h00;
			8'h5f : PATTERN = 8'h00;
			8'h60 : PATTERN = 8'h00;
			8'h61 : PATTERN = 8'h00;
			8'h62 : PATTERN = 8'h00;
			8'h63 : PATTERN = 8'h00;
			8'h64 : PATTERN = 8'h00;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h00;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'h00;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o2: begin //2
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h80;
			8'h5 : PATTERN = 8'hC0;
			8'h6 : PATTERN = 8'h40;
			8'h7 : PATTERN = 8'h40;
			8'h8 : PATTERN = 8'hC0;
			8'h9 : PATTERN = 8'h80;
			8'ha : PATTERN = 8'h00;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'h00;
			8'hd : PATTERN = 8'h00;
			8'he : PATTERN = 8'hC0;
			8'hf : PATTERN = 8'hC0;
			8'h10 : PATTERN = 8'hC0;
			8'h11 : PATTERN = 8'h00;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h00;
			8'h14 : PATTERN = 8'h00;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h00;
			8'h1a : PATTERN = 8'h80;
			8'h1b : PATTERN = 8'hC0;
			8'h1c : PATTERN = 8'h40;
			8'h1d : PATTERN = 8'h40;
			8'h1e : PATTERN = 8'hC0;
			8'h1f : PATTERN = 8'h80;
			8'h20 : PATTERN = 8'h00;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'hC0;
			8'h23 : PATTERN = 8'hC0;
			8'h24 : PATTERN = 8'h40;
			8'h25 : PATTERN = 8'h40;
			8'h26 : PATTERN = 8'h40;
			8'h27 : PATTERN = 8'h40;
			8'h28 : PATTERN = 8'h40;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'hC0;
			8'h2b : PATTERN = 8'hC0;
			8'h2c : PATTERN = 8'hC0;
			8'h2d : PATTERN = 8'h80;
			8'h2e : PATTERN = 8'h00;
			8'h2f : PATTERN = 8'h00;
			8'h30 : PATTERN = 8'hC0;
			8'h31 : PATTERN = 8'hC0;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'hC0;
			8'h34 : PATTERN = 8'hC0;
			8'h35 : PATTERN = 8'h40;
			8'h36 : PATTERN = 8'h40;
			8'h37 : PATTERN = 8'hC0;
			8'h38 : PATTERN = 8'hC0;
			8'h39 : PATTERN = 8'h80;
			8'h3a : PATTERN = 8'h00;
			8'h3b : PATTERN = 8'h00;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'h00;
			8'h40 : PATTERN = 8'h00;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h10;
			8'h45 : PATTERN = 8'h10;
			8'h46 : PATTERN = 8'h10;
			8'h47 : PATTERN = 8'h20;
			8'h48 : PATTERN = 8'h20;
			8'h49 : PATTERN = 8'hE0;
			8'h4a : PATTERN = 8'h1C;
			8'h4b : PATTERN = 8'h07;
			8'h4c : PATTERN = 8'h07;
			8'h4d : PATTERN = 8'h03;
			8'h4e : PATTERN = 8'h03;
			8'h4f : PATTERN = 8'h04;
			8'h50 : PATTERN = 8'h18;
			8'h51 : PATTERN = 8'h08;
			8'h52 : PATTERN = 8'h18;
			8'h53 : PATTERN = 8'h08;
			8'h54 : PATTERN = 8'h1C;
			8'h55 : PATTERN = 8'h03;
			8'h56 : PATTERN = 8'h01;
			8'h57 : PATTERN = 8'h81;
			8'h58 : PATTERN = 8'h81;
			8'h59 : PATTERN = 8'h01;
			8'h5a : PATTERN = 8'h06;
			8'h5b : PATTERN = 8'h1C;
			8'h5c : PATTERN = 8'hCC;
			8'h5d : PATTERN = 8'h46;
			8'h5e : PATTERN = 8'h65;
			8'h5f : PATTERN = 8'h26;
			8'h60 : PATTERN = 8'h22;
			8'h61 : PATTERN = 8'h1E;
			8'h62 : PATTERN = 8'h3E;
			8'h63 : PATTERN = 8'h0E;
			8'h64 : PATTERN = 8'h04;
			8'h65 : PATTERN = 8'h3C;
			8'h66 : PATTERN = 8'h3C;
			8'h67 : PATTERN = 8'h08;
			8'h68 : PATTERN = 8'h18;
			8'h69 : PATTERN = 8'h10;
			8'h6a : PATTERN = 8'h60;
			8'h6b : PATTERN = 8'hC0;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h38;
			8'h71 : PATTERN = 8'hF8;
			8'h72 : PATTERN = 8'hE4;
			8'h73 : PATTERN = 8'hE4;
			8'h74 : PATTERN = 8'hCE;
			8'h75 : PATTERN = 8'h9E;
			8'h76 : PATTERN = 8'hBE;
			8'h77 : PATTERN = 8'h7F;
			8'h78 : PATTERN = 8'h7F;
			8'h79 : PATTERN = 8'h3F;
			8'h7a : PATTERN = 8'h3F;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o3: begin //3
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h10;
			8'h4 : PATTERN = 8'h33;
			8'h5 : PATTERN = 8'h67;
			8'h6 : PATTERN = 8'h44;
			8'h7 : PATTERN = 8'h44;
			8'h8 : PATTERN = 8'h6D;
			8'h9 : PATTERN = 8'h39;
			8'ha : PATTERN = 8'h10;
			8'hb : PATTERN = 8'h10;
			8'hc : PATTERN = 8'h1C;
			8'hd : PATTERN = 8'h17;
			8'he : PATTERN = 8'h11;
			8'hf : PATTERN = 8'h7F;
			8'h10 : PATTERN = 8'h7F;
			8'h11 : PATTERN = 8'h10;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h63;
			8'h14 : PATTERN = 8'h63;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h10;
			8'h1a : PATTERN = 8'h33;
			8'h1b : PATTERN = 8'h67;
			8'h1c : PATTERN = 8'h44;
			8'h1d : PATTERN = 8'h44;
			8'h1e : PATTERN = 8'h6D;
			8'h1f : PATTERN = 8'h39;
			8'h20 : PATTERN = 8'h10;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'h7F;
			8'h23 : PATTERN = 8'h7F;
			8'h24 : PATTERN = 8'h44;
			8'h25 : PATTERN = 8'h44;
			8'h26 : PATTERN = 8'h44;
			8'h27 : PATTERN = 8'h40;
			8'h28 : PATTERN = 8'h40;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'h7F;
			8'h2b : PATTERN = 8'h7F;
			8'h2c : PATTERN = 8'h01;
			8'h2d : PATTERN = 8'h07;
			8'h2e : PATTERN = 8'h1E;
			8'h2f : PATTERN = 8'h78;
			8'h30 : PATTERN = 8'h7F;
			8'h31 : PATTERN = 8'h7F;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'h7F;
			8'h34 : PATTERN = 8'h7F;
			8'h35 : PATTERN = 8'h40;
			8'h36 : PATTERN = 8'h40;
			8'h37 : PATTERN = 8'h60;
			8'h38 : PATTERN = 8'h71;
			8'h39 : PATTERN = 8'h3F;
			8'h3a : PATTERN = 8'h1F;
			8'h3b : PATTERN = 8'h00;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'h00;
			8'h40 : PATTERN = 8'h00;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h02;
			8'h45 : PATTERN = 8'h02;
			8'h46 : PATTERN = 8'h01;
			8'h47 : PATTERN = 8'h01;
			8'h48 : PATTERN = 8'h7D;
			8'h49 : PATTERN = 8'hF7;
			8'h4a : PATTERN = 8'h0C;
			8'h4b : PATTERN = 8'h1C;
			8'h4c : PATTERN = 8'h0F;
			8'h4d : PATTERN = 8'h03;
			8'h4e : PATTERN = 8'h00;
			8'h4f : PATTERN = 8'h00;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h04;
			8'h52 : PATTERN = 8'h02;
			8'h53 : PATTERN = 8'h06;
			8'h54 : PATTERN = 8'h00;
			8'h55 : PATTERN = 8'h00;
			8'h56 : PATTERN = 8'h00;
			8'h57 : PATTERN = 8'h01;
			8'h58 : PATTERN = 8'h01;
			8'h59 : PATTERN = 8'h06;
			8'h5a : PATTERN = 8'h06;
			8'h5b : PATTERN = 8'h00;
			8'h5c : PATTERN = 8'h00;
			8'h5d : PATTERN = 8'h00;
			8'h5e : PATTERN = 8'h00;
			8'h5f : PATTERN = 8'h00;
			8'h60 : PATTERN = 8'h00;
			8'h61 : PATTERN = 8'h00;
			8'h62 : PATTERN = 8'h00;
			8'h63 : PATTERN = 8'h00;
			8'h64 : PATTERN = 8'h00;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h00;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'h00;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h07;
			8'h6d : PATTERN = 8'hFC;
			8'h6e : PATTERN = 8'hF0;
			8'h6f : PATTERN = 8'hF0;
			8'h70 : PATTERN = 8'h48;
			8'h71 : PATTERN = 8'h78;
			8'h72 : PATTERN = 8'h7F;
			8'h73 : PATTERN = 8'h3F;
			8'h74 : PATTERN = 8'h3B;
			8'h75 : PATTERN = 8'h13;
			8'h76 : PATTERN = 8'h0E;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o4: begin //4
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h70;
			8'h5 : PATTERN = 8'hF8;
			8'h6 : PATTERN = 8'h88;
			8'h7 : PATTERN = 8'h88;
			8'h8 : PATTERN = 8'hB8;
			8'h9 : PATTERN = 8'h30;
			8'ha : PATTERN = 8'h00;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'hF8;
			8'hd : PATTERN = 8'hC8;
			8'he : PATTERN = 8'h48;
			8'hf : PATTERN = 8'hC8;
			8'h10 : PATTERN = 8'h88;
			8'h11 : PATTERN = 8'h00;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h60;
			8'h14 : PATTERN = 8'h60;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h00;
			8'h1a : PATTERN = 8'hF0;
			8'h1b : PATTERN = 8'hF8;
			8'h1c : PATTERN = 8'h18;
			8'h1d : PATTERN = 8'h08;
			8'h1e : PATTERN = 8'h08;
			8'h1f : PATTERN = 8'h38;
			8'h20 : PATTERN = 8'h30;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'h00;
			8'h23 : PATTERN = 8'hF8;
			8'h24 : PATTERN = 8'hF8;
			8'h25 : PATTERN = 8'h00;
			8'h26 : PATTERN = 8'h00;
			8'h27 : PATTERN = 8'h00;
			8'h28 : PATTERN = 8'h00;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'hF8;
			8'h2b : PATTERN = 8'hF8;
			8'h2c : PATTERN = 8'h88;
			8'h2d : PATTERN = 8'h88;
			8'h2e : PATTERN = 8'h88;
			8'h2f : PATTERN = 8'h08;
			8'h30 : PATTERN = 8'h08;
			8'h31 : PATTERN = 8'h00;
			8'h32 : PATTERN = 8'h00;
			8'h33 : PATTERN = 8'hE0;
			8'h34 : PATTERN = 8'h78;
			8'h35 : PATTERN = 8'h38;
			8'h36 : PATTERN = 8'hF8;
			8'h37 : PATTERN = 8'h80;
			8'h38 : PATTERN = 8'h00;
			8'h39 : PATTERN = 8'h00;
			8'h3a : PATTERN = 8'hF8;
			8'h3b : PATTERN = 8'hF8;
			8'h3c : PATTERN = 8'h88;
			8'h3d : PATTERN = 8'h88;
			8'h3e : PATTERN = 8'h88;
			8'h3f : PATTERN = 8'hF8;
			8'h40 : PATTERN = 8'h70;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h00;
			8'h47 : PATTERN = 8'h00;
			8'h48 : PATTERN = 8'h00;
			8'h49 : PATTERN = 8'h0F;
			8'h4a : PATTERN = 8'h38;
			8'h4b : PATTERN = 8'hE0;
			8'h4c : PATTERN = 8'hC0;
			8'h4d : PATTERN = 8'h00;
			8'h4e : PATTERN = 8'h00;
			8'h4f : PATTERN = 8'h00;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h00;
			8'h53 : PATTERN = 8'h00;
			8'h54 : PATTERN = 8'h00;
			8'h55 : PATTERN = 8'h00;
			8'h56 : PATTERN = 8'h00;
			8'h57 : PATTERN = 8'h00;
			8'h58 : PATTERN = 8'h00;
			8'h59 : PATTERN = 8'h00;
			8'h5a : PATTERN = 8'h00;
			8'h5b : PATTERN = 8'h00;
			8'h5c : PATTERN = 8'h00;
			8'h5d : PATTERN = 8'h00;
			8'h5e : PATTERN = 8'h00;
			8'h5f : PATTERN = 8'h00;
			8'h60 : PATTERN = 8'h00;
			8'h61 : PATTERN = 8'h00;
			8'h62 : PATTERN = 8'h00;
			8'h63 : PATTERN = 8'h00;
			8'h64 : PATTERN = 8'h00;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h80;
			8'h67 : PATTERN = 8'h80;
			8'h68 : PATTERN = 8'h80;
			8'h69 : PATTERN = 8'h80;
			8'h6a : PATTERN = 8'hE0;
			8'h6b : PATTERN = 8'hB0;
			8'h6c : PATTERN = 8'h0C;
			8'h6d : PATTERN = 8'h03;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o5: begin //5
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h02;
			8'h4 : PATTERN = 8'h06;
			8'h5 : PATTERN = 8'h0C;
			8'h6 : PATTERN = 8'h08;
			8'h7 : PATTERN = 8'h08;
			8'h8 : PATTERN = 8'h0D;
			8'h9 : PATTERN = 8'h07;
			8'ha : PATTERN = 8'h02;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'h0C;
			8'hd : PATTERN = 8'h0C;
			8'he : PATTERN = 8'h08;
			8'hf : PATTERN = 8'h0C;
			8'h10 : PATTERN = 8'h07;
			8'h11 : PATTERN = 8'h00;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h0C;
			8'h14 : PATTERN = 8'h0C;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'h00;
			8'h1a : PATTERN = 8'h07;
			8'h1b : PATTERN = 8'h0F;
			8'h1c : PATTERN = 8'h0C;
			8'h1d : PATTERN = 8'h08;
			8'h1e : PATTERN = 8'h08;
			8'h1f : PATTERN = 8'h0E;
			8'h20 : PATTERN = 8'h06;
			8'h21 : PATTERN = 8'h00;
			8'h22 : PATTERN = 8'h00;
			8'h23 : PATTERN = 8'h0F;
			8'h24 : PATTERN = 8'h0F;
			8'h25 : PATTERN = 8'h08;
			8'h26 : PATTERN = 8'h08;
			8'h27 : PATTERN = 8'h08;
			8'h28 : PATTERN = 8'h08;
			8'h29 : PATTERN = 8'h00;
			8'h2a : PATTERN = 8'h0F;
			8'h2b : PATTERN = 8'h0F;
			8'h2c : PATTERN = 8'h08;
			8'h2d : PATTERN = 8'h08;
			8'h2e : PATTERN = 8'h08;
			8'h2f : PATTERN = 8'h08;
			8'h30 : PATTERN = 8'h08;
			8'h31 : PATTERN = 8'h08;
			8'h32 : PATTERN = 8'h0F;
			8'h33 : PATTERN = 8'h03;
			8'h34 : PATTERN = 8'h01;
			8'h35 : PATTERN = 8'h01;
			8'h36 : PATTERN = 8'h03;
			8'h37 : PATTERN = 8'h0F;
			8'h38 : PATTERN = 8'h0C;
			8'h39 : PATTERN = 8'h00;
			8'h3a : PATTERN = 8'h0F;
			8'h3b : PATTERN = 8'h0F;
			8'h3c : PATTERN = 8'h00;
			8'h3d : PATTERN = 8'h00;
			8'h3e : PATTERN = 8'h03;
			8'h3f : PATTERN = 8'h0E;
			8'h40 : PATTERN = 8'h0C;
			8'h41 : PATTERN = 8'h00;
			8'h42 : PATTERN = 8'h00;
			8'h43 : PATTERN = 8'h00;
			8'h44 : PATTERN = 8'h00;
			8'h45 : PATTERN = 8'h00;
			8'h46 : PATTERN = 8'h00;
			8'h47 : PATTERN = 8'h00;
			8'h48 : PATTERN = 8'h00;
			8'h49 : PATTERN = 8'h00;
			8'h4a : PATTERN = 8'h00;
			8'h4b : PATTERN = 8'h01;
			8'h4c : PATTERN = 8'h02;
			8'h4d : PATTERN = 8'h01;
			8'h4e : PATTERN = 8'h01;
			8'h4f : PATTERN = 8'h01;
			8'h50 : PATTERN = 8'h03;
			8'h51 : PATTERN = 8'h02;
			8'h52 : PATTERN = 8'h02;
			8'h53 : PATTERN = 8'h82;
			8'h54 : PATTERN = 8'hF2;
			8'h55 : PATTERN = 8'hFE;
			8'h56 : PATTERN = 8'hFC;
			8'h57 : PATTERN = 8'hFE;
			8'h58 : PATTERN = 8'hFF;
			8'h59 : PATTERN = 8'hFE;
			8'h5a : PATTERN = 8'h3E;
			8'h5b : PATTERN = 8'h3E;
			8'h5c : PATTERN = 8'h3E;
			8'h5d : PATTERN = 8'h3E;
			8'h5e : PATTERN = 8'h7E;
			8'h5f : PATTERN = 8'hFF;
			8'h60 : PATTERN = 8'hFF;
			8'h61 : PATTERN = 8'hFF;
			8'h62 : PATTERN = 8'hFE;
			8'h63 : PATTERN = 8'hF3;
			8'h64 : PATTERN = 8'hC1;
			8'h65 : PATTERN = 8'h01;
			8'h66 : PATTERN = 8'h01;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h01;
			8'h6a : PATTERN = 8'h01;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o6: begin //6
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h00;
			8'h2 : PATTERN = 8'h00;
			8'h3 : PATTERN = 8'h00;
			8'h4 : PATTERN = 8'h00;
			8'h5 : PATTERN = 8'h9E;
			8'h6 : PATTERN = 8'h1B;
			8'h7 : PATTERN = 8'h31;
			8'h8 : PATTERN = 8'h31;
			8'h9 : PATTERN = 8'hE3;
			8'ha : PATTERN = 8'hC0;
			8'hb : PATTERN = 8'h00;
			8'hc : PATTERN = 8'hEE;
			8'hd : PATTERN = 8'hBF;
			8'he : PATTERN = 8'h11;
			8'hf : PATTERN = 8'h39;
			8'h10 : PATTERN = 8'hEF;
			8'h11 : PATTERN = 8'hE0;
			8'h12 : PATTERN = 8'h00;
			8'h13 : PATTERN = 8'h8C;
			8'h14 : PATTERN = 8'h8C;
			8'h15 : PATTERN = 8'h00;
			8'h16 : PATTERN = 8'h00;
			8'h17 : PATTERN = 8'h00;
			8'h18 : PATTERN = 8'h00;
			8'h19 : PATTERN = 8'hFF;
			8'h1a : PATTERN = 8'hFF;
			8'h1b : PATTERN = 8'h11;
			8'h1c : PATTERN = 8'h31;
			8'h1d : PATTERN = 8'h7F;
			8'h1e : PATTERN = 8'hCE;
			8'h1f : PATTERN = 8'h80;
			8'h20 : PATTERN = 8'h00;
			8'h21 : PATTERN = 8'hFF;
			8'h22 : PATTERN = 8'hFF;
			8'h23 : PATTERN = 8'h11;
			8'h24 : PATTERN = 8'h11;
			8'h25 : PATTERN = 8'h11;
			8'h26 : PATTERN = 8'h00;
			8'h27 : PATTERN = 8'h00;
			8'h28 : PATTERN = 8'h9E;
			8'h29 : PATTERN = 8'h1B;
			8'h2a : PATTERN = 8'h31;
			8'h2b : PATTERN = 8'h31;
			8'h2c : PATTERN = 8'hE3;
			8'h2d : PATTERN = 8'hC0;
			8'h2e : PATTERN = 8'h01;
			8'h2f : PATTERN = 8'h01;
			8'h30 : PATTERN = 8'h01;
			8'h31 : PATTERN = 8'hFF;
			8'h32 : PATTERN = 8'h01;
			8'h33 : PATTERN = 8'h01;
			8'h34 : PATTERN = 8'h01;
			8'h35 : PATTERN = 8'h80;
			8'h36 : PATTERN = 8'hE0;
			8'h37 : PATTERN = 8'h38;
			8'h38 : PATTERN = 8'h2F;
			8'h39 : PATTERN = 8'h23;
			8'h3a : PATTERN = 8'h2F;
			8'h3b : PATTERN = 8'h3C;
			8'h3c : PATTERN = 8'hE0;
			8'h3d : PATTERN = 8'h80;
			8'h3e : PATTERN = 8'h00;
			8'h3f : PATTERN = 8'hFF;
			8'h40 : PATTERN = 8'hFF;
			8'h41 : PATTERN = 8'h11;
			8'h42 : PATTERN = 8'h31;
			8'h43 : PATTERN = 8'h7F;
			8'h44 : PATTERN = 8'hCE;
			8'h45 : PATTERN = 8'h80;
			8'h46 : PATTERN = 8'h01;
			8'h47 : PATTERN = 8'h01;
			8'h48 : PATTERN = 8'h01;
			8'h49 : PATTERN = 8'hFF;
			8'h4a : PATTERN = 8'h01;
			8'h4b : PATTERN = 8'h01;
			8'h4c : PATTERN = 8'h01;
			8'h4d : PATTERN = 8'h00;
			8'h4e : PATTERN = 8'h00;
			8'h4f : PATTERN = 8'h00;
			8'h50 : PATTERN = 8'h00;
			8'h51 : PATTERN = 8'h00;
			8'h52 : PATTERN = 8'h00;
			8'h53 : PATTERN = 8'h07;
			8'h54 : PATTERN = 8'h3F;
			8'h55 : PATTERN = 8'h4F;
			8'h56 : PATTERN = 8'h8F;
			8'h57 : PATTERN = 8'h0F;
			8'h58 : PATTERN = 8'h0F;
			8'h59 : PATTERN = 8'h07;
			8'h5a : PATTERN = 8'h0C;
			8'h5b : PATTERN = 8'h08;
			8'h5c : PATTERN = 8'h08;
			8'h5d : PATTERN = 8'h0C;
			8'h5e : PATTERN = 8'h04;
			8'h5f : PATTERN = 8'h03;
			8'h60 : PATTERN = 8'h03;
			8'h61 : PATTERN = 8'h83;
			8'h62 : PATTERN = 8'hC3;
			8'h63 : PATTERN = 8'h31;
			8'h64 : PATTERN = 8'h0F;
			8'h65 : PATTERN = 8'h00;
			8'h66 : PATTERN = 8'h00;
			8'h67 : PATTERN = 8'h00;
			8'h68 : PATTERN = 8'h00;
			8'h69 : PATTERN = 8'h00;
			8'h6a : PATTERN = 8'h00;
			8'h6b : PATTERN = 8'h00;
			8'h6c : PATTERN = 8'h00;
			8'h6d : PATTERN = 8'h00;
			8'h6e : PATTERN = 8'h00;
			8'h6f : PATTERN = 8'h00;
			8'h70 : PATTERN = 8'h00;
			8'h71 : PATTERN = 8'h00;
			8'h72 : PATTERN = 8'h00;
			8'h73 : PATTERN = 8'h00;
			8'h74 : PATTERN = 8'h00;
			8'h75 : PATTERN = 8'h00;
			8'h76 : PATTERN = 8'h00;
			8'h77 : PATTERN = 8'h00;
			8'h78 : PATTERN = 8'h00;
			8'h79 : PATTERN = 8'h00;
			8'h7a : PATTERN = 8'h00;
			8'h7b : PATTERN = 8'h00;
			8'h7c : PATTERN = 8'h00;
			8'h7d : PATTERN = 8'h00;
			8'h7e : PATTERN = 8'h00;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			3'o7: begin //7
			case(INDEX)
			8'h0 : PATTERN = 8'hFF;
			8'h1 : PATTERN = 8'h80;
			8'h2 : PATTERN = 8'h80;
			8'h3 : PATTERN = 8'h80;
			8'h4 : PATTERN = 8'h80;
			8'h5 : PATTERN = 8'h81;
			8'h6 : PATTERN = 8'h81;
			8'h7 : PATTERN = 8'h81;
			8'h8 : PATTERN = 8'h81;
			8'h9 : PATTERN = 8'h81;
			8'ha : PATTERN = 8'h80;
			8'hb : PATTERN = 8'h80;
			8'hc : PATTERN = 8'h81;
			8'hd : PATTERN = 8'h81;
			8'he : PATTERN = 8'h81;
			8'hf : PATTERN = 8'h81;
			8'h10 : PATTERN = 8'h81;
			8'h11 : PATTERN = 8'h80;
			8'h12 : PATTERN = 8'h80;
			8'h13 : PATTERN = 8'h81;
			8'h14 : PATTERN = 8'h81;
			8'h15 : PATTERN = 8'h80;
			8'h16 : PATTERN = 8'h80;
			8'h17 : PATTERN = 8'h80;
			8'h18 : PATTERN = 8'h80;
			8'h19 : PATTERN = 8'h81;
			8'h1a : PATTERN = 8'h81;
			8'h1b : PATTERN = 8'h80;
			8'h1c : PATTERN = 8'h80;
			8'h1d : PATTERN = 8'h80;
			8'h1e : PATTERN = 8'h81;
			8'h1f : PATTERN = 8'h81;
			8'h20 : PATTERN = 8'h80;
			8'h21 : PATTERN = 8'h81;
			8'h22 : PATTERN = 8'h81;
			8'h23 : PATTERN = 8'h81;
			8'h24 : PATTERN = 8'h81;
			8'h25 : PATTERN = 8'h81;
			8'h26 : PATTERN = 8'h81;
			8'h27 : PATTERN = 8'h80;
			8'h28 : PATTERN = 8'h81;
			8'h29 : PATTERN = 8'h81;
			8'h2a : PATTERN = 8'h81;
			8'h2b : PATTERN = 8'h81;
			8'h2c : PATTERN = 8'h81;
			8'h2d : PATTERN = 8'h80;
			8'h2e : PATTERN = 8'h80;
			8'h2f : PATTERN = 8'h80;
			8'h30 : PATTERN = 8'h80;
			8'h31 : PATTERN = 8'h81;
			8'h32 : PATTERN = 8'h80;
			8'h33 : PATTERN = 8'h80;
			8'h34 : PATTERN = 8'h80;
			8'h35 : PATTERN = 8'h81;
			8'h36 : PATTERN = 8'h81;
			8'h37 : PATTERN = 8'h80;
			8'h38 : PATTERN = 8'h80;
			8'h39 : PATTERN = 8'h80;
			8'h3a : PATTERN = 8'h80;
			8'h3b : PATTERN = 8'h80;
			8'h3c : PATTERN = 8'h81;
			8'h3d : PATTERN = 8'h81;
			8'h3e : PATTERN = 8'h80;
			8'h3f : PATTERN = 8'h81;
			8'h40 : PATTERN = 8'h81;
			8'h41 : PATTERN = 8'h80;
			8'h42 : PATTERN = 8'h80;
			8'h43 : PATTERN = 8'h80;
			8'h44 : PATTERN = 8'h81;
			8'h45 : PATTERN = 8'h81;
			8'h46 : PATTERN = 8'h80;
			8'h47 : PATTERN = 8'h80;
			8'h48 : PATTERN = 8'h80;
			8'h49 : PATTERN = 8'h81;
			8'h4a : PATTERN = 8'h80;
			8'h4b : PATTERN = 8'h80;
			8'h4c : PATTERN = 8'h80;
			8'h4d : PATTERN = 8'h80;
			8'h4e : PATTERN = 8'h80;
			8'h4f : PATTERN = 8'h80;
			8'h50 : PATTERN = 8'h80;
			8'h51 : PATTERN = 8'h80;
			8'h52 : PATTERN = 8'h80;
			8'h53 : PATTERN = 8'h80;
			8'h54 : PATTERN = 8'h80;
			8'h55 : PATTERN = 8'h80;
			8'h56 : PATTERN = 8'h80;
			8'h57 : PATTERN = 8'h81;
			8'h58 : PATTERN = 8'h81;
			8'h59 : PATTERN = 8'h81;
			8'h5a : PATTERN = 8'h83;
			8'h5b : PATTERN = 8'h82;
			8'h5c : PATTERN = 8'h82;
			8'h5d : PATTERN = 8'h82;
			8'h5e : PATTERN = 8'h82;
			8'h5f : PATTERN = 8'h81;
			8'h60 : PATTERN = 8'h81;
			8'h61 : PATTERN = 8'h80;
			8'h62 : PATTERN = 8'h80;
			8'h63 : PATTERN = 8'h80;
			8'h64 : PATTERN = 8'h80;
			8'h65 : PATTERN = 8'h80;
			8'h66 : PATTERN = 8'h80;
			8'h67 : PATTERN = 8'h80;
			8'h68 : PATTERN = 8'h80;
			8'h69 : PATTERN = 8'h80;
			8'h6a : PATTERN = 8'h80;
			8'h6b : PATTERN = 8'h80;
			8'h6c : PATTERN = 8'h80;
			8'h6d : PATTERN = 8'h80;
			8'h6e : PATTERN = 8'h80;
			8'h6f : PATTERN = 8'h80;
			8'h70 : PATTERN = 8'h80;
			8'h71 : PATTERN = 8'h80;
			8'h72 : PATTERN = 8'h80;
			8'h73 : PATTERN = 8'h80;
			8'h74 : PATTERN = 8'h80;
			8'h75 : PATTERN = 8'h80;
			8'h76 : PATTERN = 8'h80;
			8'h77 : PATTERN = 8'h80;
			8'h78 : PATTERN = 8'h80;
			8'h79 : PATTERN = 8'h80;
			8'h7a : PATTERN = 8'h80;
			8'h7b : PATTERN = 8'h80;
			8'h7c : PATTERN = 8'h80;
			8'h7d : PATTERN = 8'h80;
			8'h7e : PATTERN = 8'h80;
			8'h7f : PATTERN = 8'hFF;
			endcase
			end
			endcase
		end
		else begin
			case(state)
				start: begin//PIC22
				case(X_PAGE)
					3'o0: begin //0
					case(INDEX)
					8'h0 : PATTERN = 8'h0;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h08;
					8'h8 : PATTERN = 8'h98;
					8'h9 : PATTERN = 8'hA8;
					8'ha : PATTERN = 8'hE4;
					8'hb : PATTERN = 8'hC4;
					8'hc : PATTERN = 8'hC4;
					8'hd : PATTERN = 8'h88;
					8'he : PATTERN = 8'h88;
					8'hf : PATTERN = 8'hC8;
					8'h10 : PATTERN = 8'hF8;
					8'h11 : PATTERN = 8'hF8;
					8'h12 : PATTERN = 8'h04;
					8'h13 : PATTERN = 8'h02;
					8'h14 : PATTERN = 8'h82;
					8'h15 : PATTERN = 8'h82;
					8'h16 : PATTERN = 8'hE1;
					8'h17 : PATTERN = 8'hC1;
					8'h18 : PATTERN = 8'h01;
					8'h19 : PATTERN = 8'h03;
					8'h1a : PATTERN = 8'hC2;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'hC0;
					8'h1d : PATTERN = 8'h80;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h08;
					8'h20 : PATTERN = 8'h1C;
					8'h21 : PATTERN = 8'h3C;
					8'h22 : PATTERN = 8'hFE;
					8'h23 : PATTERN = 8'hDE;
					8'h24 : PATTERN = 8'hE2;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'hE0;
					8'h34 : PATTERN = 8'hF0;
					8'h35 : PATTERN = 8'hF8;
					8'h36 : PATTERN = 8'h3C;
					8'h37 : PATTERN = 8'h1C;
					8'h38 : PATTERN = 8'h0E;
					8'h39 : PATTERN = 8'h0F;
					8'h3a : PATTERN = 8'h07;
					8'h3b : PATTERN = 8'h07;
					8'h3c : PATTERN = 8'h07;
					8'h3d : PATTERN = 8'h03;
					8'h3e : PATTERN = 8'h03;
					8'h3f : PATTERN = 8'h03;
					8'h40 : PATTERN = 8'h03;
					8'h41 : PATTERN = 8'h03;
					8'h42 : PATTERN = 8'h03;
					8'h43 : PATTERN = 8'h03;
					8'h44 : PATTERN = 8'h03;
					8'h45 : PATTERN = 8'h03;
					8'h46 : PATTERN = 8'h03;
					8'h47 : PATTERN = 8'hC3;
					8'h48 : PATTERN = 8'hC3;
					8'h49 : PATTERN = 8'h43;
					8'h4a : PATTERN = 8'h43;
					8'h4b : PATTERN = 8'hC3;
					8'h4c : PATTERN = 8'hC3;
					8'h4d : PATTERN = 8'h83;
					8'h4e : PATTERN = 8'h03;
					8'h4f : PATTERN = 8'hC3;
					8'h50 : PATTERN = 8'hC3;
					8'h51 : PATTERN = 8'h43;
					8'h52 : PATTERN = 8'h43;
					8'h53 : PATTERN = 8'hC3;
					8'h54 : PATTERN = 8'hC3;
					8'h55 : PATTERN = 8'h03;
					8'h56 : PATTERN = 8'h03;
					8'h57 : PATTERN = 8'hC3;
					8'h58 : PATTERN = 8'hC3;
					8'h59 : PATTERN = 8'h43;
					8'h5a : PATTERN = 8'h43;
					8'h5b : PATTERN = 8'h43;
					8'h5c : PATTERN = 8'h03;
					8'h5d : PATTERN = 8'h03;
					8'h5e : PATTERN = 8'h83;
					8'h5f : PATTERN = 8'hC3;
					8'h60 : PATTERN = 8'h43;
					8'h61 : PATTERN = 8'h43;
					8'h62 : PATTERN = 8'hC3;
					8'h63 : PATTERN = 8'h03;
					8'h64 : PATTERN = 8'h03;
					8'h65 : PATTERN = 8'h83;
					8'h66 : PATTERN = 8'hC3;
					8'h67 : PATTERN = 8'h43;
					8'h68 : PATTERN = 8'h43;
					8'h69 : PATTERN = 8'hC3;
					8'h6a : PATTERN = 8'h03;
					8'h6b : PATTERN = 8'h03;
					8'h6c : PATTERN = 8'h03;
					8'h6d : PATTERN = 8'h03;
					8'h6e : PATTERN = 8'h03;
					8'h6f : PATTERN = 8'h03;
					8'h70 : PATTERN = 8'h03;
					8'h71 : PATTERN = 8'h03;
					8'h72 : PATTERN = 8'h03;
					8'h73 : PATTERN = 8'h03;
					8'h74 : PATTERN = 8'h03;
					8'h75 : PATTERN = 8'h03;
					8'h76 : PATTERN = 8'h07;
					8'h77 : PATTERN = 8'h07;
					8'h78 : PATTERN = 8'h0F;
					8'h79 : PATTERN = 8'h0E;
					8'h7a : PATTERN = 8'h1E;
					8'h7b : PATTERN = 8'h3C;
					8'h7c : PATTERN = 8'hF8;
					8'h7d : PATTERN = 8'hF0;
					8'h7e : PATTERN = 8'hE0;
					8'h7f : PATTERN = 8'h80;
					endcase
					end
					3'o1: begin //1
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'hFD;
					8'hb : PATTERN = 8'h07;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'hFC;
					8'he : PATTERN = 8'hFF;
					8'hf : PATTERN = 8'hFF;
					8'h10 : PATTERN = 8'hFF;
					8'h11 : PATTERN = 8'hAF;
					8'h12 : PATTERN = 8'hF8;
					8'h13 : PATTERN = 8'hF0;
					8'h14 : PATTERN = 8'h7F;
					8'h15 : PATTERN = 8'hFD;
					8'h16 : PATTERN = 8'hFC;
					8'h17 : PATTERN = 8'h7F;
					8'h18 : PATTERN = 8'h1F;
					8'h19 : PATTERN = 8'h0C;
					8'h1a : PATTERN = 8'h08;
					8'h1b : PATTERN = 8'h17;
					8'h1c : PATTERN = 8'hFE;
					8'h1d : PATTERN = 8'hFF;
					8'h1e : PATTERN = 8'h1C;
					8'h1f : PATTERN = 8'hF1;
					8'h20 : PATTERN = 8'hFC;
					8'h21 : PATTERN = 8'hC0;
					8'h22 : PATTERN = 8'h3D;
					8'h23 : PATTERN = 8'hFF;
					8'h24 : PATTERN = 8'hFF;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'hFF;
					8'h33 : PATTERN = 8'hFF;
					8'h34 : PATTERN = 8'hFF;
					8'h35 : PATTERN = 8'h00;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h7F;
					8'h48 : PATTERN = 8'h7F;
					8'h49 : PATTERN = 8'h08;
					8'h4a : PATTERN = 8'h08;
					8'h4b : PATTERN = 8'h0C;
					8'h4c : PATTERN = 8'h07;
					8'h4d : PATTERN = 8'h03;
					8'h4e : PATTERN = 8'h00;
					8'h4f : PATTERN = 8'h7F;
					8'h50 : PATTERN = 8'h7F;
					8'h51 : PATTERN = 8'h04;
					8'h52 : PATTERN = 8'h0C;
					8'h53 : PATTERN = 8'h1F;
					8'h54 : PATTERN = 8'h73;
					8'h55 : PATTERN = 8'h60;
					8'h56 : PATTERN = 8'h40;
					8'h57 : PATTERN = 8'h7F;
					8'h58 : PATTERN = 8'h7F;
					8'h59 : PATTERN = 8'h44;
					8'h5a : PATTERN = 8'h44;
					8'h5b : PATTERN = 8'h44;
					8'h5c : PATTERN = 8'h40;
					8'h5d : PATTERN = 8'h61;
					8'h5e : PATTERN = 8'h67;
					8'h5f : PATTERN = 8'h47;
					8'h60 : PATTERN = 8'h4C;
					8'h61 : PATTERN = 8'h4C;
					8'h62 : PATTERN = 8'h78;
					8'h63 : PATTERN = 8'h30;
					8'h64 : PATTERN = 8'h61;
					8'h65 : PATTERN = 8'h67;
					8'h66 : PATTERN = 8'h47;
					8'h67 : PATTERN = 8'h4C;
					8'h68 : PATTERN = 8'h4C;
					8'h69 : PATTERN = 8'h78;
					8'h6a : PATTERN = 8'h30;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'hFF;
					8'h7e : PATTERN = 8'hFF;
					8'h7f : PATTERN = 8'hFF;
					endcase
					end
					3'o2: begin //2
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h80;
					8'h5 : PATTERN = 8'h40;
					8'h6 : PATTERN = 8'h20;
					8'h7 : PATTERN = 8'h10;
					8'h8 : PATTERN = 8'h18;
					8'h9 : PATTERN = 8'h06;
					8'ha : PATTERN = 8'h81;
					8'hb : PATTERN = 8'h80;
					8'hc : PATTERN = 8'h30;
					8'hd : PATTERN = 8'h8F;
					8'he : PATTERN = 8'h7F;
					8'hf : PATTERN = 8'h03;
					8'h10 : PATTERN = 8'hC7;
					8'h11 : PATTERN = 8'h37;
					8'h12 : PATTERN = 8'h9F;
					8'h13 : PATTERN = 8'hCF;
					8'h14 : PATTERN = 8'h39;
					8'h15 : PATTERN = 8'h31;
					8'h16 : PATTERN = 8'h30;
					8'h17 : PATTERN = 8'h60;
					8'h18 : PATTERN = 8'h60;
					8'h19 : PATTERN = 8'hC8;
					8'h1a : PATTERN = 8'hE8;
					8'h1b : PATTERN = 8'hE0;
					8'h1c : PATTERN = 8'hC0;
					8'h1d : PATTERN = 8'hD1;
					8'h1e : PATTERN = 8'hF1;
					8'h1f : PATTERN = 8'h9F;
					8'h20 : PATTERN = 8'hFF;
					8'h21 : PATTERN = 8'h7F;
					8'h22 : PATTERN = 8'hC8;
					8'h23 : PATTERN = 8'h03;
					8'h24 : PATTERN = 8'h01;
					8'h25 : PATTERN = 8'h30;
					8'h26 : PATTERN = 8'h80;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'hFF;
					8'h33 : PATTERN = 8'hFF;
					8'h34 : PATTERN = 8'hFF;
					8'h35 : PATTERN = 8'h00;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'hF0;
					8'h44 : PATTERN = 8'hF0;
					8'h45 : PATTERN = 8'h80;
					8'h46 : PATTERN = 8'hC0;
					8'h47 : PATTERN = 8'h60;
					8'h48 : PATTERN = 8'h30;
					8'h49 : PATTERN = 8'h10;
					8'h4a : PATTERN = 8'h00;
					8'h4b : PATTERN = 8'hF0;
					8'h4c : PATTERN = 8'hF0;
					8'h4d : PATTERN = 8'h10;
					8'h4e : PATTERN = 8'h10;
					8'h4f : PATTERN = 8'h10;
					8'h50 : PATTERN = 8'h00;
					8'h51 : PATTERN = 8'h30;
					8'h52 : PATTERN = 8'hF0;
					8'h53 : PATTERN = 8'hC0;
					8'h54 : PATTERN = 8'h00;
					8'h55 : PATTERN = 8'hC0;
					8'h56 : PATTERN = 8'hF0;
					8'h57 : PATTERN = 8'h30;
					8'h58 : PATTERN = 8'h00;
					8'h59 : PATTERN = 8'hF0;
					8'h5a : PATTERN = 8'hF0;
					8'h5b : PATTERN = 8'h10;
					8'h5c : PATTERN = 8'h10;
					8'h5d : PATTERN = 8'h30;
					8'h5e : PATTERN = 8'hF0;
					8'h5f : PATTERN = 8'hE0;
					8'h60 : PATTERN = 8'h00;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'hC0;
					8'h63 : PATTERN = 8'hF0;
					8'h64 : PATTERN = 8'h30;
					8'h65 : PATTERN = 8'hF0;
					8'h66 : PATTERN = 8'hC0;
					8'h67 : PATTERN = 8'h00;
					8'h68 : PATTERN = 8'h00;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'hF0;
					8'h6b : PATTERN = 8'hF0;
					8'h6c : PATTERN = 8'h10;
					8'h6d : PATTERN = 8'h10;
					8'h6e : PATTERN = 8'h30;
					8'h6f : PATTERN = 8'h70;
					8'h70 : PATTERN = 8'hE0;
					8'h71 : PATTERN = 8'hC0;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'hFF;
					8'h7e : PATTERN = 8'hFF;
					8'h7f : PATTERN = 8'hFF;
					endcase
					end
					3'o3: begin //3
					case(INDEX)
					8'h0 : PATTERN = 8'hC0;
					8'h1 : PATTERN = 8'hF8;
					8'h2 : PATTERN = 8'h5E;
					8'h3 : PATTERN = 8'h39;
					8'h4 : PATTERN = 8'h1C;
					8'h5 : PATTERN = 8'h0A;
					8'h6 : PATTERN = 8'h05;
					8'h7 : PATTERN = 8'hFD;
					8'h8 : PATTERN = 8'hC6;
					8'h9 : PATTERN = 8'h73;
					8'ha : PATTERN = 8'h39;
					8'hb : PATTERN = 8'h08;
					8'hc : PATTERN = 8'h86;
					8'hd : PATTERN = 8'h61;
					8'he : PATTERN = 8'h18;
					8'hf : PATTERN = 8'h04;
					8'h10 : PATTERN = 8'h03;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h01;
					8'h13 : PATTERN = 8'h03;
					8'h14 : PATTERN = 8'h02;
					8'h15 : PATTERN = 8'h22;
					8'h16 : PATTERN = 8'hFC;
					8'h17 : PATTERN = 8'hFC;
					8'h18 : PATTERN = 8'h7C;
					8'h19 : PATTERN = 8'h38;
					8'h1a : PATTERN = 8'h18;
					8'h1b : PATTERN = 8'h11;
					8'h1c : PATTERN = 8'h11;
					8'h1d : PATTERN = 8'hE2;
					8'h1e : PATTERN = 8'hA6;
					8'h1f : PATTERN = 8'h61;
					8'h20 : PATTERN = 8'h1F;
					8'h21 : PATTERN = 8'h19;
					8'h22 : PATTERN = 8'h3F;
					8'h23 : PATTERN = 8'h37;
					8'h24 : PATTERN = 8'h26;
					8'h25 : PATTERN = 8'h2C;
					8'h26 : PATTERN = 8'h2D;
					8'h27 : PATTERN = 8'h96;
					8'h28 : PATTERN = 8'h0C;
					8'h29 : PATTERN = 8'hE0;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'hFF;
					8'h33 : PATTERN = 8'hFF;
					8'h34 : PATTERN = 8'hFF;
					8'h35 : PATTERN = 8'h00;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h1F;
					8'h44 : PATTERN = 8'h1F;
					8'h45 : PATTERN = 8'h03;
					8'h46 : PATTERN = 8'h07;
					8'h47 : PATTERN = 8'h0E;
					8'h48 : PATTERN = 8'h1C;
					8'h49 : PATTERN = 8'h18;
					8'h4a : PATTERN = 8'h10;
					8'h4b : PATTERN = 8'h1F;
					8'h4c : PATTERN = 8'h1F;
					8'h4d : PATTERN = 8'h11;
					8'h4e : PATTERN = 8'h11;
					8'h4f : PATTERN = 8'h11;
					8'h50 : PATTERN = 8'h10;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h03;
					8'h54 : PATTERN = 8'h1F;
					8'h55 : PATTERN = 8'h1F;
					8'h56 : PATTERN = 8'h00;
					8'h57 : PATTERN = 8'h00;
					8'h58 : PATTERN = 8'h00;
					8'h59 : PATTERN = 8'h1F;
					8'h5a : PATTERN = 8'h1F;
					8'h5b : PATTERN = 8'h02;
					8'h5c : PATTERN = 8'h02;
					8'h5d : PATTERN = 8'h03;
					8'h5e : PATTERN = 8'h01;
					8'h5f : PATTERN = 8'h00;
					8'h60 : PATTERN = 8'h18;
					8'h61 : PATTERN = 8'h1E;
					8'h62 : PATTERN = 8'h07;
					8'h63 : PATTERN = 8'h03;
					8'h64 : PATTERN = 8'h02;
					8'h65 : PATTERN = 8'h03;
					8'h66 : PATTERN = 8'h07;
					8'h67 : PATTERN = 8'h1F;
					8'h68 : PATTERN = 8'h18;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'h1F;
					8'h6b : PATTERN = 8'h1F;
					8'h6c : PATTERN = 8'h10;
					8'h6d : PATTERN = 8'h10;
					8'h6e : PATTERN = 8'h18;
					8'h6f : PATTERN = 8'h0C;
					8'h70 : PATTERN = 8'h0F;
					8'h71 : PATTERN = 8'h03;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'hFF;
					8'h7e : PATTERN = 8'hFF;
					8'h7f : PATTERN = 8'hFF;
					endcase
					end
					3'o4: begin //4
					case(INDEX)
					8'h0 : PATTERN = 8'h0F;
					8'h1 : PATTERN = 8'h3F;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h7F;
					8'h7 : PATTERN = 8'hFF;
					8'h8 : PATTERN = 8'hA3;
					8'h9 : PATTERN = 8'h20;
					8'ha : PATTERN = 8'hF8;
					8'hb : PATTERN = 8'h86;
					8'hc : PATTERN = 8'h01;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h80;
					8'h14 : PATTERN = 8'h80;
					8'h15 : PATTERN = 8'hC0;
					8'h16 : PATTERN = 8'hE3;
					8'h17 : PATTERN = 8'h6E;
					8'h18 : PATTERN = 8'hF0;
					8'h19 : PATTERN = 8'hF0;
					8'h1a : PATTERN = 8'hE0;
					8'h1b : PATTERN = 8'hE0;
					8'h1c : PATTERN = 8'hE0;
					8'h1d : PATTERN = 8'h5F;
					8'h1e : PATTERN = 8'h7F;
					8'h1f : PATTERN = 8'hC0;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'hE4;
					8'h27 : PATTERN = 8'h7A;
					8'h28 : PATTERN = 8'h3F;
					8'h29 : PATTERN = 8'h0F;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'hFF;
					8'h33 : PATTERN = 8'hFF;
					8'h34 : PATTERN = 8'hFF;
					8'h35 : PATTERN = 8'h00;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h00;
					8'h49 : PATTERN = 8'h00;
					8'h4a : PATTERN = 8'h00;
					8'h4b : PATTERN = 8'h00;
					8'h4c : PATTERN = 8'h00;
					8'h4d : PATTERN = 8'h00;
					8'h4e : PATTERN = 8'h00;
					8'h4f : PATTERN = 8'h00;
					8'h50 : PATTERN = 8'h04;
					8'h51 : PATTERN = 8'h04;
					8'h52 : PATTERN = 8'h04;
					8'h53 : PATTERN = 8'hFC;
					8'h54 : PATTERN = 8'hFC;
					8'h55 : PATTERN = 8'h04;
					8'h56 : PATTERN = 8'h04;
					8'h57 : PATTERN = 8'hE0;
					8'h58 : PATTERN = 8'hF8;
					8'h59 : PATTERN = 8'hB8;
					8'h5a : PATTERN = 8'h0C;
					8'h5b : PATTERN = 8'h04;
					8'h5c : PATTERN = 8'h04;
					8'h5d : PATTERN = 8'h0C;
					8'h5e : PATTERN = 8'h1C;
					8'h5f : PATTERN = 8'hF8;
					8'h60 : PATTERN = 8'hF0;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h00;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h00;
					8'h65 : PATTERN = 8'h00;
					8'h66 : PATTERN = 8'h00;
					8'h67 : PATTERN = 8'h00;
					8'h68 : PATTERN = 8'h00;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'h00;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'hFF;
					8'h7e : PATTERN = 8'hFF;
					8'h7f : PATTERN = 8'hFF;
					endcase
					end
					3'o5: begin //5
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h04;
					8'ha : PATTERN = 8'h0F;
					8'hb : PATTERN = 8'h0F;
					8'hc : PATTERN = 8'hFF;
					8'hd : PATTERN = 8'hFF;
					8'he : PATTERN = 8'h6E;
					8'hf : PATTERN = 8'h76;
					8'h10 : PATTERN = 8'h76;
					8'h11 : PATTERN = 8'hFF;
					8'h12 : PATTERN = 8'hF3;
					8'h13 : PATTERN = 8'hD7;
					8'h14 : PATTERN = 8'h5F;
					8'h15 : PATTERN = 8'h4B;
					8'h16 : PATTERN = 8'h6F;
					8'h17 : PATTERN = 8'hF7;
					8'h18 : PATTERN = 8'h16;
					8'h19 : PATTERN = 8'h09;
					8'h1a : PATTERN = 8'h07;
					8'h1b : PATTERN = 8'h03;
					8'h1c : PATTERN = 8'h01;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h01;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'hFF;
					8'h33 : PATTERN = 8'hFF;
					8'h34 : PATTERN = 8'hFF;
					8'h35 : PATTERN = 8'h00;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h00;
					8'h49 : PATTERN = 8'h00;
					8'h4a : PATTERN = 8'h00;
					8'h4b : PATTERN = 8'h00;
					8'h4c : PATTERN = 8'h00;
					8'h4d : PATTERN = 8'h00;
					8'h4e : PATTERN = 8'h00;
					8'h4f : PATTERN = 8'h00;
					8'h50 : PATTERN = 8'h00;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h07;
					8'h54 : PATTERN = 8'h07;
					8'h55 : PATTERN = 8'h00;
					8'h56 : PATTERN = 8'h00;
					8'h57 : PATTERN = 8'h00;
					8'h58 : PATTERN = 8'h03;
					8'h59 : PATTERN = 8'h03;
					8'h5a : PATTERN = 8'h06;
					8'h5b : PATTERN = 8'h04;
					8'h5c : PATTERN = 8'h04;
					8'h5d : PATTERN = 8'h06;
					8'h5e : PATTERN = 8'h07;
					8'h5f : PATTERN = 8'h03;
					8'h60 : PATTERN = 8'h00;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h00;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h00;
					8'h65 : PATTERN = 8'h00;
					8'h66 : PATTERN = 8'h00;
					8'h67 : PATTERN = 8'h00;
					8'h68 : PATTERN = 8'h00;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'h00;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'hFF;
					8'h7e : PATTERN = 8'hFF;
					8'h7f : PATTERN = 8'hFF;
					endcase
					end
					3'o6: begin //6
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'hFF;
					8'he : PATTERN = 8'hFE;
					8'hf : PATTERN = 8'h3C;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'hFF;
					8'h12 : PATTERN = 8'h01;
					8'h13 : PATTERN = 8'h07;
					8'h14 : PATTERN = 8'h1C;
					8'h15 : PATTERN = 8'h60;
					8'h16 : PATTERN = 8'hC0;
					8'h17 : PATTERN = 8'h07;
					8'h18 : PATTERN = 8'h0E;
					8'h19 : PATTERN = 8'h38;
					8'h1a : PATTERN = 8'h80;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'hFF;
					8'h33 : PATTERN = 8'hFF;
					8'h34 : PATTERN = 8'hFF;
					8'h35 : PATTERN = 8'h80;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h84;
					8'h48 : PATTERN = 8'h9E;
					8'h49 : PATTERN = 8'h1F;
					8'h4a : PATTERN = 8'h31;
					8'h4b : PATTERN = 8'h31;
					8'h4c : PATTERN = 8'hE3;
					8'h4d : PATTERN = 8'hC0;
					8'h4e : PATTERN = 8'h01;
					8'h4f : PATTERN = 8'h01;
					8'h50 : PATTERN = 8'h01;
					8'h51 : PATTERN = 8'hFF;
					8'h52 : PATTERN = 8'hFF;
					8'h53 : PATTERN = 8'h01;
					8'h54 : PATTERN = 8'h01;
					8'h55 : PATTERN = 8'h80;
					8'h56 : PATTERN = 8'hE0;
					8'h57 : PATTERN = 8'h7C;
					8'h58 : PATTERN = 8'h3F;
					8'h59 : PATTERN = 8'h23;
					8'h5a : PATTERN = 8'h3F;
					8'h5b : PATTERN = 8'h7C;
					8'h5c : PATTERN = 8'hF0;
					8'h5d : PATTERN = 8'h80;
					8'h5e : PATTERN = 8'h00;
					8'h5f : PATTERN = 8'hFF;
					8'h60 : PATTERN = 8'hFF;
					8'h61 : PATTERN = 8'h11;
					8'h62 : PATTERN = 8'h31;
					8'h63 : PATTERN = 8'h7F;
					8'h64 : PATTERN = 8'hCF;
					8'h65 : PATTERN = 8'h80;
					8'h66 : PATTERN = 8'h01;
					8'h67 : PATTERN = 8'h01;
					8'h68 : PATTERN = 8'h01;
					8'h69 : PATTERN = 8'hFF;
					8'h6a : PATTERN = 8'hFF;
					8'h6b : PATTERN = 8'h01;
					8'h6c : PATTERN = 8'h01;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'hFF;
					8'h7e : PATTERN = 8'hFF;
					8'h7f : PATTERN = 8'hFF;
					endcase
					end
					3'o7: begin //7
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h07;
					8'he : PATTERN = 8'hC7;
					8'hf : PATTERN = 8'hC0;
					8'h10 : PATTERN = 8'hC1;
					8'h11 : PATTERN = 8'h7F;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h01;
					8'h17 : PATTERN = 8'h06;
					8'h18 : PATTERN = 8'h38;
					8'h19 : PATTERN = 8'h60;
					8'h1a : PATTERN = 8'hE3;
					8'h1b : PATTERN = 8'hEE;
					8'h1c : PATTERN = 8'h70;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h03;
					8'h34 : PATTERN = 8'h0F;
					8'h35 : PATTERN = 8'h1F;
					8'h36 : PATTERN = 8'h1E;
					8'h37 : PATTERN = 8'h3C;
					8'h38 : PATTERN = 8'h38;
					8'h39 : PATTERN = 8'h70;
					8'h3a : PATTERN = 8'hF0;
					8'h3b : PATTERN = 8'hE0;
					8'h3c : PATTERN = 8'hE0;
					8'h3d : PATTERN = 8'hE0;
					8'h3e : PATTERN = 8'hE0;
					8'h3f : PATTERN = 8'hE0;
					8'h40 : PATTERN = 8'hE0;
					8'h41 : PATTERN = 8'hE0;
					8'h42 : PATTERN = 8'hE0;
					8'h43 : PATTERN = 8'hE0;
					8'h44 : PATTERN = 8'hE0;
					8'h45 : PATTERN = 8'hE0;
					8'h46 : PATTERN = 8'hE0;
					8'h47 : PATTERN = 8'hE1;
					8'h48 : PATTERN = 8'hE1;
					8'h49 : PATTERN = 8'hE1;
					8'h4a : PATTERN = 8'hE1;
					8'h4b : PATTERN = 8'hE1;
					8'h4c : PATTERN = 8'hE1;
					8'h4d : PATTERN = 8'hE0;
					8'h4e : PATTERN = 8'hE0;
					8'h4f : PATTERN = 8'hE0;
					8'h50 : PATTERN = 8'hE0;
					8'h51 : PATTERN = 8'hE1;
					8'h52 : PATTERN = 8'hE1;
					8'h53 : PATTERN = 8'hE0;
					8'h54 : PATTERN = 8'hE0;
					8'h55 : PATTERN = 8'hE1;
					8'h56 : PATTERN = 8'hE1;
					8'h57 : PATTERN = 8'hE0;
					8'h58 : PATTERN = 8'hE0;
					8'h59 : PATTERN = 8'hE0;
					8'h5a : PATTERN = 8'hE0;
					8'h5b : PATTERN = 8'hE0;
					8'h5c : PATTERN = 8'hE1;
					8'h5d : PATTERN = 8'hE1;
					8'h5e : PATTERN = 8'hE0;
					8'h5f : PATTERN = 8'hE1;
					8'h60 : PATTERN = 8'hE1;
					8'h61 : PATTERN = 8'hE0;
					8'h62 : PATTERN = 8'hE0;
					8'h63 : PATTERN = 8'hE0;
					8'h64 : PATTERN = 8'hE1;
					8'h65 : PATTERN = 8'hE1;
					8'h66 : PATTERN = 8'hE1;
					8'h67 : PATTERN = 8'hE0;
					8'h68 : PATTERN = 8'hE0;
					8'h69 : PATTERN = 8'hE1;
					8'h6a : PATTERN = 8'hE1;
					8'h6b : PATTERN = 8'hE0;
					8'h6c : PATTERN = 8'hE0;
					8'h6d : PATTERN = 8'hE0;
					8'h6e : PATTERN = 8'hE0;
					8'h6f : PATTERN = 8'hE0;
					8'h70 : PATTERN = 8'hE0;
					8'h71 : PATTERN = 8'hE0;
					8'h72 : PATTERN = 8'hE0;
					8'h73 : PATTERN = 8'hE0;
					8'h74 : PATTERN = 8'hE0;
					8'h75 : PATTERN = 8'hE0;
					8'h76 : PATTERN = 8'hE0;
					8'h77 : PATTERN = 8'hF0;
					8'h78 : PATTERN = 8'hF0;
					8'h79 : PATTERN = 8'h78;
					8'h7a : PATTERN = 8'h3C;
					8'h7b : PATTERN = 8'h3E;
					8'h7c : PATTERN = 8'h1F;
					8'h7d : PATTERN = 8'h0F;
					8'h7e : PATTERN = 8'h07;
					8'h7f : PATTERN = 8'h01;
					endcase
					end
					endcase

				end
				
				choose_level:begin
					case(X_PAGE)
						3'o0: begin //0
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'hFE;
						8'h2 : PATTERN = 8'h02;
						8'h3 : PATTERN = 8'h02;
						8'h4 : PATTERN = 8'h02;
						8'h5 : PATTERN = 8'h02;
						8'h6 : PATTERN = 8'h02;
						8'h7 : PATTERN = 8'hE2;
						8'h8 : PATTERN = 8'hE2;
						8'h9 : PATTERN = 8'hE2;
						8'ha : PATTERN = 8'hE2;
						8'hb : PATTERN = 8'hE2;
						8'hc : PATTERN = 8'h02;
						8'hd : PATTERN = 8'hF2;
						8'he : PATTERN = 8'hF2;
						8'hf : PATTERN = 8'h02;
						8'h10 : PATTERN = 8'h02;
						8'h11 : PATTERN = 8'h02;
						8'h12 : PATTERN = 8'h02;
						8'h13 : PATTERN = 8'h02;
						8'h14 : PATTERN = 8'h02;
						8'h15 : PATTERN = 8'h02;
						8'h16 : PATTERN = 8'h02;
						8'h17 : PATTERN = 8'h02;
						8'h18 : PATTERN = 8'h02;
						8'h19 : PATTERN = 8'h02;
						8'h1a : PATTERN = 8'h02;
						8'h1b : PATTERN = 8'h02;
						8'h1c : PATTERN = 8'h02;
						8'h1d : PATTERN = 8'h02;
						8'h1e : PATTERN = 8'h02;
						8'h1f : PATTERN = 8'h02;
						8'h20 : PATTERN = 8'h02;
						8'h21 : PATTERN = 8'h02;
						8'h22 : PATTERN = 8'h02;
						8'h23 : PATTERN = 8'h02;
						8'h24 : PATTERN = 8'h02;
						8'h25 : PATTERN = 8'h02;
						8'h26 : PATTERN = 8'h02;
						8'h27 : PATTERN = 8'h02;
						8'h28 : PATTERN = 8'h02;
						8'h29 : PATTERN = 8'h02;
						8'h2a : PATTERN = 8'h02;
						8'h2b : PATTERN = 8'h02;
						8'h2c : PATTERN = 8'h02;
						8'h2d : PATTERN = 8'h02;
						8'h2e : PATTERN = 8'h02;
						8'h2f : PATTERN = 8'h02;
						8'h30 : PATTERN = 8'h02;
						8'h31 : PATTERN = 8'h02;
						8'h32 : PATTERN = 8'h02;
						8'h33 : PATTERN = 8'h02;
						8'h34 : PATTERN = 8'h02;
						8'h35 : PATTERN = 8'h02;
						8'h36 : PATTERN = 8'h02;
						8'h37 : PATTERN = 8'h02;
						8'h38 : PATTERN = 8'h02;
						8'h39 : PATTERN = 8'h02;
						8'h3a : PATTERN = 8'h02;
						8'h3b : PATTERN = 8'hF2;
						8'h3c : PATTERN = 8'hF2;
						8'h3d : PATTERN = 8'h02;
						8'h3e : PATTERN = 8'h02;
						8'h3f : PATTERN = 8'h02;
						8'h40 : PATTERN = 8'h02;
						8'h41 : PATTERN = 8'h02;
						8'h42 : PATTERN = 8'h02;
						8'h43 : PATTERN = 8'h02;
						8'h44 : PATTERN = 8'h02;
						8'h45 : PATTERN = 8'h02;
						8'h46 : PATTERN = 8'h02;
						8'h47 : PATTERN = 8'h02;
						8'h48 : PATTERN = 8'h02;
						8'h49 : PATTERN = 8'h02;
						8'h4a : PATTERN = 8'h02;
						8'h4b : PATTERN = 8'h02;
						8'h4c : PATTERN = 8'h02;
						8'h4d : PATTERN = 8'h02;
						8'h4e : PATTERN = 8'h02;
						8'h4f : PATTERN = 8'h02;
						8'h50 : PATTERN = 8'h02;
						8'h51 : PATTERN = 8'h02;
						8'h52 : PATTERN = 8'hF2;
						8'h53 : PATTERN = 8'hF2;
						8'h54 : PATTERN = 8'h02;
						8'h55 : PATTERN = 8'h02;
						8'h56 : PATTERN = 8'h02;
						8'h57 : PATTERN = 8'h02;
						8'h58 : PATTERN = 8'h02;
						8'h59 : PATTERN = 8'h02;
						8'h5a : PATTERN = 8'h02;
						8'h5b : PATTERN = 8'h02;
						8'h5c : PATTERN = 8'h02;
						8'h5d : PATTERN = 8'h02;
						8'h5e : PATTERN = 8'h02;
						8'h5f : PATTERN = 8'h02;
						8'h60 : PATTERN = 8'h02;
						8'h61 : PATTERN = 8'h02;
						8'h62 : PATTERN = 8'h02;
						8'h63 : PATTERN = 8'h02;
						8'h64 : PATTERN = 8'h02;
						8'h65 : PATTERN = 8'h02;
						8'h66 : PATTERN = 8'h02;
						8'h67 : PATTERN = 8'h02;
						8'h68 : PATTERN = 8'h02;
						8'h69 : PATTERN = 8'h02;
						8'h6a : PATTERN = 8'h02;
						8'h6b : PATTERN = 8'h02;
						8'h6c : PATTERN = 8'h02;
						8'h6d : PATTERN = 8'h02;
						8'h6e : PATTERN = 8'h02;
						8'h6f : PATTERN = 8'h02;
						8'h70 : PATTERN = 8'h02;
						8'h71 : PATTERN = 8'h02;
						8'h72 : PATTERN = 8'h02;
						8'h73 : PATTERN = 8'h02;
						8'h74 : PATTERN = 8'h02;
						8'h75 : PATTERN = 8'h02;
						8'h76 : PATTERN = 8'h02;
						8'h77 : PATTERN = 8'h02;
						8'h78 : PATTERN = 8'h02;
						8'h79 : PATTERN = 8'h02;
						8'h7a : PATTERN = 8'h02;
						8'h7b : PATTERN = 8'h02;
						8'h7c : PATTERN = 8'h02;
						8'h7d : PATTERN = 8'h02;
						8'h7e : PATTERN = 8'hFE;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o1: begin //1
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'hFF;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'h00;
						8'h7 : PATTERN = 8'h7F;
						8'h8 : PATTERN = 8'h7F;
						8'h9 : PATTERN = 8'h70;
						8'ha : PATTERN = 8'h70;
						8'hb : PATTERN = 8'h70;
						8'hc : PATTERN = 8'h00;
						8'hd : PATTERN = 8'h7F;
						8'he : PATTERN = 8'h7F;
						8'hf : PATTERN = 8'h03;
						8'h10 : PATTERN = 8'h7F;
						8'h11 : PATTERN = 8'h7F;
						8'h12 : PATTERN = 8'h00;
						8'h13 : PATTERN = 8'h7F;
						8'h14 : PATTERN = 8'h73;
						8'h15 : PATTERN = 8'h73;
						8'h16 : PATTERN = 8'h7F;
						8'h17 : PATTERN = 8'h7F;
						8'h18 : PATTERN = 8'h7F;
						8'h19 : PATTERN = 8'h00;
						8'h1a : PATTERN = 8'h7F;
						8'h1b : PATTERN = 8'h73;
						8'h1c : PATTERN = 8'h73;
						8'h1d : PATTERN = 8'h7F;
						8'h1e : PATTERN = 8'h7F;
						8'h1f : PATTERN = 8'h7F;
						8'h20 : PATTERN = 8'h00;
						8'h21 : PATTERN = 8'h77;
						8'h22 : PATTERN = 8'h77;
						8'h23 : PATTERN = 8'h77;
						8'h24 : PATTERN = 8'h7D;
						8'h25 : PATTERN = 8'h7D;
						8'h26 : PATTERN = 8'h00;
						8'h27 : PATTERN = 8'h7F;
						8'h28 : PATTERN = 8'h7F;
						8'h29 : PATTERN = 8'h75;
						8'h2a : PATTERN = 8'h75;
						8'h2b : PATTERN = 8'h77;
						8'h2c : PATTERN = 8'h00;
						8'h2d : PATTERN = 8'h00;
						8'h2e : PATTERN = 8'h00;
						8'h2f : PATTERN = 8'h00;
						8'h30 : PATTERN = 8'h7E;
						8'h31 : PATTERN = 8'h73;
						8'h32 : PATTERN = 8'h71;
						8'h33 : PATTERN = 8'h1F;
						8'h34 : PATTERN = 8'h1F;
						8'h35 : PATTERN = 8'h7F;
						8'h36 : PATTERN = 8'h60;
						8'h37 : PATTERN = 8'h00;
						8'h38 : PATTERN = 8'h00;
						8'h39 : PATTERN = 8'h00;
						8'h3a : PATTERN = 8'h00;
						8'h3b : PATTERN = 8'h7F;
						8'h3c : PATTERN = 8'h7F;
						8'h3d : PATTERN = 8'h00;
						8'h3e : PATTERN = 8'h7F;
						8'h3f : PATTERN = 8'h7F;
						8'h40 : PATTERN = 8'h75;
						8'h41 : PATTERN = 8'h75;
						8'h42 : PATTERN = 8'h77;
						8'h43 : PATTERN = 8'h00;
						8'h44 : PATTERN = 8'h07;
						8'h45 : PATTERN = 8'h1F;
						8'h46 : PATTERN = 8'h78;
						8'h47 : PATTERN = 8'h78;
						8'h48 : PATTERN = 8'h1F;
						8'h49 : PATTERN = 8'h07;
						8'h4a : PATTERN = 8'h00;
						8'h4b : PATTERN = 8'h7F;
						8'h4c : PATTERN = 8'h7F;
						8'h4d : PATTERN = 8'h7F;
						8'h4e : PATTERN = 8'h75;
						8'h4f : PATTERN = 8'h75;
						8'h50 : PATTERN = 8'h77;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h7F;
						8'h53 : PATTERN = 8'h7F;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : PATTERN = 8'h33;
						8'h59 : PATTERN = 8'h33;
						8'h5a : PATTERN = 8'h00;
						8'h5b : PATTERN = 8'h00;
						8'h5c : PATTERN = 8'h00;
						8'h5d : PATTERN = 8'h00;
						8'h5e : PATTERN = 8'h00;
						8'h5f : PATTERN = 8'h00;
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'h00;
						8'h63 : PATTERN = 8'h00;
						8'h64 : PATTERN = 8'h00;
						8'h65 : PATTERN = 8'h00;
						8'h66 : PATTERN = 8'h00;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'h00;
						8'h6a : PATTERN = 8'h00;
						8'h6b : PATTERN = 8'h00;
						8'h6c : PATTERN = 8'h00;
						8'h6d : PATTERN = 8'h00;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h00;
						8'h70 : PATTERN = 8'h00;
						8'h71 : PATTERN = 8'h00;
						8'h72 : PATTERN = 8'h00;
						8'h73 : PATTERN = 8'h00;
						8'h74 : PATTERN = 8'h00;
						8'h75 : PATTERN = 8'h00;
						8'h76 : PATTERN = 8'h00;
						8'h77 : PATTERN = 8'h00;
						8'h78 : PATTERN = 8'h00;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'hFF;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o2: begin //2
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'hFF;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'h00;
						8'h7 : PATTERN = 8'h00;
						8'h8 : PATTERN = 8'h00;
						8'h9 : PATTERN = 8'h00;
						8'ha : PATTERN = 8'h00;
						8'hb : PATTERN = 8'h00;
						8'hc : PATTERN = 8'h00;
						8'hd : PATTERN = 8'h00;
						8'he : PATTERN = 8'h00;
						8'hf : PATTERN = 8'h00;
						8'h10 : PATTERN = 8'h00;
						8'h11 : PATTERN = 8'h00;
						8'h12 : PATTERN = 8'h00;
						8'h13 : PATTERN = 8'h00;
						8'h14 : PATTERN = 8'h00;
						8'h15 : PATTERN = 8'h00;
						8'h16 : PATTERN = 8'h00;
						8'h17 : PATTERN = 8'h00;
						8'h18 : PATTERN = 8'h00;
						8'h19 : PATTERN = 8'h00;
						8'h1a : PATTERN = 8'h00;
						8'h1b : PATTERN = 8'h00;
						8'h1c : PATTERN = 8'h00;
						8'h1d : PATTERN = 8'h00;
						8'h1e : PATTERN = 8'h00;
						8'h1f : PATTERN = 8'h00;
						8'h20 : PATTERN = 8'h00;
						8'h21 : PATTERN = 8'h00;
						8'h22 : PATTERN = 8'h00;
						8'h23 : PATTERN = 8'h00;
						8'h24 : PATTERN = 8'h00;
						8'h25 : PATTERN = 8'h00;
						8'h26 : PATTERN = 8'h00;
						8'h27 : PATTERN = 8'h00;
						8'h28 : PATTERN = 8'h00;
						8'h29 : PATTERN = 8'h00;
						8'h2a : PATTERN = 8'h00;
						8'h2b : PATTERN = 8'h00;
						8'h2c : PATTERN = 8'h00;
						8'h2d : PATTERN = 8'h00;
						8'h2e : PATTERN = 8'h00;
						8'h2f : PATTERN = 8'h00;
						8'h30 : PATTERN = 8'h00;
						8'h31 : PATTERN = 8'h00;
						8'h32 : PATTERN = 8'h00;
						8'h33 : PATTERN = 8'h00;
						8'h34 : PATTERN = 8'h00;
						8'h35 : PATTERN = 8'h00;
						8'h36 : PATTERN = 8'h00;
						8'h37 : PATTERN = 8'h00;
						8'h38 : PATTERN = 8'h00;
						8'h39 : PATTERN = 8'h00;
						8'h3a : PATTERN = 8'h00;
						8'h3b : PATTERN = 8'h00;
						8'h3c : PATTERN = 8'h00;
						8'h3d : PATTERN = 8'h00;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h00;
						8'h40 : PATTERN = 8'h00;
						8'h41 : PATTERN = 8'h00;
						8'h42 : PATTERN = 8'h00;
						8'h43 : PATTERN = 8'h00;
						8'h44 : PATTERN = 8'h00;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h00;
						8'h47 : PATTERN = 8'h00;
						8'h48 : PATTERN = 8'h00;
						8'h49 : PATTERN = 8'h00;
						8'h4a : PATTERN = 8'h00;
						8'h4b : PATTERN = 8'h00;
						8'h4c : PATTERN = 8'h00;
						8'h4d : PATTERN = 8'h00;
						8'h4e : PATTERN = 8'h00;
						8'h4f : PATTERN = 8'h00;
						8'h50 : PATTERN = 8'h00;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h00;
						8'h53 : PATTERN = 8'h00;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : PATTERN = 8'h00;
						8'h59 : PATTERN = 8'h00;
						8'h5a : PATTERN = 8'h00;
						8'h5b : PATTERN = 8'h00;
						8'h5c : PATTERN = 8'h00;
						8'h5d : PATTERN = 8'h00;
						8'h5e : PATTERN = 8'h00;
						8'h5f : PATTERN = 8'h00;
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'h00;
						8'h63 : PATTERN = 8'h00;
						8'h64 : PATTERN = 8'h00;
						8'h65 : PATTERN = 8'h00;
						8'h66 : PATTERN = 8'h00;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'h00;
						8'h6a : PATTERN = 8'h00;
						8'h6b : PATTERN = 8'h00;
						8'h6c : PATTERN = 8'h00;
						8'h6d : PATTERN = 8'h00;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h00;
						8'h70 : PATTERN = 8'h00;
						8'h71 : PATTERN = 8'h00;
						8'h72 : PATTERN = 8'h00;
						8'h73 : PATTERN = 8'h00;
						8'h74 : PATTERN = 8'h00;
						8'h75 : PATTERN = 8'h00;
						8'h76 : PATTERN = 8'h00;
						8'h77 : PATTERN = 8'h00;
						8'h78 : PATTERN = 8'h00;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'hFF;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o3: begin //3
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'hFF;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : begin if(level==3'd1) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'h7 : begin if(level==3'd1) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'h8 : begin if(level==3'd1) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'h9 : begin if(level==3'd1) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'ha : begin if(level==3'd1) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'hb : begin if(level==3'd1) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'hc : begin if(level==3'd1) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'hd : begin if(level==3'd1) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'he : PATTERN = 8'h00;
						8'hf : PATTERN = 8'h00;
						8'h10 : PATTERN = 8'hFF;
						8'h11 : PATTERN = 8'hFF;
						8'h12 : PATTERN = 8'h80;
						8'h13 : PATTERN = 8'h80;
						8'h14 : PATTERN = 8'h80;
						8'h15 : PATTERN = 8'h00;
						8'h16 : PATTERN = 8'h38;
						8'h17 : PATTERN = 8'hF8;
						8'h18 : PATTERN = 8'hC0;
						8'h19 : PATTERN = 8'hC0;
						8'h1a : PATTERN = 8'hF8;
						8'h1b : PATTERN = 8'h38;
						8'h1c : PATTERN = 8'h00;
						8'h1d : PATTERN = 8'h80;
						8'h1e : PATTERN = 8'h80;
						8'h1f : PATTERN = 8'h00;
						8'h20 : PATTERN = 8'h00;
						8'h21 : PATTERN = 8'h81;
						8'h22 : PATTERN = 8'h81;
						8'h23 : PATTERN = 8'hFF;
						8'h24 : PATTERN = 8'hFF;
						8'h25 : PATTERN = 8'h80;
						8'h26 : PATTERN = 8'h80;
						8'h27 : PATTERN = 8'h00;
						8'h28 : PATTERN = 8'h00;
						8'h29 : PATTERN = 8'h00;
						8'h2a : PATTERN = 8'h00;
						8'h2b : PATTERN = 8'h00;
						8'h2c : PATTERN = 8'h00;
						8'h2d : PATTERN = 8'h00;
						8'h2e : PATTERN = 8'h00;
						8'h2f : begin if(level==3'd3) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'h30 : begin if(level==3'd3) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'h31 : begin if(level==3'd3) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'h32 : begin if(level==3'd3) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'h33 : begin if(level==3'd3) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'h34 : begin if(level==3'd3) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'h35 : begin if(level==3'd3) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'h36 : begin if(level==3'd3) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'h37 : PATTERN = 8'h00;
						8'h38 : PATTERN = 8'h00;
						8'h39 : PATTERN = 8'hFF;
						8'h3a : PATTERN = 8'hFF;
						8'h3b : PATTERN = 8'h80;
						8'h3c : PATTERN = 8'h80;
						8'h3d : PATTERN = 8'h80;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h38;
						8'h40 : PATTERN = 8'hF8;
						8'h41 : PATTERN = 8'hC0;
						8'h42 : PATTERN = 8'hC0;
						8'h43 : PATTERN = 8'hF8;
						8'h44 : PATTERN = 8'h38;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h80;
						8'h47 : PATTERN = 8'h80;
						8'h48 : PATTERN = 8'h00;
						8'h49 : PATTERN = 8'h00;
						8'h4a : PATTERN = 8'h99;
						8'h4b : PATTERN = 8'h99;
						8'h4c : PATTERN = 8'h99;
						8'h4d : PATTERN = 8'h99;
						8'h4e : PATTERN = 8'hFF;
						8'h4f : PATTERN = 8'hFF;
						8'h50 : PATTERN = 8'h00;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h00;
						8'h53 : PATTERN = 8'h00;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : begin if(level==3'd5) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'h59 : begin if(level==3'd5) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'h5a : begin if(level==3'd5) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'h5b : begin if(level==3'd5) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'h5c : begin if(level==3'd5) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'h5d : begin if(level==3'd5) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'h5e : begin if(level==3'd5) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'h5f : begin if(level==3'd5) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'hFF;
						8'h63 : PATTERN = 8'hFF;
						8'h64 : PATTERN = 8'h80;
						8'h65 : PATTERN = 8'h80;
						8'h66 : PATTERN = 8'h80;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h38;
						8'h69 : PATTERN = 8'hF8;
						8'h6a : PATTERN = 8'hC0;
						8'h6b : PATTERN = 8'hC0;
						8'h6c : PATTERN = 8'hF8;
						8'h6d : PATTERN = 8'h38;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h80;
						8'h70 : PATTERN = 8'h80;
						8'h71 : PATTERN = 8'h00;
						8'h72 : PATTERN = 8'h00;
						8'h73 : PATTERN = 8'h8F;
						8'h74 : PATTERN = 8'h8F;
						8'h75 : PATTERN = 8'h89;
						8'h76 : PATTERN = 8'h89;
						8'h77 : PATTERN = 8'hF9;
						8'h78 : PATTERN = 8'hF9;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'hFF;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o4: begin //4
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'hFF;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'h00;
						8'h7 : PATTERN = 8'h00;
						8'h8 : PATTERN = 8'h00;
						8'h9 : PATTERN = 8'h00;
						8'ha : PATTERN = 8'h00;
						8'hb : PATTERN = 8'h00;
						8'hc : PATTERN = 8'h00;
						8'hd : PATTERN = 8'h00;
						8'he : PATTERN = 8'h00;
						8'hf : PATTERN = 8'h00;
						8'h10 : PATTERN = 8'h01;
						8'h11 : PATTERN = 8'h01;
						8'h12 : PATTERN = 8'h01;
						8'h13 : PATTERN = 8'h01;
						8'h14 : PATTERN = 8'h01;
						8'h15 : PATTERN = 8'h00;
						8'h16 : PATTERN = 8'h00;
						8'h17 : PATTERN = 8'h00;
						8'h18 : PATTERN = 8'h01;
						8'h19 : PATTERN = 8'h01;
						8'h1a : PATTERN = 8'h00;
						8'h1b : PATTERN = 8'h00;
						8'h1c : PATTERN = 8'h00;
						8'h1d : PATTERN = 8'h01;
						8'h1e : PATTERN = 8'h01;
						8'h1f : PATTERN = 8'h00;
						8'h20 : PATTERN = 8'h00;
						8'h21 : PATTERN = 8'h01;
						8'h22 : PATTERN = 8'h01;
						8'h23 : PATTERN = 8'h01;
						8'h24 : PATTERN = 8'h01;
						8'h25 : PATTERN = 8'h01;
						8'h26 : PATTERN = 8'h01;
						8'h27 : PATTERN = 8'h00;
						8'h28 : PATTERN = 8'h00;
						8'h29 : PATTERN = 8'h00;
						8'h2a : PATTERN = 8'h00;
						8'h2b : PATTERN = 8'h00;
						8'h2c : PATTERN = 8'h00;
						8'h2d : PATTERN = 8'h00;
						8'h2e : PATTERN = 8'h00;
						8'h2f : PATTERN = 8'h00;
						8'h30 : PATTERN = 8'h00;
						8'h31 : PATTERN = 8'h00;
						8'h32 : PATTERN = 8'h00;
						8'h33 : PATTERN = 8'h00;
						8'h34 : PATTERN = 8'h00;
						8'h35 : PATTERN = 8'h00;
						8'h36 : PATTERN = 8'h00;
						8'h37 : PATTERN = 8'h00;
						8'h38 : PATTERN = 8'h00;
						8'h39 : PATTERN = 8'h01;
						8'h3a : PATTERN = 8'h01;
						8'h3b : PATTERN = 8'h01;
						8'h3c : PATTERN = 8'h01;
						8'h3d : PATTERN = 8'h01;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h00;
						8'h40 : PATTERN = 8'h00;
						8'h41 : PATTERN = 8'h01;
						8'h42 : PATTERN = 8'h01;
						8'h43 : PATTERN = 8'h00;
						8'h44 : PATTERN = 8'h00;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h01;
						8'h47 : PATTERN = 8'h01;
						8'h48 : PATTERN = 8'h00;
						8'h49 : PATTERN = 8'h00;
						8'h4a : PATTERN = 8'h01;
						8'h4b : PATTERN = 8'h01;
						8'h4c : PATTERN = 8'h01;
						8'h4d : PATTERN = 8'h01;
						8'h4e : PATTERN = 8'h01;
						8'h4f : PATTERN = 8'h01;
						8'h50 : PATTERN = 8'h00;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h00;
						8'h53 : PATTERN = 8'h00;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : PATTERN = 8'h00;
						8'h59 : PATTERN = 8'h00;
						8'h5a : PATTERN = 8'h00;
						8'h5b : PATTERN = 8'h00;
						8'h5c : PATTERN = 8'h00;
						8'h5d : PATTERN = 8'h00;
						8'h5e : PATTERN = 8'h00;
						8'h5f : PATTERN = 8'h00;
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'h01;
						8'h63 : PATTERN = 8'h01;
						8'h64 : PATTERN = 8'h01;
						8'h65 : PATTERN = 8'h01;
						8'h66 : PATTERN = 8'h01;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'h00;
						8'h6a : PATTERN = 8'h01;
						8'h6b : PATTERN = 8'h01;
						8'h6c : PATTERN = 8'h00;
						8'h6d : PATTERN = 8'h00;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h01;
						8'h70 : PATTERN = 8'h01;
						8'h71 : PATTERN = 8'h00;
						8'h72 : PATTERN = 8'h00;
						8'h73 : PATTERN = 8'h01;
						8'h74 : PATTERN = 8'h01;
						8'h75 : PATTERN = 8'h01;
						8'h76 : PATTERN = 8'h01;
						8'h77 : PATTERN = 8'h01;
						8'h78 : PATTERN = 8'h01;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'hFF;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o5: begin //5
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'hFF;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : begin if(level==3'd2) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'h7 : begin if(level==3'd2) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'h8 : begin if(level==3'd2) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'h9 : begin if(level==3'd2) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'ha : begin if(level==3'd2) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'hb : begin if(level==3'd2) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'hc : begin if(level==3'd2) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'hd : begin if(level==3'd2) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'he : PATTERN = 8'h00;
						8'hf : PATTERN = 8'h00;
						8'h10 : PATTERN = 8'hFF;
						8'h11 : PATTERN = 8'hFF;
						8'h12 : PATTERN = 8'h80;
						8'h13 : PATTERN = 8'h80;
						8'h14 : PATTERN = 8'h80;
						8'h15 : PATTERN = 8'h00;
						8'h16 : PATTERN = 8'h38;
						8'h17 : PATTERN = 8'hF8;
						8'h18 : PATTERN = 8'hC0;
						8'h19 : PATTERN = 8'hC0;
						8'h1a : PATTERN = 8'hF8;
						8'h1b : PATTERN = 8'h38;
						8'h1c : PATTERN = 8'h00;
						8'h1d : PATTERN = 8'h80;
						8'h1e : PATTERN = 8'h80;
						8'h1f : PATTERN = 8'h00;
						8'h20 : PATTERN = 8'h00;
						8'h21 : PATTERN = 8'hF1;
						8'h22 : PATTERN = 8'hF1;
						8'h23 : PATTERN = 8'h91;
						8'h24 : PATTERN = 8'h91;
						8'h25 : PATTERN = 8'h9F;
						8'h26 : PATTERN = 8'h9F;
						8'h27 : PATTERN = 8'h00;
						8'h28 : PATTERN = 8'h00;
						8'h29 : PATTERN = 8'h00;
						8'h2a : PATTERN = 8'h00;
						8'h2b : PATTERN = 8'h00;
						8'h2c : PATTERN = 8'h00;
						8'h2d : PATTERN = 8'h00;
						8'h2e : PATTERN = 8'h00;
						8'h2f : begin if(level==3'd4) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'h30 : begin if(level==3'd4) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'h31 : begin if(level==3'd4) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'h32 : begin if(level==3'd4) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'h33 : begin if(level==3'd4) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'h34 : begin if(level==3'd4) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'h35 : begin if(level==3'd4) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'h36 : begin if(level==3'd4) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'h37 : PATTERN = 8'h00;
						8'h38 : PATTERN = 8'h00;
						8'h39 : PATTERN = 8'hFF;
						8'h3a : PATTERN = 8'hFF;
						8'h3b : PATTERN = 8'h80;
						8'h3c : PATTERN = 8'h80;
						8'h3d : PATTERN = 8'h80;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h38;
						8'h40 : PATTERN = 8'hF8;
						8'h41 : PATTERN = 8'hC0;
						8'h42 : PATTERN = 8'hC0;
						8'h43 : PATTERN = 8'hF8;
						8'h44 : PATTERN = 8'h38;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h80;
						8'h47 : PATTERN = 8'h80;
						8'h48 : PATTERN = 8'h00;
						8'h49 : PATTERN = 8'h00;
						8'h4a : PATTERN = 8'h7F;
						8'h4b : PATTERN = 8'h7F;
						8'h4c : PATTERN = 8'h60;
						8'h4d : PATTERN = 8'hFF;
						8'h4e : PATTERN = 8'hFF;
						8'h4f : PATTERN = 8'h60;
						8'h50 : PATTERN = 8'h00;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h00;
						8'h53 : PATTERN = 8'h00;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : begin if(level==3'd6) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'h59 : begin if(level==3'd6) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'h5a : begin if(level==3'd6) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'h5b : begin if(level==3'd6) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'h5c : begin if(level==3'd6) PATTERN = 8'hF8; else PATTERN = 8'h00; end
						8'h5d : begin if(level==3'd6) PATTERN = 8'hDF; else PATTERN = 8'h00; end
						8'h5e : begin if(level==3'd6) PATTERN = 8'hFF; else PATTERN = 8'h00; end
						8'h5f : begin if(level==3'd6) PATTERN = 8'h70; else PATTERN = 8'h00; end
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'hFF;
						8'h63 : PATTERN = 8'hFF;
						8'h64 : PATTERN = 8'h80;
						8'h65 : PATTERN = 8'h80;
						8'h66 : PATTERN = 8'h80;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h38;
						8'h69 : PATTERN = 8'hF8;
						8'h6a : PATTERN = 8'hC0;
						8'h6b : PATTERN = 8'hC0;
						8'h6c : PATTERN = 8'hF8;
						8'h6d : PATTERN = 8'h38;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h80;
						8'h70 : PATTERN = 8'h80;
						8'h71 : PATTERN = 8'h00;
						8'h72 : PATTERN = 8'h00;
						8'h73 : PATTERN = 8'hFF;
						8'h74 : PATTERN = 8'hFF;
						8'h75 : PATTERN = 8'h89;
						8'h76 : PATTERN = 8'h89;
						8'h77 : PATTERN = 8'hF9;
						8'h78 : PATTERN = 8'hF9;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'hFF;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o6: begin //6
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'hFF;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'h00;
						8'h7 : PATTERN = 8'h00;
						8'h8 : PATTERN = 8'h00;
						8'h9 : PATTERN = 8'h00;
						8'ha : PATTERN = 8'h00;
						8'hb : PATTERN = 8'h00;
						8'hc : PATTERN = 8'h00;
						8'hd : PATTERN = 8'h00;
						8'he : PATTERN = 8'h00;
						8'hf : PATTERN = 8'h00;
						8'h10 : PATTERN = 8'h01;
						8'h11 : PATTERN = 8'h01;
						8'h12 : PATTERN = 8'h01;
						8'h13 : PATTERN = 8'h01;
						8'h14 : PATTERN = 8'h01;
						8'h15 : PATTERN = 8'h00;
						8'h16 : PATTERN = 8'h00;
						8'h17 : PATTERN = 8'h00;
						8'h18 : PATTERN = 8'h01;
						8'h19 : PATTERN = 8'h01;
						8'h1a : PATTERN = 8'h00;
						8'h1b : PATTERN = 8'h00;
						8'h1c : PATTERN = 8'h00;
						8'h1d : PATTERN = 8'h01;
						8'h1e : PATTERN = 8'h01;
						8'h1f : PATTERN = 8'h00;
						8'h20 : PATTERN = 8'h00;
						8'h21 : PATTERN = 8'h01;
						8'h22 : PATTERN = 8'h01;
						8'h23 : PATTERN = 8'h01;
						8'h24 : PATTERN = 8'h01;
						8'h25 : PATTERN = 8'h01;
						8'h26 : PATTERN = 8'h01;
						8'h27 : PATTERN = 8'h00;
						8'h28 : PATTERN = 8'h00;
						8'h29 : PATTERN = 8'h00;
						8'h2a : PATTERN = 8'h00;
						8'h2b : PATTERN = 8'h00;
						8'h2c : PATTERN = 8'h00;
						8'h2d : PATTERN = 8'h00;
						8'h2e : PATTERN = 8'h00;
						8'h2f : PATTERN = 8'h00;
						8'h30 : PATTERN = 8'h00;
						8'h31 : PATTERN = 8'h00;
						8'h32 : PATTERN = 8'h00;
						8'h33 : PATTERN = 8'h00;
						8'h34 : PATTERN = 8'h00;
						8'h35 : PATTERN = 8'h00;
						8'h36 : PATTERN = 8'h00;
						8'h37 : PATTERN = 8'h00;
						8'h38 : PATTERN = 8'h00;
						8'h39 : PATTERN = 8'h01;
						8'h3a : PATTERN = 8'h01;
						8'h3b : PATTERN = 8'h01;
						8'h3c : PATTERN = 8'h01;
						8'h3d : PATTERN = 8'h01;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h00;
						8'h40 : PATTERN = 8'h00;
						8'h41 : PATTERN = 8'h01;
						8'h42 : PATTERN = 8'h01;
						8'h43 : PATTERN = 8'h00;
						8'h44 : PATTERN = 8'h00;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h01;
						8'h47 : PATTERN = 8'h01;
						8'h48 : PATTERN = 8'h00;
						8'h49 : PATTERN = 8'h00;
						8'h4a : PATTERN = 8'h00;
						8'h4b : PATTERN = 8'h00;
						8'h4c : PATTERN = 8'h00;
						8'h4d : PATTERN = 8'h01;
						8'h4e : PATTERN = 8'h01;
						8'h4f : PATTERN = 8'h00;
						8'h50 : PATTERN = 8'hC0;
						8'h51 : PATTERN = 8'hC0;
						8'h52 : PATTERN = 8'h40;
						8'h53 : PATTERN = 8'h40;
						8'h54 : PATTERN = 8'h40;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h40;
						8'h57 : PATTERN = 8'h40;
						8'h58 : PATTERN = 8'h40;
						8'h59 : PATTERN = 8'hC0;
						8'h5a : PATTERN = 8'h00;
						8'h5b : PATTERN = 8'h00;
						8'h5c : PATTERN = 8'h80;
						8'h5d : PATTERN = 8'hC0;
						8'h5e : PATTERN = 8'h80;
						8'h5f : PATTERN = 8'h00;
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'h01;
						8'h63 : PATTERN = 8'h01;
						8'h64 : PATTERN = 8'h01;
						8'h65 : PATTERN = 8'h01;
						8'h66 : PATTERN = 8'h01;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'hC0;
						8'h69 : PATTERN = 8'hC0;
						8'h6a : PATTERN = 8'h41;
						8'h6b : PATTERN = 8'h41;
						8'h6c : PATTERN = 8'h40;
						8'h6d : PATTERN = 8'h00;
						8'h6e : PATTERN = 8'h40;
						8'h6f : PATTERN = 8'h41;
						8'h70 : PATTERN = 8'hC1;
						8'h71 : PATTERN = 8'hC0;
						8'h72 : PATTERN = 8'h00;
						8'h73 : PATTERN = 8'h01;
						8'h74 : PATTERN = 8'h01;
						8'h75 : PATTERN = 8'hC1;
						8'h76 : PATTERN = 8'h01;
						8'h77 : PATTERN = 8'h01;
						8'h78 : PATTERN = 8'h01;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'hFF;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o7: begin //7
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'h7F;
						8'h2 : PATTERN = 8'h40;
						8'h3 : PATTERN = 8'h40;
						8'h4 : PATTERN = 8'h40;
						8'h5 : PATTERN = 8'h40;
						8'h6 : PATTERN = 8'h40;
						8'h7 : PATTERN = 8'h40;
						8'h8 : PATTERN = 8'h40;
						8'h9 : PATTERN = 8'h40;
						8'ha : PATTERN = 8'h40;
						8'hb : PATTERN = 8'h40;
						8'hc : PATTERN = 8'h40;
						8'hd : PATTERN = 8'h40;
						8'he : PATTERN = 8'h40;
						8'hf : PATTERN = 8'h40;
						8'h10 : PATTERN = 8'h40;
						8'h11 : PATTERN = 8'h40;
						8'h12 : PATTERN = 8'h40;
						8'h13 : PATTERN = 8'h40;
						8'h14 : PATTERN = 8'h40;
						8'h15 : PATTERN = 8'h40;
						8'h16 : PATTERN = 8'h40;
						8'h17 : PATTERN = 8'h40;
						8'h18 : PATTERN = 8'h40;
						8'h19 : PATTERN = 8'h40;
						8'h1a : PATTERN = 8'h40;
						8'h1b : PATTERN = 8'h40;
						8'h1c : PATTERN = 8'h40;
						8'h1d : PATTERN = 8'h40;
						8'h1e : PATTERN = 8'h40;
						8'h1f : PATTERN = 8'h40;
						8'h20 : PATTERN = 8'h40;
						8'h21 : PATTERN = 8'h40;
						8'h22 : PATTERN = 8'h40;
						8'h23 : PATTERN = 8'h40;
						8'h24 : PATTERN = 8'h40;
						8'h25 : PATTERN = 8'h40;
						8'h26 : PATTERN = 8'h40;
						8'h27 : PATTERN = 8'h40;
						8'h28 : PATTERN = 8'h40;
						8'h29 : PATTERN = 8'h40;
						8'h2a : PATTERN = 8'h40;
						8'h2b : PATTERN = 8'h40;
						8'h2c : PATTERN = 8'h40;
						8'h2d : PATTERN = 8'h40;
						8'h2e : PATTERN = 8'h40;
						8'h2f : PATTERN = 8'h40;
						8'h30 : PATTERN = 8'h40;
						8'h31 : PATTERN = 8'h40;
						8'h32 : PATTERN = 8'h40;
						8'h33 : PATTERN = 8'h40;
						8'h34 : PATTERN = 8'h40;
						8'h35 : PATTERN = 8'h40;
						8'h36 : PATTERN = 8'h40;
						8'h37 : PATTERN = 8'h40;
						8'h38 : PATTERN = 8'h40;
						8'h39 : PATTERN = 8'h40;
						8'h3a : PATTERN = 8'h40;
						8'h3b : PATTERN = 8'h40;
						8'h3c : PATTERN = 8'h40;
						8'h3d : PATTERN = 8'h40;
						8'h3e : PATTERN = 8'h40;
						8'h3f : PATTERN = 8'h40;
						8'h40 : PATTERN = 8'h40;
						8'h41 : PATTERN = 8'h40;
						8'h42 : PATTERN = 8'h40;
						8'h43 : PATTERN = 8'h40;
						8'h44 : PATTERN = 8'h40;
						8'h45 : PATTERN = 8'h40;
						8'h46 : PATTERN = 8'h40;
						8'h47 : PATTERN = 8'h40;
						8'h48 : PATTERN = 8'h40;
						8'h49 : PATTERN = 8'h40;
						8'h4a : PATTERN = 8'h40;
						8'h4b : PATTERN = 8'h40;
						8'h4c : PATTERN = 8'h40;
						8'h4d : PATTERN = 8'h40;
						8'h4e : PATTERN = 8'h40;
						8'h4f : PATTERN = 8'h40;
						8'h50 : PATTERN = 8'h4D;
						8'h51 : PATTERN = 8'h4D;
						8'h52 : PATTERN = 8'h4D;
						8'h53 : PATTERN = 8'h4F;
						8'h54 : PATTERN = 8'h4F;
						8'h55 : PATTERN = 8'h40;
						8'h56 : PATTERN = 8'h4E;
						8'h57 : PATTERN = 8'h4A;
						8'h58 : PATTERN = 8'h4A;
						8'h59 : PATTERN = 8'h4B;
						8'h5a : PATTERN = 8'h40;
						8'h5b : PATTERN = 8'h41;
						8'h5c : PATTERN = 8'h41;
						8'h5d : PATTERN = 8'h4F;
						8'h5e : PATTERN = 8'h41;
						8'h5f : PATTERN = 8'h41;
						8'h60 : PATTERN = 8'h40;
						8'h61 : PATTERN = 8'h40;
						8'h62 : PATTERN = 8'h40;
						8'h63 : PATTERN = 8'h40;
						8'h64 : PATTERN = 8'h40;
						8'h65 : PATTERN = 8'h40;
						8'h66 : PATTERN = 8'h40;
						8'h67 : PATTERN = 8'h40;
						8'h68 : PATTERN = 8'h4D;
						8'h69 : PATTERN = 8'h4D;
						8'h6a : PATTERN = 8'h4D;
						8'h6b : PATTERN = 8'h4F;
						8'h6c : PATTERN = 8'h4F;
						8'h6d : PATTERN = 8'h40;
						8'h6e : PATTERN = 8'h4B;
						8'h6f : PATTERN = 8'h4B;
						8'h70 : PATTERN = 8'h4F;
						8'h71 : PATTERN = 8'h4F;
						8'h72 : PATTERN = 8'h40;
						8'h73 : PATTERN = 8'h42;
						8'h74 : PATTERN = 8'h46;
						8'h75 : PATTERN = 8'h4F;
						8'h76 : PATTERN = 8'h46;
						8'h77 : PATTERN = 8'h42;
						8'h78 : PATTERN = 8'h40;
						8'h79 : PATTERN = 8'h40;
						8'h7a : PATTERN = 8'h40;
						8'h7b : PATTERN = 8'h40;
						8'h7c : PATTERN = 8'h40;
						8'h7d : PATTERN = 8'h40;
						8'h7e : PATTERN = 8'h7F;
						8'h7f : PATTERN = 8'h00;
						endcase
						end

					endcase
				end	
			
				XAYB: begin
					case(X_PAGE)
					3'o0: begin //0
					case(INDEX)
					8'h0 : PATTERN = 8'h0;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h00;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h00;
					8'h34 : PATTERN = 8'h00;
					8'h35 : PATTERN = 8'h00;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h00;
					8'h49 : PATTERN = 8'h00;
					8'h4a : PATTERN = 8'h00;
					8'h4b : PATTERN = 8'h00;
					8'h4c : PATTERN = 8'h00;
					8'h4d : PATTERN = 8'h00;
					8'h4e : PATTERN = 8'h00;
					8'h4f : PATTERN = 8'h00;
					8'h50 : PATTERN = 8'h00;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h00;
					8'h54 : PATTERN = 8'h00;
					8'h55 : PATTERN = 8'h00;
					8'h56 : PATTERN = 8'h00;
					8'h57 : PATTERN = 8'h00;
					8'h58 : PATTERN = 8'h00;
					8'h59 : PATTERN = 8'h00;
					8'h5a : PATTERN = 8'h80;
					8'h5b : PATTERN = 8'h80;
					8'h5c : PATTERN = 8'h80;
					8'h5d : PATTERN = 8'hC0;
					8'h5e : PATTERN = 8'h40;
					8'h5f : PATTERN = 8'h40;
					8'h60 : PATTERN = 8'h20;
					8'h61 : PATTERN = 8'h60;
					8'h62 : PATTERN = 8'hE0;
					8'h63 : PATTERN = 8'hF0;
					8'h64 : PATTERN = 8'hF0;
					8'h65 : PATTERN = 8'hF0;
					8'h66 : PATTERN = 8'hF8;
					8'h67 : PATTERN = 8'hF8;
					8'h68 : PATTERN = 8'h78;
					8'h69 : PATTERN = 8'h38;
					8'h6a : PATTERN = 8'h00;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o1: begin //1
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'hFC;
					8'h8 : PATTERN = 8'hFC;
					8'h9 : PATTERN = 8'hFC;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h80;
					8'hc : PATTERN = 8'hE0;
					8'hd : PATTERN = 8'h70;
					8'he : PATTERN = 8'h30;
					8'hf : PATTERN = 8'h10;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'hF0;
					8'h15 : PATTERN = 8'hF8;
					8'h16 : PATTERN = 8'hF8;
					8'h17 : PATTERN = 8'h18;
					8'h18 : PATTERN = 8'h18;
					8'h19 : PATTERN = 8'h18;
					8'h1a : PATTERN = 8'h18;
					8'h1b : PATTERN = 8'h18;
					8'h1c : PATTERN = 8'h18;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'hF0;
					8'h21 : PATTERN = 8'hF8;
					8'h22 : PATTERN = 8'hF8;
					8'h23 : PATTERN = 8'h18;
					8'h24 : PATTERN = 8'h18;
					8'h25 : PATTERN = 8'h18;
					8'h26 : PATTERN = 8'h18;
					8'h27 : PATTERN = 8'h18;
					8'h28 : PATTERN = 8'h18;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'hF8;
					8'h2d : PATTERN = 8'hF8;
					8'h2e : PATTERN = 8'hF8;
					8'h2f : PATTERN = 8'h18;
					8'h30 : PATTERN = 8'h08;
					8'h31 : PATTERN = 8'h08;
					8'h32 : PATTERN = 8'h08;
					8'h33 : PATTERN = 8'h08;
					8'h34 : PATTERN = 8'h18;
					8'h35 : PATTERN = 8'hF0;
					8'h36 : PATTERN = 8'hE0;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'hC0;
					8'h46 : PATTERN = 8'hC0;
					8'h47 : PATTERN = 8'h40;
					8'h48 : PATTERN = 8'h30;
					8'h49 : PATTERN = 8'h30;
					8'h4a : PATTERN = 8'h10;
					8'h4b : PATTERN = 8'h18;
					8'h4c : PATTERN = 8'h08;
					8'h4d : PATTERN = 8'h0C;
					8'h4e : PATTERN = 8'h04;
					8'h4f : PATTERN = 8'h04;
					8'h50 : PATTERN = 8'h04;
					8'h51 : PATTERN = 8'h04;
					8'h52 : PATTERN = 8'h04;
					8'h53 : PATTERN = 8'h04;
					8'h54 : PATTERN = 8'h04;
					8'h55 : PATTERN = 8'h04;
					8'h56 : PATTERN = 8'h02;
					8'h57 : PATTERN = 8'h02;
					8'h58 : PATTERN = 8'h01;
					8'h59 : PATTERN = 8'h01;
					8'h5a : PATTERN = 8'h01;
					8'h5b : PATTERN = 8'h00;
					8'h5c : PATTERN = 8'h00;
					8'h5d : PATTERN = 8'hF0;
					8'h5e : PATTERN = 8'hF8;
					8'h5f : PATTERN = 8'hFC;
					8'h60 : PATTERN = 8'hFE;
					8'h61 : PATTERN = 8'h7E;
					8'h62 : PATTERN = 8'h3F;
					8'h63 : PATTERN = 8'h1F;
					8'h64 : PATTERN = 8'h0F;
					8'h65 : PATTERN = 8'h07;
					8'h66 : PATTERN = 8'h03;
					8'h67 : PATTERN = 8'h01;
					8'h68 : PATTERN = 8'h00;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'h00;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o2: begin //2
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h06;
					8'h5 : PATTERN = 8'h07;
					8'h6 : PATTERN = 8'h07;
					8'h7 : PATTERN = 8'h07;
					8'h8 : PATTERN = 8'h3F;
					8'h9 : PATTERN = 8'h3F;
					8'ha : PATTERN = 8'h33;
					8'hb : PATTERN = 8'h07;
					8'hc : PATTERN = 8'h0E;
					8'hd : PATTERN = 8'h1C;
					8'he : PATTERN = 8'h38;
					8'hf : PATTERN = 8'h30;
					8'h10 : PATTERN = 8'h20;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h3F;
					8'h15 : PATTERN = 8'h3F;
					8'h16 : PATTERN = 8'h3F;
					8'h17 : PATTERN = 8'h21;
					8'h18 : PATTERN = 8'h21;
					8'h19 : PATTERN = 8'h21;
					8'h1a : PATTERN = 8'h21;
					8'h1b : PATTERN = 8'h21;
					8'h1c : PATTERN = 8'h21;
					8'h1d : PATTERN = 8'h20;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h3F;
					8'h21 : PATTERN = 8'h3F;
					8'h22 : PATTERN = 8'h3F;
					8'h23 : PATTERN = 8'h21;
					8'h24 : PATTERN = 8'h21;
					8'h25 : PATTERN = 8'h21;
					8'h26 : PATTERN = 8'h21;
					8'h27 : PATTERN = 8'h21;
					8'h28 : PATTERN = 8'h21;
					8'h29 : PATTERN = 8'h20;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h1F;
					8'h2d : PATTERN = 8'h3F;
					8'h2e : PATTERN = 8'h3F;
					8'h2f : PATTERN = 8'h06;
					8'h30 : PATTERN = 8'h04;
					8'h31 : PATTERN = 8'h04;
					8'h32 : PATTERN = 8'h04;
					8'h33 : PATTERN = 8'h06;
					8'h34 : PATTERN = 8'h07;
					8'h35 : PATTERN = 8'h03;
					8'h36 : PATTERN = 8'h01;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h80;
					8'h39 : PATTERN = 8'h80;
					8'h3a : PATTERN = 8'hC0;
					8'h3b : PATTERN = 8'h40;
					8'h3c : PATTERN = 8'h60;
					8'h3d : PATTERN = 8'h60;
					8'h3e : PATTERN = 8'h30;
					8'h3f : PATTERN = 8'h10;
					8'h40 : PATTERN = 8'h18;
					8'h41 : PATTERN = 8'h08;
					8'h42 : PATTERN = 8'hEC;
					8'h43 : PATTERN = 8'h1E;
					8'h44 : PATTERN = 8'h06;
					8'h45 : PATTERN = 8'h01;
					8'h46 : PATTERN = 8'h01;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h00;
					8'h49 : PATTERN = 8'h00;
					8'h4a : PATTERN = 8'h00;
					8'h4b : PATTERN = 8'h00;
					8'h4c : PATTERN = 8'h00;
					8'h4d : PATTERN = 8'h00;
					8'h4e : PATTERN = 8'h00;
					8'h4f : PATTERN = 8'h00;
					8'h50 : PATTERN = 8'h00;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h00;
					8'h54 : PATTERN = 8'h80;
					8'h55 : PATTERN = 8'h40;
					8'h56 : PATTERN = 8'h40;
					8'h57 : PATTERN = 8'hC0;
					8'h58 : PATTERN = 8'hC0;
					8'h59 : PATTERN = 8'h80;
					8'h5a : PATTERN = 8'h00;
					8'h5b : PATTERN = 8'h00;
					8'h5c : PATTERN = 8'h00;
					8'h5d : PATTERN = 8'h03;
					8'h5e : PATTERN = 8'h07;
					8'h5f : PATTERN = 8'h0D;
					8'h60 : PATTERN = 8'h18;
					8'h61 : PATTERN = 8'h70;
					8'h62 : PATTERN = 8'hE0;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h00;
					8'h65 : PATTERN = 8'h00;
					8'h66 : PATTERN = 8'h00;
					8'h67 : PATTERN = 8'h00;
					8'h68 : PATTERN = 8'h00;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'h00;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h80;
					8'h73 : PATTERN = 8'hC0;
					8'h74 : PATTERN = 8'h60;
					8'h75 : PATTERN = 8'h30;
					8'h76 : PATTERN = 8'h18;
					8'h77 : PATTERN = 8'h08;
					8'h78 : PATTERN = 8'h0C;
					8'h79 : PATTERN = 8'hF8;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o3: begin //3
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h00;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h18;
					8'h33 : PATTERN = 8'h18;
					8'h34 : PATTERN = 8'h1C;
					8'h35 : PATTERN = 8'h3E;
					8'h36 : PATTERN = 8'h3E;
					8'h37 : PATTERN = 8'h3F;
					8'h38 : PATTERN = 8'h3F;
					8'h39 : PATTERN = 8'h3F;
					8'h3a : PATTERN = 8'h3F;
					8'h3b : PATTERN = 8'h1C;
					8'h3c : PATTERN = 8'h1C;
					8'h3d : PATTERN = 8'h1E;
					8'h3e : PATTERN = 8'h1E;
					8'h3f : PATTERN = 8'h1E;
					8'h40 : PATTERN = 8'h0E;
					8'h41 : PATTERN = 8'h3F;
					8'h42 : PATTERN = 8'hCF;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'hE0;
					8'h47 : PATTERN = 8'h20;
					8'h48 : PATTERN = 8'h20;
					8'h49 : PATTERN = 8'hC0;
					8'h4a : PATTERN = 8'h80;
					8'h4b : PATTERN = 8'h00;
					8'h4c : PATTERN = 8'h00;
					8'h4d : PATTERN = 8'h00;
					8'h4e : PATTERN = 8'h00;
					8'h4f : PATTERN = 8'h00;
					8'h50 : PATTERN = 8'h00;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h00;
					8'h54 : PATTERN = 8'h0F;
					8'h55 : PATTERN = 8'h3E;
					8'h56 : PATTERN = 8'h7E;
					8'h57 : PATTERN = 8'h7F;
					8'h58 : PATTERN = 8'h7F;
					8'h59 : PATTERN = 8'h3F;
					8'h5a : PATTERN = 8'hDF;
					8'h5b : PATTERN = 8'hE0;
					8'h5c : PATTERN = 8'hF0;
					8'h5d : PATTERN = 8'hF0;
					8'h5e : PATTERN = 8'hE0;
					8'h5f : PATTERN = 8'hE0;
					8'h60 : PATTERN = 8'hC0;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h03;
					8'h63 : PATTERN = 8'h3D;
					8'h64 : PATTERN = 8'hC0;
					8'h65 : PATTERN = 8'h00;
					8'h66 : PATTERN = 8'h00;
					8'h67 : PATTERN = 8'h00;
					8'h68 : PATTERN = 8'h00;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'h00;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'hC0;
					8'h6d : PATTERN = 8'h60;
					8'h6e : PATTERN = 8'h10;
					8'h6f : PATTERN = 8'h08;
					8'h70 : PATTERN = 8'h04;
					8'h71 : PATTERN = 8'h03;
					8'h72 : PATTERN = 8'h01;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h03;
					8'h7a : PATTERN = 8'hFF;
					8'h7b : PATTERN = 8'hE0;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o4: begin //4
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h00;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h00;
					8'h34 : PATTERN = 8'h00;
					8'h35 : PATTERN = 8'h00;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h07;
					8'h43 : PATTERN = 8'h1E;
					8'h44 : PATTERN = 8'hF0;
					8'h45 : PATTERN = 8'hF0;
					8'h46 : PATTERN = 8'hF7;
					8'h47 : PATTERN = 8'hEF;
					8'h48 : PATTERN = 8'hDF;
					8'h49 : PATTERN = 8'h1F;
					8'h4a : PATTERN = 8'h0F;
					8'h4b : PATTERN = 8'h00;
					8'h4c : PATTERN = 8'h00;
					8'h4d : PATTERN = 8'h10;
					8'h4e : PATTERN = 8'h00;
					8'h4f : PATTERN = 8'h09;
					8'h50 : PATTERN = 8'h02;
					8'h51 : PATTERN = 8'h02;
					8'h52 : PATTERN = 8'h02;
					8'h53 : PATTERN = 8'h02;
					8'h54 : PATTERN = 8'h02;
					8'h55 : PATTERN = 8'h00;
					8'h56 : PATTERN = 8'h00;
					8'h57 : PATTERN = 8'h00;
					8'h58 : PATTERN = 8'h00;
					8'h59 : PATTERN = 8'h00;
					8'h5a : PATTERN = 8'h00;
					8'h5b : PATTERN = 8'h03;
					8'h5c : PATTERN = 8'h03;
					8'h5d : PATTERN = 8'h03;
					8'h5e : PATTERN = 8'h03;
					8'h5f : PATTERN = 8'h03;
					8'h60 : PATTERN = 8'h00;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h00;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h01;
					8'h65 : PATTERN = 8'h07;
					8'h66 : PATTERN = 8'h0C;
					8'h67 : PATTERN = 8'hF0;
					8'h68 : PATTERN = 8'hD8;
					8'h69 : PATTERN = 8'h84;
					8'h6a : PATTERN = 8'h02;
					8'h6b : PATTERN = 8'h01;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h80;
					8'h76 : PATTERN = 8'h80;
					8'h77 : PATTERN = 8'hC0;
					8'h78 : PATTERN = 8'hC0;
					8'h79 : PATTERN = 8'h40;
					8'h7a : PATTERN = 8'h7F;
					8'h7b : PATTERN = 8'h7F;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o5: begin //5
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h30;
					8'h4 : PATTERN = 8'h30;
					8'h5 : PATTERN = 8'h30;
					8'h6 : PATTERN = 8'h30;
					8'h7 : PATTERN = 8'h30;
					8'h8 : PATTERN = 8'hF0;
					8'h9 : PATTERN = 8'hF0;
					8'ha : PATTERN = 8'h30;
					8'hb : PATTERN = 8'h30;
					8'hc : PATTERN = 8'h30;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'hB0;
					8'h11 : PATTERN = 8'hF0;
					8'h12 : PATTERN = 8'hF0;
					8'h13 : PATTERN = 8'h18;
					8'h14 : PATTERN = 8'h18;
					8'h15 : PATTERN = 8'h08;
					8'h16 : PATTERN = 8'h08;
					8'h17 : PATTERN = 8'h98;
					8'h18 : PATTERN = 8'hF8;
					8'h19 : PATTERN = 8'h70;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h18;
					8'h1c : PATTERN = 8'h38;
					8'h1d : PATTERN = 8'h78;
					8'h1e : PATTERN = 8'hE0;
					8'h1f : PATTERN = 8'hC0;
					8'h20 : PATTERN = 8'hC0;
					8'h21 : PATTERN = 8'hE0;
					8'h22 : PATTERN = 8'h60;
					8'h23 : PATTERN = 8'h30;
					8'h24 : PATTERN = 8'h30;
					8'h25 : PATTERN = 8'h10;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h1C;
					8'h28 : PATTERN = 8'h9C;
					8'h29 : PATTERN = 8'h90;
					8'h2a : PATTERN = 8'h9C;
					8'h2b : PATTERN = 8'h0C;
					8'h2c : PATTERN = 8'h08;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'hC0;
					8'h2f : PATTERN = 8'hC0;
					8'h30 : PATTERN = 8'hC0;
					8'h31 : PATTERN = 8'h80;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h00;
					8'h34 : PATTERN = 8'hC0;
					8'h35 : PATTERN = 8'hC0;
					8'h36 : PATTERN = 8'h80;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h80;
					8'h3b : PATTERN = 8'hE0;
					8'h3c : PATTERN = 8'hE0;
					8'h3d : PATTERN = 8'h30;
					8'h3e : PATTERN = 8'h10;
					8'h3f : PATTERN = 8'h10;
					8'h40 : PATTERN = 8'h10;
					8'h41 : PATTERN = 8'h30;
					8'h42 : PATTERN = 8'h30;
					8'h43 : PATTERN = 8'h20;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h01;
					8'h46 : PATTERN = 8'h03;
					8'h47 : PATTERN = 8'h07;
					8'h48 : PATTERN = 8'h87;
					8'h49 : PATTERN = 8'h84;
					8'h4a : PATTERN = 8'h84;
					8'h4b : PATTERN = 8'h84;
					8'h4c : PATTERN = 8'hFC;
					8'h4d : PATTERN = 8'h0C;
					8'h4e : PATTERN = 8'h0C;
					8'h4f : PATTERN = 8'h1C;
					8'h50 : PATTERN = 8'h98;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h00;
					8'h54 : PATTERN = 8'h00;
					8'h55 : PATTERN = 8'h00;
					8'h56 : PATTERN = 8'h00;
					8'h57 : PATTERN = 8'h40;
					8'h58 : PATTERN = 8'hF0;
					8'h59 : PATTERN = 8'h8C;
					8'h5a : PATTERN = 8'hC6;
					8'h5b : PATTERN = 8'hC0;
					8'h5c : PATTERN = 8'hC0;
					8'h5d : PATTERN = 8'hE0;
					8'h5e : PATTERN = 8'hC0;
					8'h5f : PATTERN = 8'h80;
					8'h60 : PATTERN = 8'h80;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h00;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h00;
					8'h65 : PATTERN = 8'h00;
					8'h66 : PATTERN = 8'h03;
					8'h67 : PATTERN = 8'hC3;
					8'h68 : PATTERN = 8'hE3;
					8'h69 : PATTERN = 8'hFE;
					8'h6a : PATTERN = 8'hF1;
					8'h6b : PATTERN = 8'hF3;
					8'h6c : PATTERN = 8'hFE;
					8'h6d : PATTERN = 8'hFC;
					8'h6e : PATTERN = 8'hF8;
					8'h6f : PATTERN = 8'hFC;
					8'h70 : PATTERN = 8'h7E;
					8'h71 : PATTERN = 8'h7F;
					8'h72 : PATTERN = 8'h23;
					8'h73 : PATTERN = 8'h01;
					8'h74 : PATTERN = 8'h01;
					8'h75 : PATTERN = 8'h01;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o6: begin //6
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h3F;
					8'h9 : PATTERN = 8'h3F;
					8'ha : PATTERN = 8'h30;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h06;
					8'h10 : PATTERN = 8'h07;
					8'h11 : PATTERN = 8'h3F;
					8'h12 : PATTERN = 8'h3F;
					8'h13 : PATTERN = 8'h07;
					8'h14 : PATTERN = 8'h0C;
					8'h15 : PATTERN = 8'h1C;
					8'h16 : PATTERN = 8'h3E;
					8'h17 : PATTERN = 8'h33;
					8'h18 : PATTERN = 8'h21;
					8'h19 : PATTERN = 8'h00;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h3F;
					8'h20 : PATTERN = 8'h3F;
					8'h21 : PATTERN = 8'h20;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h03;
					8'h29 : PATTERN = 8'h7F;
					8'h2a : PATTERN = 8'h7F;
					8'h2b : PATTERN = 8'h40;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h3F;
					8'h2f : PATTERN = 8'h3F;
					8'h30 : PATTERN = 8'h1F;
					8'h31 : PATTERN = 8'h07;
					8'h32 : PATTERN = 8'h0E;
					8'h33 : PATTERN = 8'h1C;
					8'h34 : PATTERN = 8'h3F;
					8'h35 : PATTERN = 8'h3F;
					8'h36 : PATTERN = 8'h3F;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h07;
					8'h3b : PATTERN = 8'h0F;
					8'h3c : PATTERN = 8'h1F;
					8'h3d : PATTERN = 8'h38;
					8'h3e : PATTERN = 8'h32;
					8'h3f : PATTERN = 8'h22;
					8'h40 : PATTERN = 8'h22;
					8'h41 : PATTERN = 8'h32;
					8'h42 : PATTERN = 8'h3E;
					8'h43 : PATTERN = 8'h1E;
					8'h44 : PATTERN = 8'h06;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h3F;
					8'h49 : PATTERN = 8'hF3;
					8'h4a : PATTERN = 8'hC0;
					8'h4b : PATTERN = 8'h01;
					8'h4c : PATTERN = 8'h02;
					8'h4d : PATTERN = 8'h03;
					8'h4e : PATTERN = 8'h86;
					8'h4f : PATTERN = 8'hF2;
					8'h50 : PATTERN = 8'hE1;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h00;
					8'h54 : PATTERN = 8'h00;
					8'h55 : PATTERN = 8'h00;
					8'h56 : PATTERN = 8'hE0;
					8'h57 : PATTERN = 8'hF8;
					8'h58 : PATTERN = 8'hF9;
					8'h59 : PATTERN = 8'h0B;
					8'h5a : PATTERN = 8'h73;
					8'h5b : PATTERN = 8'h1B;
					8'h5c : PATTERN = 8'h3B;
					8'h5d : PATTERN = 8'h7F;
					8'h5e : PATTERN = 8'h7F;
					8'h5f : PATTERN = 8'h7F;
					8'h60 : PATTERN = 8'hFF;
					8'h61 : PATTERN = 8'hE5;
					8'h62 : PATTERN = 8'hC0;
					8'h63 : PATTERN = 8'h80;
					8'h64 : PATTERN = 8'h80;
					8'h65 : PATTERN = 8'hC0;
					8'h66 : PATTERN = 8'hE0;
					8'h67 : PATTERN = 8'hFC;
					8'h68 : PATTERN = 8'hFF;
					8'h69 : PATTERN = 8'h3C;
					8'h6a : PATTERN = 8'h1F;
					8'h6b : PATTERN = 8'h1F;
					8'h6c : PATTERN = 8'h1F;
					8'h6d : PATTERN = 8'h0F;
					8'h6e : PATTERN = 8'h0E;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o7: begin //7
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h00;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h00;
					8'h34 : PATTERN = 8'h00;
					8'h35 : PATTERN = 8'h00;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h00;
					8'h49 : PATTERN = 8'h00;
					8'h4a : PATTERN = 8'h03;
					8'h4b : PATTERN = 8'h07;
					8'h4c : PATTERN = 8'h05;
					8'h4d : PATTERN = 8'h07;
					8'h4e : PATTERN = 8'h07;
					8'h4f : PATTERN = 8'h05;
					8'h50 : PATTERN = 8'h07;
					8'h51 : PATTERN = 8'h0A;
					8'h52 : PATTERN = 8'h0A;
					8'h53 : PATTERN = 8'h0A;
					8'h54 : PATTERN = 8'h0F;
					8'h55 : PATTERN = 8'h0F;
					8'h56 : PATTERN = 8'h0F;
					8'h57 : PATTERN = 8'h0F;
					8'h58 : PATTERN = 8'h0B;
					8'h59 : PATTERN = 8'h0B;
					8'h5a : PATTERN = 8'h0A;
					8'h5b : PATTERN = 8'h0C;
					8'h5c : PATTERN = 8'h0E;
					8'h5d : PATTERN = 8'h0E;
					8'h5e : PATTERN = 8'h0E;
					8'h5f : PATTERN = 8'h0F;
					8'h60 : PATTERN = 8'h0F;
					8'h61 : PATTERN = 8'h07;
					8'h62 : PATTERN = 8'h07;
					8'h63 : PATTERN = 8'h01;
					8'h64 : PATTERN = 8'h03;
					8'h65 : PATTERN = 8'h03;
					8'h66 : PATTERN = 8'h01;
					8'h67 : PATTERN = 8'h00;
					8'h68 : PATTERN = 8'h00;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'h00;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end

					endcase
				end
				
				win: begin
					case(X_PAGE)
						3'o0: begin //0
						case(INDEX)
						8'h0 : PATTERN = 8'h0;
						8'h1 : PATTERN = 8'h00;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'h00;
						8'h7 : PATTERN = 8'h00;
						8'h8 : PATTERN = 8'h00;
						8'h9 : PATTERN = 8'h00;
						8'ha : PATTERN = 8'h00;
						8'hb : PATTERN = 8'h00;
						8'hc : PATTERN = 8'h00;
						8'hd : PATTERN = 8'h00;
						8'he : PATTERN = 8'h00;
						8'hf : PATTERN = 8'h00;
						8'h10 : PATTERN = 8'h00;
						8'h11 : PATTERN = 8'h00;
						8'h12 : PATTERN = 8'h00;
						8'h13 : PATTERN = 8'h00;
						8'h14 : PATTERN = 8'h00;
						8'h15 : PATTERN = 8'h00;
						8'h16 : PATTERN = 8'h00;
						8'h17 : PATTERN = 8'h80;
						8'h18 : PATTERN = 8'h80;
						8'h19 : PATTERN = 8'h80;
						8'h1a : PATTERN = 8'h00;
						8'h1b : PATTERN = 8'h00;
						8'h1c : PATTERN = 8'h00;
						8'h1d : PATTERN = 8'h02;
						8'h1e : PATTERN = 8'h0E;
						8'h1f : PATTERN = 8'h3E;
						8'h20 : PATTERN = 8'h7E;
						8'h21 : PATTERN = 8'hFC;
						8'h22 : PATTERN = 8'hFC;
						8'h23 : PATTERN = 8'hFC;
						8'h24 : PATTERN = 8'hF8;
						8'h25 : PATTERN = 8'h78;
						8'h26 : PATTERN = 8'h30;
						8'h27 : PATTERN = 8'h30;
						8'h28 : PATTERN = 8'h20;
						8'h29 : PATTERN = 8'h20;
						8'h2a : PATTERN = 8'h40;
						8'h2b : PATTERN = 8'h40;
						8'h2c : PATTERN = 8'h80;
						8'h2d : PATTERN = 8'h80;
						8'h2e : PATTERN = 8'h00;
						8'h2f : PATTERN = 8'h00;
						8'h30 : PATTERN = 8'h80;
						8'h31 : PATTERN = 8'h80;
						8'h32 : PATTERN = 8'h80;
						8'h33 : PATTERN = 8'h80;
						8'h34 : PATTERN = 8'h80;
						8'h35 : PATTERN = 8'h80;
						8'h36 : PATTERN = 8'h80;
						8'h37 : PATTERN = 8'h00;
						8'h38 : PATTERN = 8'h00;
						8'h39 : PATTERN = 8'h00;
						8'h3a : PATTERN = 8'h00;
						8'h3b : PATTERN = 8'h00;
						8'h3c : PATTERN = 8'h00;
						8'h3d : PATTERN = 8'h00;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h00;
						8'h40 : PATTERN = 8'h00;
						8'h41 : PATTERN = 8'h00;
						8'h42 : PATTERN = 8'h00;
						8'h43 : PATTERN = 8'h00;
						8'h44 : PATTERN = 8'h00;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h00;
						8'h47 : PATTERN = 8'h00;
						8'h48 : PATTERN = 8'h80;
						8'h49 : PATTERN = 8'hC0;
						8'h4a : PATTERN = 8'hC0;
						8'h4b : PATTERN = 8'hE0;
						8'h4c : PATTERN = 8'hE0;
						8'h4d : PATTERN = 8'hF0;
						8'h4e : PATTERN = 8'hF0;
						8'h4f : PATTERN = 8'hF0;
						8'h50 : PATTERN = 8'h38;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h00;
						8'h53 : PATTERN = 8'h00;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : PATTERN = 8'h00;
						8'h59 : PATTERN = 8'h00;
						8'h5a : PATTERN = 8'h00;
						8'h5b : PATTERN = 8'h00;
						8'h5c : PATTERN = 8'h00;
						8'h5d : PATTERN = 8'h00;
						8'h5e : PATTERN = 8'h00;
						8'h5f : PATTERN = 8'h00;
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'h00;
						8'h63 : PATTERN = 8'h00;
						8'h64 : PATTERN = 8'h00;
						8'h65 : PATTERN = 8'h00;
						8'h66 : PATTERN = 8'h00;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'h00;
						8'h6a : PATTERN = 8'h00;
						8'h6b : PATTERN = 8'h00;
						8'h6c : PATTERN = 8'h00;
						8'h6d : PATTERN = 8'h00;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h00;
						8'h70 : PATTERN = 8'h00;
						8'h71 : PATTERN = 8'h00;
						8'h72 : PATTERN = 8'h00;
						8'h73 : PATTERN = 8'h00;
						8'h74 : PATTERN = 8'h00;
						8'h75 : PATTERN = 8'h00;
						8'h76 : PATTERN = 8'h00;
						8'h77 : PATTERN = 8'h00;
						8'h78 : PATTERN = 8'h00;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'h00;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o1: begin //1
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'h00;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'h00;
						8'h7 : PATTERN = 8'h00;
						8'h8 : PATTERN = 8'h00;
						8'h9 : PATTERN = 8'h00;
						8'ha : PATTERN = 8'h00;
						8'hb : PATTERN = 8'h00;
						8'hc : PATTERN = 8'h00;
						8'hd : PATTERN = 8'h00;
						8'he : PATTERN = 8'h00;
						8'hf : PATTERN = 8'hE0;
						8'h10 : PATTERN = 8'hF0;
						8'h11 : PATTERN = 8'hF0;
						8'h12 : PATTERN = 8'hF8;
						8'h13 : PATTERN = 8'hF0;
						8'h14 : PATTERN = 8'hF0;
						8'h15 : PATTERN = 8'hFC;
						8'h16 : PATTERN = 8'hFF;
						8'h17 : PATTERN = 8'hFF;
						8'h18 : PATTERN = 8'hFF;
						8'h19 : PATTERN = 8'hFF;
						8'h1a : PATTERN = 8'hFF;
						8'h1b : PATTERN = 8'hFE;
						8'h1c : PATTERN = 8'h00;
						8'h1d : PATTERN = 8'h00;
						8'h1e : PATTERN = 8'h00;
						8'h1f : PATTERN = 8'h00;
						8'h20 : PATTERN = 8'h00;
						8'h21 : PATTERN = 8'h00;
						8'h22 : PATTERN = 8'h03;
						8'h23 : PATTERN = 8'h07;
						8'h24 : PATTERN = 8'h0F;
						8'h25 : PATTERN = 8'h18;
						8'h26 : PATTERN = 8'h90;
						8'h27 : PATTERN = 8'h60;
						8'h28 : PATTERN = 8'h30;
						8'h29 : PATTERN = 8'h18;
						8'h2a : PATTERN = 8'h08;
						8'h2b : PATTERN = 8'h84;
						8'h2c : PATTERN = 8'h82;
						8'h2d : PATTERN = 8'h82;
						8'h2e : PATTERN = 8'h03;
						8'h2f : PATTERN = 8'h01;
						8'h30 : PATTERN = 8'h01;
						8'h31 : PATTERN = 8'h00;
						8'h32 : PATTERN = 8'h01;
						8'h33 : PATTERN = 8'h01;
						8'h34 : PATTERN = 8'h01;
						8'h35 : PATTERN = 8'h01;
						8'h36 : PATTERN = 8'h07;
						8'h37 : PATTERN = 8'h07;
						8'h38 : PATTERN = 8'h06;
						8'h39 : PATTERN = 8'h06;
						8'h3a : PATTERN = 8'h06;
						8'h3b : PATTERN = 8'h1C;
						8'h3c : PATTERN = 8'h18;
						8'h3d : PATTERN = 8'h10;
						8'h3e : PATTERN = 8'hA0;
						8'h3f : PATTERN = 8'hC0;
						8'h40 : PATTERN = 8'h60;
						8'h41 : PATTERN = 8'h30;
						8'h42 : PATTERN = 8'h10;
						8'h43 : PATTERN = 8'h08;
						8'h44 : PATTERN = 8'h04;
						8'h45 : PATTERN = 8'h06;
						8'h46 : PATTERN = 8'h07;
						8'h47 : PATTERN = 8'h07;
						8'h48 : PATTERN = 8'h1F;
						8'h49 : PATTERN = 8'hFF;
						8'h4a : PATTERN = 8'hFF;
						8'h4b : PATTERN = 8'hFF;
						8'h4c : PATTERN = 8'h3F;
						8'h4d : PATTERN = 8'h1F;
						8'h4e : PATTERN = 8'h07;
						8'h4f : PATTERN = 8'h01;
						8'h50 : PATTERN = 8'h00;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h00;
						8'h53 : PATTERN = 8'h00;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : PATTERN = 8'h00;
						8'h59 : PATTERN = 8'h00;
						8'h5a : PATTERN = 8'h00;
						8'h5b : PATTERN = 8'h00;
						8'h5c : PATTERN = 8'h00;
						8'h5d : PATTERN = 8'h00;
						8'h5e : PATTERN = 8'h00;
						8'h5f : PATTERN = 8'h00;
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'h00;
						8'h63 : PATTERN = 8'h00;
						8'h64 : PATTERN = 8'h00;
						8'h65 : PATTERN = 8'h00;
						8'h66 : PATTERN = 8'h00;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'h00;
						8'h6a : PATTERN = 8'h00;
						8'h6b : PATTERN = 8'h00;
						8'h6c : PATTERN = 8'h00;
						8'h6d : PATTERN = 8'h00;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h00;
						8'h70 : PATTERN = 8'h00;
						8'h71 : PATTERN = 8'h00;
						8'h72 : PATTERN = 8'h00;
						8'h73 : PATTERN = 8'h00;
						8'h74 : PATTERN = 8'h00;
						8'h75 : PATTERN = 8'h00;
						8'h76 : PATTERN = 8'h00;
						8'h77 : PATTERN = 8'h00;
						8'h78 : PATTERN = 8'h00;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'h00;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o2: begin //2
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'h00;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'h00;
						8'h7 : PATTERN = 8'h00;
						8'h8 : PATTERN = 8'h00;
						8'h9 : PATTERN = 8'h00;
						8'ha : PATTERN = 8'h00;
						8'hb : PATTERN = 8'h00;
						8'hc : PATTERN = 8'h00;
						8'hd : PATTERN = 8'h00;
						8'he : PATTERN = 8'h00;
						8'hf : PATTERN = 8'h01;
						8'h10 : PATTERN = 8'h03;
						8'h11 : PATTERN = 8'h07;
						8'h12 : PATTERN = 8'h07;
						8'h13 : PATTERN = 8'h07;
						8'h14 : PATTERN = 8'h0F;
						8'h15 : PATTERN = 8'h0F;
						8'h16 : PATTERN = 8'h0F;
						8'h17 : PATTERN = 8'h0F;
						8'h18 : PATTERN = 8'h07;
						8'h19 : PATTERN = 8'h07;
						8'h1a : PATTERN = 8'h07;
						8'h1b : PATTERN = 8'h01;
						8'h1c : PATTERN = 8'h00;
						8'h1d : PATTERN = 8'h00;
						8'h1e : PATTERN = 8'h00;
						8'h1f : PATTERN = 8'h00;
						8'h20 : PATTERN = 8'h00;
						8'h21 : PATTERN = 8'h00;
						8'h22 : PATTERN = 8'hF8;
						8'h23 : PATTERN = 8'hFC;
						8'h24 : PATTERN = 8'hFE;
						8'h25 : PATTERN = 8'hF3;
						8'h26 : PATTERN = 8'h61;
						8'h27 : PATTERN = 8'h00;
						8'h28 : PATTERN = 8'h7C;
						8'h29 : PATTERN = 8'h7E;
						8'h2a : PATTERN = 8'h7F;
						8'h2b : PATTERN = 8'h3F;
						8'h2c : PATTERN = 8'h1F;
						8'h2d : PATTERN = 8'h0D;
						8'h2e : PATTERN = 8'h00;
						8'h2f : PATTERN = 8'h00;
						8'h30 : PATTERN = 8'h00;
						8'h31 : PATTERN = 8'h00;
						8'h32 : PATTERN = 8'h00;
						8'h33 : PATTERN = 8'h00;
						8'h34 : PATTERN = 8'h00;
						8'h35 : PATTERN = 8'h00;
						8'h36 : PATTERN = 8'h00;
						8'h37 : PATTERN = 8'h80;
						8'h38 : PATTERN = 8'hC0;
						8'h39 : PATTERN = 8'hE0;
						8'h3a : PATTERN = 8'h20;
						8'h3b : PATTERN = 8'h20;
						8'h3c : PATTERN = 8'h00;
						8'h3d : PATTERN = 8'h00;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h00;
						8'h40 : PATTERN = 8'h00;
						8'h41 : PATTERN = 8'h00;
						8'h42 : PATTERN = 8'h00;
						8'h43 : PATTERN = 8'hC0;
						8'h44 : PATTERN = 8'h60;
						8'h45 : PATTERN = 8'h20;
						8'h46 : PATTERN = 8'h10;
						8'h47 : PATTERN = 8'h18;
						8'h48 : PATTERN = 8'h0E;
						8'h49 : PATTERN = 8'h03;
						8'h4a : PATTERN = 8'h01;
						8'h4b : PATTERN = 8'h00;
						8'h4c : PATTERN = 8'h00;
						8'h4d : PATTERN = 8'h00;
						8'h4e : PATTERN = 8'h00;
						8'h4f : PATTERN = 8'h00;
						8'h50 : PATTERN = 8'h00;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h00;
						8'h53 : PATTERN = 8'h00;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : PATTERN = 8'h00;
						8'h59 : PATTERN = 8'h00;
						8'h5a : PATTERN = 8'h00;
						8'h5b : PATTERN = 8'h00;
						8'h5c : PATTERN = 8'h00;
						8'h5d : PATTERN = 8'h00;
						8'h5e : PATTERN = 8'h00;
						8'h5f : PATTERN = 8'h00;
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'h00;
						8'h63 : PATTERN = 8'h00;
						8'h64 : PATTERN = 8'h00;
						8'h65 : PATTERN = 8'h00;
						8'h66 : PATTERN = 8'h00;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'h00;
						8'h6a : PATTERN = 8'h00;
						8'h6b : PATTERN = 8'h00;
						8'h6c : PATTERN = 8'h00;
						8'h6d : PATTERN = 8'h00;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h00;
						8'h70 : PATTERN = 8'h00;
						8'h71 : PATTERN = 8'h00;
						8'h72 : PATTERN = 8'h00;
						8'h73 : PATTERN = 8'h00;
						8'h74 : PATTERN = 8'h00;
						8'h75 : PATTERN = 8'h00;
						8'h76 : PATTERN = 8'h00;
						8'h77 : PATTERN = 8'h00;
						8'h78 : PATTERN = 8'h00;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'h00;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o3: begin //3
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'h00;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'h00;
						8'h7 : PATTERN = 8'h00;
						8'h8 : PATTERN = 8'h00;
						8'h9 : PATTERN = 8'h00;
						8'ha : PATTERN = 8'h00;
						8'hb : PATTERN = 8'h00;
						8'hc : PATTERN = 8'h80;
						8'hd : PATTERN = 8'h80;
						8'he : PATTERN = 8'h40;
						8'hf : PATTERN = 8'hC0;
						8'h10 : PATTERN = 8'h00;
						8'h11 : PATTERN = 8'h00;
						8'h12 : PATTERN = 8'h00;
						8'h13 : PATTERN = 8'h00;
						8'h14 : PATTERN = 8'h00;
						8'h15 : PATTERN = 8'h00;
						8'h16 : PATTERN = 8'h00;
						8'h17 : PATTERN = 8'h00;
						8'h18 : PATTERN = 8'h00;
						8'h19 : PATTERN = 8'h00;
						8'h1a : PATTERN = 8'h00;
						8'h1b : PATTERN = 8'h00;
						8'h1c : PATTERN = 8'h00;
						8'h1d : PATTERN = 8'h00;
						8'h1e : PATTERN = 8'h00;
						8'h1f : PATTERN = 8'h00;
						8'h20 : PATTERN = 8'h00;
						8'h21 : PATTERN = 8'h00;
						8'h22 : PATTERN = 8'h83;
						8'h23 : PATTERN = 8'hFD;
						8'h24 : PATTERN = 8'h21;
						8'h25 : PATTERN = 8'h21;
						8'h26 : PATTERN = 8'h30;
						8'h27 : PATTERN = 8'h20;
						8'h28 : PATTERN = 8'h20;
						8'h29 : PATTERN = 8'h60;
						8'h2a : PATTERN = 8'hC0;
						8'h2b : PATTERN = 8'h02;
						8'h2c : PATTERN = 8'h1C;
						8'h2d : PATTERN = 8'h3C;
						8'h2e : PATTERN = 8'h7C;
						8'h2f : PATTERN = 8'h79;
						8'h30 : PATTERN = 8'h78;
						8'h31 : PATTERN = 8'h38;
						8'h32 : PATTERN = 8'h10;
						8'h33 : PATTERN = 8'h00;
						8'h34 : PATTERN = 8'h00;
						8'h35 : PATTERN = 8'h00;
						8'h36 : PATTERN = 8'h8F;
						8'h37 : PATTERN = 8'hDF;
						8'h38 : PATTERN = 8'hDF;
						8'h39 : PATTERN = 8'hDF;
						8'h3a : PATTERN = 8'hDF;
						8'h3b : PATTERN = 8'hCE;
						8'h3c : PATTERN = 8'h02;
						8'h3d : PATTERN = 8'h00;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h00;
						8'h40 : PATTERN = 8'h80;
						8'h41 : PATTERN = 8'hE0;
						8'h42 : PATTERN = 8'h3E;
						8'h43 : PATTERN = 8'h07;
						8'h44 : PATTERN = 8'h00;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h00;
						8'h47 : PATTERN = 8'h00;
						8'h48 : PATTERN = 8'h00;
						8'h49 : PATTERN = 8'h00;
						8'h4a : PATTERN = 8'h00;
						8'h4b : PATTERN = 8'h03;
						8'h4c : PATTERN = 8'h06;
						8'h4d : PATTERN = 8'h08;
						8'h4e : PATTERN = 8'h18;
						8'h4f : PATTERN = 8'hF8;
						8'h50 : PATTERN = 8'h08;
						8'h51 : PATTERN = 8'h08;
						8'h52 : PATTERN = 8'h04;
						8'h53 : PATTERN = 8'h06;
						8'h54 : PATTERN = 8'h02;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : PATTERN = 8'h00;
						8'h59 : PATTERN = 8'hF8;
						8'h5a : PATTERN = 8'h0C;
						8'h5b : PATTERN = 8'h04;
						8'h5c : PATTERN = 8'h02;
						8'h5d : PATTERN = 8'h02;
						8'h5e : PATTERN = 8'h02;
						8'h5f : PATTERN = 8'h02;
						8'h60 : PATTERN = 8'h06;
						8'h61 : PATTERN = 8'h04;
						8'h62 : PATTERN = 8'h08;
						8'h63 : PATTERN = 8'hF0;
						8'h64 : PATTERN = 8'h00;
						8'h65 : PATTERN = 8'h00;
						8'h66 : PATTERN = 8'h00;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'hFC;
						8'h6a : PATTERN = 8'h00;
						8'h6b : PATTERN = 8'h00;
						8'h6c : PATTERN = 8'h00;
						8'h6d : PATTERN = 8'h00;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h00;
						8'h70 : PATTERN = 8'h18;
						8'h71 : PATTERN = 8'h70;
						8'h72 : PATTERN = 8'h80;
						8'h73 : PATTERN = 8'h00;
						8'h74 : PATTERN = 8'h00;
						8'h75 : PATTERN = 8'h00;
						8'h76 : PATTERN = 8'h00;
						8'h77 : PATTERN = 8'h00;
						8'h78 : PATTERN = 8'h00;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'h00;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o4: begin //4
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'h00;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'h00;
						8'h7 : PATTERN = 8'h00;
						8'h8 : PATTERN = 8'h80;
						8'h9 : PATTERN = 8'hE0;
						8'ha : PATTERN = 8'h38;
						8'hb : PATTERN = 8'h0E;
						8'hc : PATTERN = 8'h03;
						8'hd : PATTERN = 8'h00;
						8'he : PATTERN = 8'h00;
						8'hf : PATTERN = 8'h01;
						8'h10 : PATTERN = 8'h3E;
						8'h11 : PATTERN = 8'hC0;
						8'h12 : PATTERN = 8'h00;
						8'h13 : PATTERN = 8'h00;
						8'h14 : PATTERN = 8'h00;
						8'h15 : PATTERN = 8'h00;
						8'h16 : PATTERN = 8'hE0;
						8'h17 : PATTERN = 8'h18;
						8'h18 : PATTERN = 8'h04;
						8'h19 : PATTERN = 8'h0E;
						8'h1a : PATTERN = 8'h02;
						8'h1b : PATTERN = 8'h1A;
						8'h1c : PATTERN = 8'h06;
						8'h1d : PATTERN = 8'h0C;
						8'h1e : PATTERN = 8'hF8;
						8'h1f : PATTERN = 8'h08;
						8'h20 : PATTERN = 8'h08;
						8'h21 : PATTERN = 8'h0C;
						8'h22 : PATTERN = 8'h03;
						8'h23 : PATTERN = 8'h00;
						8'h24 : PATTERN = 8'h00;
						8'h25 : PATTERN = 8'h00;
						8'h26 : PATTERN = 8'h00;
						8'h27 : PATTERN = 8'h00;
						8'h28 : PATTERN = 8'h18;
						8'h29 : PATTERN = 8'h0E;
						8'h2a : PATTERN = 8'h03;
						8'h2b : PATTERN = 8'h00;
						8'h2c : PATTERN = 8'h08;
						8'h2d : PATTERN = 8'h00;
						8'h2e : PATTERN = 8'hFC;
						8'h2f : PATTERN = 8'h04;
						8'h30 : PATTERN = 8'h02;
						8'h31 : PATTERN = 8'h02;
						8'h32 : PATTERN = 8'h06;
						8'h33 : PATTERN = 8'h0C;
						8'h34 : PATTERN = 8'h18;
						8'h35 : PATTERN = 8'h70;
						8'h36 : PATTERN = 8'h41;
						8'h37 : PATTERN = 8'h07;
						8'h38 : PATTERN = 8'h07;
						8'h39 : PATTERN = 8'h07;
						8'h3a : PATTERN = 8'hF7;
						8'h3b : PATTERN = 8'h13;
						8'h3c : PATTERN = 8'h18;
						8'h3d : PATTERN = 8'h08;
						8'h3e : PATTERN = 8'h0C;
						8'h3f : PATTERN = 8'h06;
						8'h40 : PATTERN = 8'h03;
						8'h41 : PATTERN = 8'h00;
						8'h42 : PATTERN = 8'h00;
						8'h43 : PATTERN = 8'h00;
						8'h44 : PATTERN = 8'h00;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h00;
						8'h47 : PATTERN = 8'h00;
						8'h48 : PATTERN = 8'h00;
						8'h49 : PATTERN = 8'h00;
						8'h4a : PATTERN = 8'h00;
						8'h4b : PATTERN = 8'h00;
						8'h4c : PATTERN = 8'h00;
						8'h4d : PATTERN = 8'h00;
						8'h4e : PATTERN = 8'h00;
						8'h4f : PATTERN = 8'h07;
						8'h50 : PATTERN = 8'h00;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h00;
						8'h53 : PATTERN = 8'h00;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : PATTERN = 8'h00;
						8'h59 : PATTERN = 8'h01;
						8'h5a : PATTERN = 8'h02;
						8'h5b : PATTERN = 8'h04;
						8'h5c : PATTERN = 8'h08;
						8'h5d : PATTERN = 8'h08;
						8'h5e : PATTERN = 8'h08;
						8'h5f : PATTERN = 8'h08;
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h04;
						8'h62 : PATTERN = 8'h02;
						8'h63 : PATTERN = 8'h00;
						8'h64 : PATTERN = 8'h00;
						8'h65 : PATTERN = 8'h00;
						8'h66 : PATTERN = 8'h00;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'h03;
						8'h6a : PATTERN = 8'h06;
						8'h6b : PATTERN = 8'h04;
						8'h6c : PATTERN = 8'h0C;
						8'h6d : PATTERN = 8'h08;
						8'h6e : PATTERN = 8'h08;
						8'h6f : PATTERN = 8'h08;
						8'h70 : PATTERN = 8'h04;
						8'h71 : PATTERN = 8'h02;
						8'h72 : PATTERN = 8'h01;
						8'h73 : PATTERN = 8'h00;
						8'h74 : PATTERN = 8'h00;
						8'h75 : PATTERN = 8'h00;
						8'h76 : PATTERN = 8'h00;
						8'h77 : PATTERN = 8'h00;
						8'h78 : PATTERN = 8'h00;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'h00;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o5: begin //5
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'h00;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'hF0;
						8'h7 : PATTERN = 8'h7E;
						8'h8 : PATTERN = 8'h07;
						8'h9 : PATTERN = 8'h00;
						8'ha : PATTERN = 8'h00;
						8'hb : PATTERN = 8'h00;
						8'hc : PATTERN = 8'h00;
						8'hd : PATTERN = 8'h00;
						8'he : PATTERN = 8'h00;
						8'hf : PATTERN = 8'h00;
						8'h10 : PATTERN = 8'h00;
						8'h11 : PATTERN = 8'h03;
						8'h12 : PATTERN = 8'h1C;
						8'h13 : PATTERN = 8'hE0;
						8'h14 : PATTERN = 8'h00;
						8'h15 : PATTERN = 8'h00;
						8'h16 : PATTERN = 8'h0F;
						8'h17 : PATTERN = 8'h10;
						8'h18 : PATTERN = 8'h20;
						8'h19 : PATTERN = 8'h20;
						8'h1a : PATTERN = 8'hE0;
						8'h1b : PATTERN = 8'hA0;
						8'h1c : PATTERN = 8'h00;
						8'h1d : PATTERN = 8'h00;
						8'h1e : PATTERN = 8'h00;
						8'h1f : PATTERN = 8'h00;
						8'h20 : PATTERN = 8'h00;
						8'h21 : PATTERN = 8'h00;
						8'h22 : PATTERN = 8'h00;
						8'h23 : PATTERN = 8'h00;
						8'h24 : PATTERN = 8'h00;
						8'h25 : PATTERN = 8'h00;
						8'h26 : PATTERN = 8'h00;
						8'h27 : PATTERN = 8'h00;
						8'h28 : PATTERN = 8'hC0;
						8'h29 : PATTERN = 8'h20;
						8'h2a : PATTERN = 8'h10;
						8'h2b : PATTERN = 8'h70;
						8'h2c : PATTERN = 8'h30;
						8'h2d : PATTERN = 8'h10;
						8'h2e : PATTERN = 8'hD1;
						8'h2f : PATTERN = 8'h61;
						8'h30 : PATTERN = 8'hE0;
						8'h31 : PATTERN = 8'h00;
						8'h32 : PATTERN = 8'h00;
						8'h33 : PATTERN = 8'h00;
						8'h34 : PATTERN = 8'h00;
						8'h35 : PATTERN = 8'h00;
						8'h36 : PATTERN = 8'h1E;
						8'h37 : PATTERN = 8'h7E;
						8'h38 : PATTERN = 8'hFC;
						8'h39 : PATTERN = 8'h7F;
						8'h3a : PATTERN = 8'h03;
						8'h3b : PATTERN = 8'h00;
						8'h3c : PATTERN = 8'h00;
						8'h3d : PATTERN = 8'h00;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h00;
						8'h40 : PATTERN = 8'h00;
						8'h41 : PATTERN = 8'h00;
						8'h42 : PATTERN = 8'h00;
						8'h43 : PATTERN = 8'h00;
						8'h44 : PATTERN = 8'h00;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h00;
						8'h47 : PATTERN = 8'h00;
						8'h48 : PATTERN = 8'h00;
						8'h49 : PATTERN = 8'h00;
						8'h4a : PATTERN = 8'h00;
						8'h4b : PATTERN = 8'h80;
						8'h4c : PATTERN = 8'h00;
						8'h4d : PATTERN = 8'h00;
						8'h4e : PATTERN = 8'h00;
						8'h4f : PATTERN = 8'h00;
						8'h50 : PATTERN = 8'h00;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h80;
						8'h53 : PATTERN = 8'h00;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : PATTERN = 8'h00;
						8'h59 : PATTERN = 8'hE0;
						8'h5a : PATTERN = 8'h00;
						8'h5b : PATTERN = 8'h00;
						8'h5c : PATTERN = 8'h00;
						8'h5d : PATTERN = 8'h00;
						8'h5e : PATTERN = 8'h00;
						8'h5f : PATTERN = 8'h00;
						8'h60 : PATTERN = 8'h0C;
						8'h61 : PATTERN = 8'h18;
						8'h62 : PATTERN = 8'h98;
						8'h63 : PATTERN = 8'h04;
						8'h64 : PATTERN = 8'h06;
						8'h65 : PATTERN = 8'h00;
						8'h66 : PATTERN = 8'h00;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'h00;
						8'h6a : PATTERN = 8'hC0;
						8'h6b : PATTERN = 8'hC0;
						8'h6c : PATTERN = 8'h00;
						8'h6d : PATTERN = 8'h00;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h00;
						8'h70 : PATTERN = 8'h00;
						8'h71 : PATTERN = 8'h00;
						8'h72 : PATTERN = 8'hE0;
						8'h73 : PATTERN = 8'h00;
						8'h74 : PATTERN = 8'h00;
						8'h75 : PATTERN = 8'h00;
						8'h76 : PATTERN = 8'h00;
						8'h77 : PATTERN = 8'h00;
						8'h78 : PATTERN = 8'h00;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'h00;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o6: begin //6
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'h00;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h01;
						8'h6 : PATTERN = 8'h0F;
						8'h7 : PATTERN = 8'h18;
						8'h8 : PATTERN = 8'h60;
						8'h9 : PATTERN = 8'hC0;
						8'ha : PATTERN = 8'h98;
						8'hb : PATTERN = 8'h78;
						8'hc : PATTERN = 8'hF8;
						8'hd : PATTERN = 8'hF0;
						8'he : PATTERN = 8'hC0;
						8'hf : PATTERN = 8'h00;
						8'h10 : PATTERN = 8'h00;
						8'h11 : PATTERN = 8'h00;
						8'h12 : PATTERN = 8'h00;
						8'h13 : PATTERN = 8'h01;
						8'h14 : PATTERN = 8'h0E;
						8'h15 : PATTERN = 8'h30;
						8'h16 : PATTERN = 8'h20;
						8'h17 : PATTERN = 8'h10;
						8'h18 : PATTERN = 8'h08;
						8'h19 : PATTERN = 8'h08;
						8'h1a : PATTERN = 8'h10;
						8'h1b : PATTERN = 8'h21;
						8'h1c : PATTERN = 8'h42;
						8'h1d : PATTERN = 8'h8C;
						8'h1e : PATTERN = 8'h9C;
						8'h1f : PATTERN = 8'hF8;
						8'h20 : PATTERN = 8'hF8;
						8'h21 : PATTERN = 8'hF8;
						8'h22 : PATTERN = 8'hF8;
						8'h23 : PATTERN = 8'hF8;
						8'h24 : PATTERN = 8'hF0;
						8'h25 : PATTERN = 8'hF0;
						8'h26 : PATTERN = 8'hE0;
						8'h27 : PATTERN = 8'hE0;
						8'h28 : PATTERN = 8'hE3;
						8'h29 : PATTERN = 8'h80;
						8'h2a : PATTERN = 8'h80;
						8'h2b : PATTERN = 8'h00;
						8'h2c : PATTERN = 8'h00;
						8'h2d : PATTERN = 8'h60;
						8'h2e : PATTERN = 8'h20;
						8'h2f : PATTERN = 8'h18;
						8'h30 : PATTERN = 8'h8F;
						8'h31 : PATTERN = 8'h80;
						8'h32 : PATTERN = 8'h40;
						8'h33 : PATTERN = 8'h60;
						8'h34 : PATTERN = 8'h3E;
						8'h35 : PATTERN = 8'h1E;
						8'h36 : PATTERN = 8'h0C;
						8'h37 : PATTERN = 8'h03;
						8'h38 : PATTERN = 8'h01;
						8'h39 : PATTERN = 8'h00;
						8'h3a : PATTERN = 8'h00;
						8'h3b : PATTERN = 8'h00;
						8'h3c : PATTERN = 8'h00;
						8'h3d : PATTERN = 8'h00;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h00;
						8'h40 : PATTERN = 8'h00;
						8'h41 : PATTERN = 8'h00;
						8'h42 : PATTERN = 8'h00;
						8'h43 : PATTERN = 8'h00;
						8'h44 : PATTERN = 8'h00;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h00;
						8'h47 : PATTERN = 8'h00;
						8'h48 : PATTERN = 8'h00;
						8'h49 : PATTERN = 8'h00;
						8'h4a : PATTERN = 8'h00;
						8'h4b : PATTERN = 8'h01;
						8'h4c : PATTERN = 8'h06;
						8'h4d : PATTERN = 8'h38;
						8'h4e : PATTERN = 8'hF0;
						8'h4f : PATTERN = 8'h70;
						8'h50 : PATTERN = 8'h18;
						8'h51 : PATTERN = 8'h03;
						8'h52 : PATTERN = 8'h03;
						8'h53 : PATTERN = 8'h02;
						8'h54 : PATTERN = 8'h08;
						8'h55 : PATTERN = 8'h70;
						8'h56 : PATTERN = 8'hF0;
						8'h57 : PATTERN = 8'h30;
						8'h58 : PATTERN = 8'h0F;
						8'h59 : PATTERN = 8'h00;
						8'h5a : PATTERN = 8'h00;
						8'h5b : PATTERN = 8'h00;
						8'h5c : PATTERN = 8'h00;
						8'h5d : PATTERN = 8'h00;
						8'h5e : PATTERN = 8'h00;
						8'h5f : PATTERN = 8'h00;
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'h7F;
						8'h63 : PATTERN = 8'hF0;
						8'h64 : PATTERN = 8'h00;
						8'h65 : PATTERN = 8'h00;
						8'h66 : PATTERN = 8'h00;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'h00;
						8'h6a : PATTERN = 8'hFF;
						8'h6b : PATTERN = 8'h03;
						8'h6c : PATTERN = 8'h03;
						8'h6d : PATTERN = 8'h06;
						8'h6e : PATTERN = 8'h0C;
						8'h6f : PATTERN = 8'h18;
						8'h70 : PATTERN = 8'h30;
						8'h71 : PATTERN = 8'h70;
						8'h72 : PATTERN = 8'h7F;
						8'h73 : PATTERN = 8'h78;
						8'h74 : PATTERN = 8'h00;
						8'h75 : PATTERN = 8'h00;
						8'h76 : PATTERN = 8'h00;
						8'h77 : PATTERN = 8'h00;
						8'h78 : PATTERN = 8'h00;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'h00;
						8'h7f : PATTERN = 8'h00;
						endcase
						end
						3'o7: begin //7
						case(INDEX)
						8'h0 : PATTERN = 8'h00;
						8'h1 : PATTERN = 8'h00;
						8'h2 : PATTERN = 8'h00;
						8'h3 : PATTERN = 8'h00;
						8'h4 : PATTERN = 8'h00;
						8'h5 : PATTERN = 8'h00;
						8'h6 : PATTERN = 8'h00;
						8'h7 : PATTERN = 8'h00;
						8'h8 : PATTERN = 8'h00;
						8'h9 : PATTERN = 8'h00;
						8'ha : PATTERN = 8'h01;
						8'hb : PATTERN = 8'h03;
						8'hc : PATTERN = 8'h07;
						8'hd : PATTERN = 8'h0F;
						8'he : PATTERN = 8'h1F;
						8'hf : PATTERN = 8'h3F;
						8'h10 : PATTERN = 8'h7E;
						8'h11 : PATTERN = 8'h5E;
						8'h12 : PATTERN = 8'h3C;
						8'h13 : PATTERN = 8'h1C;
						8'h14 : PATTERN = 8'h10;
						8'h15 : PATTERN = 8'h08;
						8'h16 : PATTERN = 8'h04;
						8'h17 : PATTERN = 8'h06;
						8'h18 : PATTERN = 8'h03;
						8'h19 : PATTERN = 8'h03;
						8'h1a : PATTERN = 8'h02;
						8'h1b : PATTERN = 8'h04;
						8'h1c : PATTERN = 8'h08;
						8'h1d : PATTERN = 8'h08;
						8'h1e : PATTERN = 8'h05;
						8'h1f : PATTERN = 8'h03;
						8'h20 : PATTERN = 8'h03;
						8'h21 : PATTERN = 8'h01;
						8'h22 : PATTERN = 8'h00;
						8'h23 : PATTERN = 8'h00;
						8'h24 : PATTERN = 8'h01;
						8'h25 : PATTERN = 8'h01;
						8'h26 : PATTERN = 8'h01;
						8'h27 : PATTERN = 8'h01;
						8'h28 : PATTERN = 8'h03;
						8'h29 : PATTERN = 8'h03;
						8'h2a : PATTERN = 8'h03;
						8'h2b : PATTERN = 8'h03;
						8'h2c : PATTERN = 8'h01;
						8'h2d : PATTERN = 8'h01;
						8'h2e : PATTERN = 8'h01;
						8'h2f : PATTERN = 8'h01;
						8'h30 : PATTERN = 8'h00;
						8'h31 : PATTERN = 8'h00;
						8'h32 : PATTERN = 8'h00;
						8'h33 : PATTERN = 8'h00;
						8'h34 : PATTERN = 8'h00;
						8'h35 : PATTERN = 8'h00;
						8'h36 : PATTERN = 8'h00;
						8'h37 : PATTERN = 8'h00;
						8'h38 : PATTERN = 8'h00;
						8'h39 : PATTERN = 8'h00;
						8'h3a : PATTERN = 8'h00;
						8'h3b : PATTERN = 8'h00;
						8'h3c : PATTERN = 8'h00;
						8'h3d : PATTERN = 8'h00;
						8'h3e : PATTERN = 8'h00;
						8'h3f : PATTERN = 8'h00;
						8'h40 : PATTERN = 8'h00;
						8'h41 : PATTERN = 8'h00;
						8'h42 : PATTERN = 8'h00;
						8'h43 : PATTERN = 8'h00;
						8'h44 : PATTERN = 8'h00;
						8'h45 : PATTERN = 8'h00;
						8'h46 : PATTERN = 8'h00;
						8'h47 : PATTERN = 8'h00;
						8'h48 : PATTERN = 8'h00;
						8'h49 : PATTERN = 8'h00;
						8'h4a : PATTERN = 8'h00;
						8'h4b : PATTERN = 8'h00;
						8'h4c : PATTERN = 8'h00;
						8'h4d : PATTERN = 8'h00;
						8'h4e : PATTERN = 8'h00;
						8'h4f : PATTERN = 8'h00;
						8'h50 : PATTERN = 8'h00;
						8'h51 : PATTERN = 8'h00;
						8'h52 : PATTERN = 8'h00;
						8'h53 : PATTERN = 8'h00;
						8'h54 : PATTERN = 8'h00;
						8'h55 : PATTERN = 8'h00;
						8'h56 : PATTERN = 8'h00;
						8'h57 : PATTERN = 8'h00;
						8'h58 : PATTERN = 8'h00;
						8'h59 : PATTERN = 8'h00;
						8'h5a : PATTERN = 8'h00;
						8'h5b : PATTERN = 8'h00;
						8'h5c : PATTERN = 8'h00;
						8'h5d : PATTERN = 8'h00;
						8'h5e : PATTERN = 8'h00;
						8'h5f : PATTERN = 8'h00;
						8'h60 : PATTERN = 8'h00;
						8'h61 : PATTERN = 8'h00;
						8'h62 : PATTERN = 8'h00;
						8'h63 : PATTERN = 8'h01;
						8'h64 : PATTERN = 8'h00;
						8'h65 : PATTERN = 8'h00;
						8'h66 : PATTERN = 8'h00;
						8'h67 : PATTERN = 8'h00;
						8'h68 : PATTERN = 8'h00;
						8'h69 : PATTERN = 8'h00;
						8'h6a : PATTERN = 8'h00;
						8'h6b : PATTERN = 8'h00;
						8'h6c : PATTERN = 8'h00;
						8'h6d : PATTERN = 8'h00;
						8'h6e : PATTERN = 8'h00;
						8'h6f : PATTERN = 8'h00;
						8'h70 : PATTERN = 8'h00;
						8'h71 : PATTERN = 8'h00;
						8'h72 : PATTERN = 8'h00;
						8'h73 : PATTERN = 8'h00;
						8'h74 : PATTERN = 8'h00;
						8'h75 : PATTERN = 8'h00;
						8'h76 : PATTERN = 8'h00;
						8'h77 : PATTERN = 8'h00;
						8'h78 : PATTERN = 8'h00;
						8'h79 : PATTERN = 8'h00;
						8'h7a : PATTERN = 8'h00;
						8'h7b : PATTERN = 8'h00;
						8'h7c : PATTERN = 8'h00;
						8'h7d : PATTERN = 8'h00;
						8'h7e : PATTERN = 8'h00;
						8'h7f : PATTERN = 8'h00;
						endcase
						end

					endcase
				end
				
				fail: begin
					case(X_PAGE)
					3'o0: begin //0
					case(INDEX)
					8'h0 : PATTERN = 8'h0;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h00;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h00;
					8'h34 : PATTERN = 8'h00;
					8'h35 : PATTERN = 8'h00;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h00;
					8'h3a : PATTERN = 8'h00;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h00;
					8'h49 : PATTERN = 8'h00;
					8'h4a : PATTERN = 8'h00;
					8'h4b : PATTERN = 8'h00;
					8'h4c : PATTERN = 8'h00;
					8'h4d : PATTERN = 8'h80;
					8'h4e : PATTERN = 8'h00;
					8'h4f : PATTERN = 8'h00;
					8'h50 : PATTERN = 8'h00;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h00;
					8'h54 : PATTERN = 8'h00;
					8'h55 : PATTERN = 8'h00;
					8'h56 : PATTERN = 8'h00;
					8'h57 : PATTERN = 8'h00;
					8'h58 : PATTERN = 8'h00;
					8'h59 : PATTERN = 8'h30;
					8'h5a : PATTERN = 8'h00;
					8'h5b : PATTERN = 8'h20;
					8'h5c : PATTERN = 8'h00;
					8'h5d : PATTERN = 8'h40;
					8'h5e : PATTERN = 8'h40;
					8'h5f : PATTERN = 8'h80;
					8'h60 : PATTERN = 8'h00;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h00;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h00;
					8'h65 : PATTERN = 8'h00;
					8'h66 : PATTERN = 8'h00;
					8'h67 : PATTERN = 8'h00;
					8'h68 : PATTERN = 8'h00;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'h00;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o1: begin //1
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h00;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h80;
					8'h1f : PATTERN = 8'h80;
					8'h20 : PATTERN = 8'hC0;
					8'h21 : PATTERN = 8'h40;
					8'h22 : PATTERN = 8'h40;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h80;
					8'h25 : PATTERN = 8'hA0;
					8'h26 : PATTERN = 8'hE0;
					8'h27 : PATTERN = 8'hE0;
					8'h28 : PATTERN = 8'hE0;
					8'h29 : PATTERN = 8'hF0;
					8'h2a : PATTERN = 8'hF0;
					8'h2b : PATTERN = 8'hF0;
					8'h2c : PATTERN = 8'h70;
					8'h2d : PATTERN = 8'h30;
					8'h2e : PATTERN = 8'h10;
					8'h2f : PATTERN = 8'h10;
					8'h30 : PATTERN = 8'h08;
					8'h31 : PATTERN = 8'h08;
					8'h32 : PATTERN = 8'h0C;
					8'h33 : PATTERN = 8'h04;
					8'h34 : PATTERN = 8'h04;
					8'h35 : PATTERN = 8'h05;
					8'h36 : PATTERN = 8'h04;
					8'h37 : PATTERN = 8'h04;
					8'h38 : PATTERN = 8'h04;
					8'h39 : PATTERN = 8'h04;
					8'h3a : PATTERN = 8'h0C;
					8'h3b : PATTERN = 8'h0C;
					8'h3c : PATTERN = 8'h0C;
					8'h3d : PATTERN = 8'h1C;
					8'h3e : PATTERN = 8'h3C;
					8'h3f : PATTERN = 8'h3E;
					8'h40 : PATTERN = 8'h3E;
					8'h41 : PATTERN = 8'h7E;
					8'h42 : PATTERN = 8'hFE;
					8'h43 : PATTERN = 8'hFF;
					8'h44 : PATTERN = 8'hFF;
					8'h45 : PATTERN = 8'hBF;
					8'h46 : PATTERN = 8'hFF;
					8'h47 : PATTERN = 8'hF3;
					8'h48 : PATTERN = 8'hE7;
					8'h49 : PATTERN = 8'hCF;
					8'h4a : PATTERN = 8'h1F;
					8'h4b : PATTERN = 8'h3F;
					8'h4c : PATTERN = 8'h7E;
					8'h4d : PATTERN = 8'hFE;
					8'h4e : PATTERN = 8'hDC;
					8'h4f : PATTERN = 8'h38;
					8'h50 : PATTERN = 8'h7A;
					8'h51 : PATTERN = 8'hF0;
					8'h52 : PATTERN = 8'hE0;
					8'h53 : PATTERN = 8'hE0;
					8'h54 : PATTERN = 8'hC0;
					8'h55 : PATTERN = 8'h80;
					8'h56 : PATTERN = 8'hF8;
					8'h57 : PATTERN = 8'hF0;
					8'h58 : PATTERN = 8'hE0;
					8'h59 : PATTERN = 8'h78;
					8'h5a : PATTERN = 8'h94;
					8'h5b : PATTERN = 8'hF0;
					8'h5c : PATTERN = 8'h70;
					8'h5d : PATTERN = 8'hC0;
					8'h5e : PATTERN = 8'h80;
					8'h5f : PATTERN = 8'h00;
					8'h60 : PATTERN = 8'h01;
					8'h61 : PATTERN = 8'h01;
					8'h62 : PATTERN = 8'h02;
					8'h63 : PATTERN = 8'h04;
					8'h64 : PATTERN = 8'h08;
					8'h65 : PATTERN = 8'h10;
					8'h66 : PATTERN = 8'h30;
					8'h67 : PATTERN = 8'h60;
					8'h68 : PATTERN = 8'hC0;
					8'h69 : PATTERN = 8'h90;
					8'h6a : PATTERN = 8'h20;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o2: begin //2
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h00;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h01;
					8'h1e : PATTERN = 8'h03;
					8'h1f : PATTERN = 8'h03;
					8'h20 : PATTERN = 8'h03;
					8'h21 : PATTERN = 8'h03;
					8'h22 : PATTERN = 8'h03;
					8'h23 : PATTERN = 8'h07;
					8'h24 : PATTERN = 8'h07;
					8'h25 : PATTERN = 8'h07;
					8'h26 : PATTERN = 8'h87;
					8'h27 : PATTERN = 8'hF7;
					8'h28 : PATTERN = 8'h1F;
					8'h29 : PATTERN = 8'h03;
					8'h2a : PATTERN = 8'h01;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h00;
					8'h34 : PATTERN = 8'h00;
					8'h35 : PATTERN = 8'h00;
					8'h36 : PATTERN = 8'h00;
					8'h37 : PATTERN = 8'h00;
					8'h38 : PATTERN = 8'h00;
					8'h39 : PATTERN = 8'h80;
					8'h3a : PATTERN = 8'hC0;
					8'h3b : PATTERN = 8'h20;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h80;
					8'h42 : PATTERN = 8'hC0;
					8'h43 : PATTERN = 8'h61;
					8'h44 : PATTERN = 8'h3B;
					8'h45 : PATTERN = 8'h05;
					8'h46 : PATTERN = 8'h01;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h01;
					8'h49 : PATTERN = 8'h03;
					8'h4a : PATTERN = 8'h07;
					8'h4b : PATTERN = 8'h04;
					8'h4c : PATTERN = 8'h00;
					8'h4d : PATTERN = 8'h00;
					8'h4e : PATTERN = 8'h01;
					8'h4f : PATTERN = 8'h01;
					8'h50 : PATTERN = 8'h00;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h01;
					8'h53 : PATTERN = 8'h03;
					8'h54 : PATTERN = 8'h07;
					8'h55 : PATTERN = 8'h3F;
					8'h56 : PATTERN = 8'hE7;
					8'h57 : PATTERN = 8'h03;
					8'h58 : PATTERN = 8'h01;
					8'h59 : PATTERN = 8'h03;
					8'h5a : PATTERN = 8'h01;
					8'h5b : PATTERN = 8'h00;
					8'h5c : PATTERN = 8'h00;
					8'h5d : PATTERN = 8'h00;
					8'h5e : PATTERN = 8'h03;
					8'h5f : PATTERN = 8'h0E;
					8'h60 : PATTERN = 8'h30;
					8'h61 : PATTERN = 8'hC0;
					8'h62 : PATTERN = 8'h80;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h80;
					8'h65 : PATTERN = 8'h80;
					8'h66 : PATTERN = 8'h80;
					8'h67 : PATTERN = 8'h80;
					8'h68 : PATTERN = 8'h80;
					8'h69 : PATTERN = 8'h81;
					8'h6a : PATTERN = 8'h82;
					8'h6b : PATTERN = 8'h84;
					8'h6c : PATTERN = 8'hE1;
					8'h6d : PATTERN = 8'h02;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o3: begin //3
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h00;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h01;
					8'h1d : PATTERN = 8'h03;
					8'h1e : PATTERN = 8'h06;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h04;
					8'h21 : PATTERN = 8'h0C;
					8'h22 : PATTERN = 8'h0C;
					8'h23 : PATTERN = 8'h06;
					8'h24 : PATTERN = 8'hC2;
					8'h25 : PATTERN = 8'hE0;
					8'h26 : PATTERN = 8'hF0;
					8'h27 : PATTERN = 8'hFB;
					8'h28 : PATTERN = 8'h74;
					8'h29 : PATTERN = 8'h18;
					8'h2a : PATTERN = 8'h18;
					8'h2b : PATTERN = 8'h30;
					8'h2c : PATTERN = 8'h30;
					8'h2d : PATTERN = 8'h10;
					8'h2e : PATTERN = 8'h20;
					8'h2f : PATTERN = 8'h60;
					8'h30 : PATTERN = 8'h60;
					8'h31 : PATTERN = 8'h60;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h62;
					8'h34 : PATTERN = 8'hC2;
					8'h35 : PATTERN = 8'hC2;
					8'h36 : PATTERN = 8'h82;
					8'h37 : PATTERN = 8'hBE;
					8'h38 : PATTERN = 8'h9F;
					8'h39 : PATTERN = 8'h9F;
					8'h3a : PATTERN = 8'h9C;
					8'h3b : PATTERN = 8'h98;
					8'h3c : PATTERN = 8'hBC;
					8'h3d : PATTERN = 8'hFC;
					8'h3e : PATTERN = 8'h7E;
					8'h3f : PATTERN = 8'h7E;
					8'h40 : PATTERN = 8'h3F;
					8'h41 : PATTERN = 8'h3F;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h00;
					8'h49 : PATTERN = 8'h00;
					8'h4a : PATTERN = 8'h80;
					8'h4b : PATTERN = 8'h80;
					8'h4c : PATTERN = 8'hC0;
					8'h4d : PATTERN = 8'hC0;
					8'h4e : PATTERN = 8'hC0;
					8'h4f : PATTERN = 8'hC0;
					8'h50 : PATTERN = 8'h40;
					8'h51 : PATTERN = 8'h60;
					8'h52 : PATTERN = 8'h20;
					8'h53 : PATTERN = 8'h30;
					8'h54 : PATTERN = 8'h30;
					8'h55 : PATTERN = 8'h20;
					8'h56 : PATTERN = 8'h61;
					8'h57 : PATTERN = 8'h2C;
					8'h58 : PATTERN = 8'h20;
					8'h59 : PATTERN = 8'h36;
					8'h5a : PATTERN = 8'h00;
					8'h5b : PATTERN = 8'h00;
					8'h5c : PATTERN = 8'h00;
					8'h5d : PATTERN = 8'h00;
					8'h5e : PATTERN = 8'h00;
					8'h5f : PATTERN = 8'h00;
					8'h60 : PATTERN = 8'h00;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h01;
					8'h63 : PATTERN = 8'h01;
					8'h64 : PATTERN = 8'h01;
					8'h65 : PATTERN = 8'h01;
					8'h66 : PATTERN = 8'h01;
					8'h67 : PATTERN = 8'h01;
					8'h68 : PATTERN = 8'h00;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'h00;
					8'h6b : PATTERN = 8'h01;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o4: begin //4
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h00;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h00;
					8'ha : PATTERN = 8'h00;
					8'hb : PATTERN = 8'h00;
					8'hc : PATTERN = 8'h00;
					8'hd : PATTERN = 8'h00;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h04;
					8'h1a : PATTERN = 8'h0E;
					8'h1b : PATTERN = 8'h1C;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h30;
					8'h1e : PATTERN = 8'h70;
					8'h1f : PATTERN = 8'h60;
					8'h20 : PATTERN = 8'h70;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'hC1;
					8'h26 : PATTERN = 8'hF3;
					8'h27 : PATTERN = 8'hFB;
					8'h28 : PATTERN = 8'hFB;
					8'h29 : PATTERN = 8'hFA;
					8'h2a : PATTERN = 8'hFE;
					8'h2b : PATTERN = 8'hFC;
					8'h2c : PATTERN = 8'hE4;
					8'h2d : PATTERN = 8'h14;
					8'h2e : PATTERN = 8'h0D;
					8'h2f : PATTERN = 8'h0C;
					8'h30 : PATTERN = 8'h0C;
					8'h31 : PATTERN = 8'h08;
					8'h32 : PATTERN = 8'h08;
					8'h33 : PATTERN = 8'h08;
					8'h34 : PATTERN = 8'h28;
					8'h35 : PATTERN = 8'h38;
					8'h36 : PATTERN = 8'h08;
					8'h37 : PATTERN = 8'h0F;
					8'h38 : PATTERN = 8'h1F;
					8'h39 : PATTERN = 8'h3F;
					8'h3a : PATTERN = 8'h3F;
					8'h3b : PATTERN = 8'h33;
					8'h3c : PATTERN = 8'h31;
					8'h3d : PATTERN = 8'h10;
					8'h3e : PATTERN = 8'h10;
					8'h3f : PATTERN = 8'h10;
					8'h40 : PATTERN = 8'h08;
					8'h41 : PATTERN = 8'h08;
					8'h42 : PATTERN = 8'h04;
					8'h43 : PATTERN = 8'h06;
					8'h44 : PATTERN = 8'h06;
					8'h45 : PATTERN = 8'h02;
					8'h46 : PATTERN = 8'h02;
					8'h47 : PATTERN = 8'h02;
					8'h48 : PATTERN = 8'h00;
					8'h49 : PATTERN = 8'h01;
					8'h4a : PATTERN = 8'h00;
					8'h4b : PATTERN = 8'h00;
					8'h4c : PATTERN = 8'h00;
					8'h4d : PATTERN = 8'h00;
					8'h4e : PATTERN = 8'h00;
					8'h4f : PATTERN = 8'h00;
					8'h50 : PATTERN = 8'h00;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h00;
					8'h54 : PATTERN = 8'h00;
					8'h55 : PATTERN = 8'h00;
					8'h56 : PATTERN = 8'h00;
					8'h57 : PATTERN = 8'h00;
					8'h58 : PATTERN = 8'h00;
					8'h59 : PATTERN = 8'h00;
					8'h5a : PATTERN = 8'h00;
					8'h5b : PATTERN = 8'h00;
					8'h5c : PATTERN = 8'h00;
					8'h5d : PATTERN = 8'h00;
					8'h5e : PATTERN = 8'h00;
					8'h5f : PATTERN = 8'h00;
					8'h60 : PATTERN = 8'h00;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h00;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h00;
					8'h65 : PATTERN = 8'h00;
					8'h66 : PATTERN = 8'h00;
					8'h67 : PATTERN = 8'h00;
					8'h68 : PATTERN = 8'h00;
					8'h69 : PATTERN = 8'h00;
					8'h6a : PATTERN = 8'h00;
					8'h6b : PATTERN = 8'h00;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h00;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h00;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o5: begin //5
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h80;
					8'h8 : PATTERN = 8'h40;
					8'h9 : PATTERN = 8'h40;
					8'ha : PATTERN = 8'h40;
					8'hb : PATTERN = 8'h40;
					8'hc : PATTERN = 8'h80;
					8'hd : PATTERN = 8'h80;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h00;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h80;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h00;
					8'h25 : PATTERN = 8'h01;
					8'h26 : PATTERN = 8'h01;
					8'h27 : PATTERN = 8'h03;
					8'h28 : PATTERN = 8'h03;
					8'h29 : PATTERN = 8'h03;
					8'h2a : PATTERN = 8'h01;
					8'h2b : PATTERN = 8'h01;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h00;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h00;
					8'h34 : PATTERN = 8'h00;
					8'h35 : PATTERN = 8'h80;
					8'h36 : PATTERN = 8'h80;
					8'h37 : PATTERN = 8'h80;
					8'h38 : PATTERN = 8'h80;
					8'h39 : PATTERN = 8'h80;
					8'h3a : PATTERN = 8'h80;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h00;
					8'h49 : PATTERN = 8'h00;
					8'h4a : PATTERN = 8'h00;
					8'h4b : PATTERN = 8'h80;
					8'h4c : PATTERN = 8'h80;
					8'h4d : PATTERN = 8'h80;
					8'h4e : PATTERN = 8'h80;
					8'h4f : PATTERN = 8'h80;
					8'h50 : PATTERN = 8'h00;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h00;
					8'h54 : PATTERN = 8'h00;
					8'h55 : PATTERN = 8'h00;
					8'h56 : PATTERN = 8'h00;
					8'h57 : PATTERN = 8'h00;
					8'h58 : PATTERN = 8'h00;
					8'h59 : PATTERN = 8'h00;
					8'h5a : PATTERN = 8'h00;
					8'h5b : PATTERN = 8'h00;
					8'h5c : PATTERN = 8'h00;
					8'h5d : PATTERN = 8'h00;
					8'h5e : PATTERN = 8'h00;
					8'h5f : PATTERN = 8'h00;
					8'h60 : PATTERN = 8'h00;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h00;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h00;
					8'h65 : PATTERN = 8'h00;
					8'h66 : PATTERN = 8'h80;
					8'h67 : PATTERN = 8'h80;
					8'h68 : PATTERN = 8'h80;
					8'h69 : PATTERN = 8'h80;
					8'h6a : PATTERN = 8'h80;
					8'h6b : PATTERN = 8'h80;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h80;
					8'h73 : PATTERN = 8'hC0;
					8'h74 : PATTERN = 8'hC0;
					8'h75 : PATTERN = 8'h40;
					8'h76 : PATTERN = 8'h40;
					8'h77 : PATTERN = 8'h40;
					8'h78 : PATTERN = 8'h40;
					8'h79 : PATTERN = 8'h40;
					8'h7a : PATTERN = 8'h80;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o6: begin //6
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h7E;
					8'h6 : PATTERN = 8'hC1;
					8'h7 : PATTERN = 8'h80;
					8'h8 : PATTERN = 8'h00;
					8'h9 : PATTERN = 8'h10;
					8'ha : PATTERN = 8'h10;
					8'hb : PATTERN = 8'h10;
					8'hc : PATTERN = 8'h10;
					8'hd : PATTERN = 8'h11;
					8'he : PATTERN = 8'hF0;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h00;
					8'h15 : PATTERN = 8'h80;
					8'h16 : PATTERN = 8'h60;
					8'h17 : PATTERN = 8'h38;
					8'h18 : PATTERN = 8'h2E;
					8'h19 : PATTERN = 8'h23;
					8'h1a : PATTERN = 8'h23;
					8'h1b : PATTERN = 8'h24;
					8'h1c : PATTERN = 8'h30;
					8'h1d : PATTERN = 8'hC0;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'hFF;
					8'h25 : PATTERN = 8'h1C;
					8'h26 : PATTERN = 8'h18;
					8'h27 : PATTERN = 8'h20;
					8'h28 : PATTERN = 8'h20;
					8'h29 : PATTERN = 8'h10;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h08;
					8'h2c : PATTERN = 8'h0E;
					8'h2d : PATTERN = 8'hF0;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h00;
					8'h34 : PATTERN = 8'hFF;
					8'h35 : PATTERN = 8'h11;
					8'h36 : PATTERN = 8'h11;
					8'h37 : PATTERN = 8'h11;
					8'h38 : PATTERN = 8'h11;
					8'h39 : PATTERN = 8'h11;
					8'h3a : PATTERN = 8'h11;
					8'h3b : PATTERN = 8'h00;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h7E;
					8'h49 : PATTERN = 8'h83;
					8'h4a : PATTERN = 8'h01;
					8'h4b : PATTERN = 8'h00;
					8'h4c : PATTERN = 8'h00;
					8'h4d : PATTERN = 8'h00;
					8'h4e : PATTERN = 8'h00;
					8'h4f : PATTERN = 8'h01;
					8'h50 : PATTERN = 8'h01;
					8'h51 : PATTERN = 8'h82;
					8'h52 : PATTERN = 8'h3C;
					8'h53 : PATTERN = 8'h00;
					8'h54 : PATTERN = 8'h00;
					8'h55 : PATTERN = 8'h00;
					8'h56 : PATTERN = 8'h00;
					8'h57 : PATTERN = 8'h00;
					8'h58 : PATTERN = 8'h0C;
					8'h59 : PATTERN = 8'h30;
					8'h5a : PATTERN = 8'hC0;
					8'h5b : PATTERN = 8'h00;
					8'h5c : PATTERN = 8'h00;
					8'h5d : PATTERN = 8'h80;
					8'h5e : PATTERN = 8'h60;
					8'h5f : PATTERN = 8'h1C;
					8'h60 : PATTERN = 8'h00;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h00;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h00;
					8'h65 : PATTERN = 8'hFF;
					8'h66 : PATTERN = 8'h11;
					8'h67 : PATTERN = 8'h11;
					8'h68 : PATTERN = 8'h11;
					8'h69 : PATTERN = 8'h11;
					8'h6a : PATTERN = 8'h11;
					8'h6b : PATTERN = 8'h11;
					8'h6c : PATTERN = 8'h00;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h30;
					8'h72 : PATTERN = 8'h79;
					8'h73 : PATTERN = 8'h7F;
					8'h74 : PATTERN = 8'h30;
					8'h75 : PATTERN = 8'h20;
					8'h76 : PATTERN = 8'h60;
					8'h77 : PATTERN = 8'hA0;
					8'h78 : PATTERN = 8'h00;
					8'h79 : PATTERN = 8'h10;
					8'h7a : PATTERN = 8'h04;
					8'h7b : PATTERN = 8'h03;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
					3'o7: begin //7
					case(INDEX)
					8'h0 : PATTERN = 8'h00;
					8'h1 : PATTERN = 8'h00;
					8'h2 : PATTERN = 8'h00;
					8'h3 : PATTERN = 8'h00;
					8'h4 : PATTERN = 8'h00;
					8'h5 : PATTERN = 8'h00;
					8'h6 : PATTERN = 8'h00;
					8'h7 : PATTERN = 8'h01;
					8'h8 : PATTERN = 8'h01;
					8'h9 : PATTERN = 8'h02;
					8'ha : PATTERN = 8'h02;
					8'hb : PATTERN = 8'h02;
					8'hc : PATTERN = 8'h03;
					8'hd : PATTERN = 8'h01;
					8'he : PATTERN = 8'h00;
					8'hf : PATTERN = 8'h00;
					8'h10 : PATTERN = 8'h00;
					8'h11 : PATTERN = 8'h00;
					8'h12 : PATTERN = 8'h00;
					8'h13 : PATTERN = 8'h00;
					8'h14 : PATTERN = 8'h03;
					8'h15 : PATTERN = 8'h01;
					8'h16 : PATTERN = 8'h00;
					8'h17 : PATTERN = 8'h00;
					8'h18 : PATTERN = 8'h00;
					8'h19 : PATTERN = 8'h00;
					8'h1a : PATTERN = 8'h00;
					8'h1b : PATTERN = 8'h00;
					8'h1c : PATTERN = 8'h00;
					8'h1d : PATTERN = 8'h00;
					8'h1e : PATTERN = 8'h00;
					8'h1f : PATTERN = 8'h00;
					8'h20 : PATTERN = 8'h00;
					8'h21 : PATTERN = 8'h00;
					8'h22 : PATTERN = 8'h00;
					8'h23 : PATTERN = 8'h00;
					8'h24 : PATTERN = 8'h03;
					8'h25 : PATTERN = 8'h00;
					8'h26 : PATTERN = 8'h00;
					8'h27 : PATTERN = 8'h00;
					8'h28 : PATTERN = 8'h00;
					8'h29 : PATTERN = 8'h00;
					8'h2a : PATTERN = 8'h00;
					8'h2b : PATTERN = 8'h00;
					8'h2c : PATTERN = 8'h00;
					8'h2d : PATTERN = 8'h03;
					8'h2e : PATTERN = 8'h00;
					8'h2f : PATTERN = 8'h00;
					8'h30 : PATTERN = 8'h00;
					8'h31 : PATTERN = 8'h00;
					8'h32 : PATTERN = 8'h00;
					8'h33 : PATTERN = 8'h00;
					8'h34 : PATTERN = 8'h03;
					8'h35 : PATTERN = 8'h02;
					8'h36 : PATTERN = 8'h02;
					8'h37 : PATTERN = 8'h02;
					8'h38 : PATTERN = 8'h02;
					8'h39 : PATTERN = 8'h02;
					8'h3a : PATTERN = 8'h02;
					8'h3b : PATTERN = 8'h02;
					8'h3c : PATTERN = 8'h00;
					8'h3d : PATTERN = 8'h00;
					8'h3e : PATTERN = 8'h00;
					8'h3f : PATTERN = 8'h00;
					8'h40 : PATTERN = 8'h00;
					8'h41 : PATTERN = 8'h00;
					8'h42 : PATTERN = 8'h00;
					8'h43 : PATTERN = 8'h00;
					8'h44 : PATTERN = 8'h00;
					8'h45 : PATTERN = 8'h00;
					8'h46 : PATTERN = 8'h00;
					8'h47 : PATTERN = 8'h00;
					8'h48 : PATTERN = 8'h00;
					8'h49 : PATTERN = 8'h00;
					8'h4a : PATTERN = 8'h01;
					8'h4b : PATTERN = 8'h02;
					8'h4c : PATTERN = 8'h02;
					8'h4d : PATTERN = 8'h02;
					8'h4e : PATTERN = 8'h02;
					8'h4f : PATTERN = 8'h00;
					8'h50 : PATTERN = 8'h01;
					8'h51 : PATTERN = 8'h00;
					8'h52 : PATTERN = 8'h00;
					8'h53 : PATTERN = 8'h00;
					8'h54 : PATTERN = 8'h00;
					8'h55 : PATTERN = 8'h00;
					8'h56 : PATTERN = 8'h00;
					8'h57 : PATTERN = 8'h00;
					8'h58 : PATTERN = 8'h00;
					8'h59 : PATTERN = 8'h00;
					8'h5a : PATTERN = 8'h00;
					8'h5b : PATTERN = 8'h01;
					8'h5c : PATTERN = 8'h03;
					8'h5d : PATTERN = 8'h01;
					8'h5e : PATTERN = 8'h00;
					8'h5f : PATTERN = 8'h00;
					8'h60 : PATTERN = 8'h00;
					8'h61 : PATTERN = 8'h00;
					8'h62 : PATTERN = 8'h00;
					8'h63 : PATTERN = 8'h00;
					8'h64 : PATTERN = 8'h00;
					8'h65 : PATTERN = 8'h03;
					8'h66 : PATTERN = 8'h02;
					8'h67 : PATTERN = 8'h02;
					8'h68 : PATTERN = 8'h02;
					8'h69 : PATTERN = 8'h02;
					8'h6a : PATTERN = 8'h02;
					8'h6b : PATTERN = 8'h02;
					8'h6c : PATTERN = 8'h02;
					8'h6d : PATTERN = 8'h00;
					8'h6e : PATTERN = 8'h00;
					8'h6f : PATTERN = 8'h00;
					8'h70 : PATTERN = 8'h00;
					8'h71 : PATTERN = 8'h00;
					8'h72 : PATTERN = 8'h00;
					8'h73 : PATTERN = 8'h03;
					8'h74 : PATTERN = 8'h00;
					8'h75 : PATTERN = 8'h00;
					8'h76 : PATTERN = 8'h00;
					8'h77 : PATTERN = 8'h00;
					8'h78 : PATTERN = 8'h01;
					8'h79 : PATTERN = 8'h02;
					8'h7a : PATTERN = 8'h00;
					8'h7b : PATTERN = 8'h00;
					8'h7c : PATTERN = 8'h00;
					8'h7d : PATTERN = 8'h00;
					8'h7e : PATTERN = 8'h00;
					8'h7f : PATTERN = 8'h00;
					endcase
					end
						
					endcase
				end
				default:PATTERN = 8'h00;
			endcase
		end
	end
	

/*********************************************************
			* Initialize and Write LCD Data *
**********************************************************/
	always@(negedge  LCD_clk or negedge  S1_reset)begin
		if(!S1_reset)begin
			CLEAR <= 1'b1;
			STATE <= 3'b0;
			DELAY <= 2'b00;
			X_PAGE <= 3'o0;
			INDEX = 0;
			LCD_RST<= 1'b0;
			ENABLE <= 2'b00;
			LCD_SEL<= 2'b11;
			LCD_DI <= 1'b0;
			LCD_RW <= 1'b0;
		end
		else begin
			if(ENABLE < 2'b10)begin
				ENABLE <= ENABLE + 1;
				DELAY[1]<= 1'b1;
			end
			else if(DELAY != 2'b00)
				DELAY <= DELAY -1;
			else if(STATE == 3'o0)begin
				STATE <= 3'o1;
				LCD_RST <= 1'b1;
				LCD_DATA<= 8'h3F;
				ENABLE <= 2'b00;
			end
			else if(STATE == 3'o1)begin
				STATE <= 3'o2;
				LCD_DATA<= {2'b11,6'b000000};
				ENABLE <= 2'b00;
			end
			else if(STATE == 3'o2)begin
				STATE <= 3'o3;
				LCD_DATA<= 8'h40;
				ENABLE <= 2'b00;
			end
			else if(STATE == 3'o3)begin
				STATE <= 3'o4;
				LCD_DI <= 1'b0;
				INDEX = 0;
				LCD_DATA<= {5'b10111,X_PAGE};
				ENABLE <= 2'b00;
			end
			else if(STATE == 3'o4)begin
				if(CLEAR)begin
					if(INDEX < 64)begin
						INDEX = INDEX + 1;
						LCD_DI <= 1'b1;
						LCD_DATA<= 8'h00;
						ENABLE <= 2'b00;
					end
					else if(X_PAGE < 3'o7)begin
						STATE <= 3'o3;
						X_PAGE <= X_PAGE + 1;
					end
					else begin
						STATE <= 3'o3;
						X_PAGE <= 3'o3;
						CLEAR <= 1'b0;
					end
				end
				else if((X_PAGE == 3'o0)||(X_PAGE == 3'o1)||(X_PAGE == 3'o2)||(X_PAGE == 3'o3)||(X_PAGE == 3'o4)||(X_PAGE == 3'o5)||(X_PAGE == 3'o6)||(X_PAGE == 3'o7)) begin
					if(INDEX < 128)begin
						LCD_DI <= 1'b1;
						LCD_DATA <= PATTERN;
						if(INDEX < 64)
							LCD_SEL <= 2'b01;
						else
							LCD_SEL <= 2'b10;
						INDEX = INDEX + 1;
						ENABLE<= 2'b00;
					end
					else begin
						LCD_SEL <= 2'b11;
						STATE <= 3'o3;
						X_PAGE <= X_PAGE + 1;
					end
				end
			end
		end
	end
	assign LCD_ENABLE = ENABLE[0];
	assign LCD_CS1 = LCD_SEL[0];
	assign LCD_CS2 = LCD_SEL[1];
endmodule
