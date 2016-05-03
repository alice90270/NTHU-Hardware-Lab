`timescale 1ns / 1ps
module Lab6(LCD_ENABLE, LCD_RW, LCD_DI, LCD_CS1, LCD_CS2, LCD_RST, LCD_DATA, clk, reset, start, pause);

	input clk;
	input reset;
	input start;
	input pause;
	output LCD_ENABLE;
	output LCD_RW;
	output LCD_DI;
	output LCD_CS1;
	output LCD_CS2;
	output LCD_RST;
	output [7:0] LCD_DATA;
	
	wire reset_db,start_db, pause_db;
	wire reset_op,start_op, pause_op;
	wire [1:0] state;
	wire [0:255] pattern;
	wire clk_LCD;
	wire clk8, clk16;
	
	clock_divider cd(clk16,clk8,clk);
	clock_generator_LCD CLK_GEN (clk,reset,clk_LCD);
	
	debounce db0(reset_db, reset, clk16);
	debounce db1(start_db, start, clk16);
	debounce db2(pause_db, pause, clk16);
	
	onepulse op0(reset_op, reset_db, clk16);
	onepulse op1(start_op, start_db, clk16);
	onepulse op2(pause_op, pause_db, clk16);
	
	state_ctrl state_translate(state, start_op, pause_op, clk16, reset_db);
	display_ctrl gen_pattern(pattern, reset_op, clk_LCD, state);
	LCD_display lcd(LCD_ENABLE,LCD_RW,LCD_DI,LCD_CS1,LCD_CS2,LCD_RST,LCD_DATA,pattern,reset_op,clk8);

endmodule
