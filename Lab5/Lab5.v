`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:36:48 04/02/2015 
// Design Name: 
// Module Name:    Lab5 
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
module Lab5(DIGIT, DISPLAY, max, min, clk, reset, en, speed, mode);
     input clk;
     input reset;
     input en;
     input speed;
     input mode;
     output [3:0] DIGIT;
     output [7:0] DISPLAY;
     output max;
     output min;
     wire clk24;
     wire clk22;    
     wire clk15;
     wire mux_ppc_speed;
     wire db_ppc_reset;
     wire db_ppc_en;
     wire [3:0] BCD0_7;
     wire [3:0] BCD1_7;
	  reg min_flag,max_flag;
	  wire max,min;

     clk_divider15 clk_15(.clk_div(clk15), .clk(clk));
     clk_divider22 clk_22(.clk_div(clk22), .clk(clk));
     clk_divider24 clk_24(.clk_div(clk24), .clk(clk));
     mux choose_speed(.speed(mux_ppc_speed),.select(speed),.a(clk22),.b(clk24));
     debounce db1(.pb_debounced(db_ppc_reset), .pb(reset), .clk(clk15));
     debounce db2(.pb_debounced(db_ppc_en), .pb(en), .clk(clk15));
     pingpong_counter ppc(.BCD0(BCD0_7),.BCD1(BCD1_7), .max(max), .min(min),.reset(db_ppc_reset),.en(db_ppc_en),.speed(mux_ppc_speed),.mode(mode));
     sevenSegement segment7(.DISPLAY(DISPLAY),.DIGIT(DIGIT),.BCD0(BCD0_7),.BCD1(BCD1_7),.clk(clk15));
endmodule

//pingpong_counter
module pingpong_counter(BCD0,BCD1, max, min,reset,en,speed,mode);
     output [3:0] BCD0,BCD1;
	  output max, min;
     input reset,en,speed,mode;
	  reg dir;
	  reg pause;
	  reg max, min;
	  Lab4_1 two_digitBCD(.BCD0(BCD0),.BCD1(BCD1),.dir(dir),.en(pause),.reset(reset),.clk(speed));
	  
	  always @(negedge en)
	  begin
			pause=~pause;
	  end
	  
	  always @(posedge speed)
	  begin
	  max=0;
	  min=0;
		if(mode==1)//99
		begin
			if(BCD0==4'd8 && BCD1==4'd9) dir=0;//89
			else if(BCD0==4'd0 && BCD1==4'd9)//90
			begin
				max = 1;
				min = 0;
			end
			else if(BCD0==4'd1 && BCD1==4'd0) dir=1;//01
			else if(BCD0==4'd0 && BCD1==4'd0)
			begin
				max = 0;
				min = 1;
			end
		end
		if(mode==0)//60
		begin
			if(BCD0==4'd0 && BCD1==4'd6)//60
			begin	
				max = 1;
				min = 0;
			end
			else if(BCD0==4'd9 && BCD1==4'd5)dir=0;//59
			else if(BCD0==4'd0 && BCD1==4'd0) //00
			begin
				max = 0;
				min = 1;
			end
			else if(BCD0==4'd1 && BCD1==4'd0)dir=1;//01
			else 
			begin
				max=0;
				min=0;
			end
		end
	  end
endmodule

module mux (speed,select,a,b);
     input a, b, select;
     output reg speed;
	  always@ (select)
	  begin
	  if(select==1) speed=a;
	  else speed=b;
	 end
endmodule

module debounce(pb_debounced, pb, clk);
     output pb_debounced;     // signal of a pushbutton after being debounced
     input pb;      				// signal from a pushbutton
     input clk;
     reg[3:0] shift_reg;      // use shift_regto filter pushbutton bounce

     always@(posedge clk)
          begin
          shift_reg[3:1] <= shift_reg[2:0];
          shift_reg[0] <= pb;
          end
     assign pb_debounced= ((shift_reg== 4'b0000) ? 1'b0 : 1'b1);
endmodule

module clk_divider24(clk_div, clk);
input clk;
output clk_div;
reg[23:0] num;
wire[23:0] next_num;
     always@(posedge clk)
          begin
          num<= next_num;
          end
     assign next_num= num+ 1;
     assign clk_div= num[23];
endmodule

module clk_divider22(clk_div, clk);
input clk;
output clk_div;
reg[21:0] num;
wire[21:0] next_num;
     always@(posedge clk)
          begin
          num<= next_num;
          end
     assign next_num= num+ 1;
     assign clk_div= num[21];
endmodule

module clk_divider15(clk_div, clk);
input clk;
output clk_div;
reg[14:0] num;
wire[14:0] next_num;
     always@(posedge clk)
          begin
          num<= next_num;
          end
     assign next_num= num+ 1;
     assign clk_div= num[14];
endmodule

module sevenSegement(DISPLAY,DIGIT,BCD0,BCD1,clk);
output reg [3:0] DIGIT;
output [7:0] DISPLAY;
input[3:0] BCD0;
input[3:0]BCD1;
input clk;
reg[3:0] value;

	always @ ( posedge clk) 
	begin
		case(DIGIT)
			4'b1110: 
			begin
			value <= BCD1;
			DIGIT <= 4'b1101;
			end
			
			4'b1101: begin
			value <= BCD0;
			DIGIT <= 4'b1110;
			end
			default begin
			DIGIT <= 4'b1110;
			end
			
		endcase
	end
assign DISPLAY = (value==4'd0) ? 8'b00000011 :
	(value==4'd1) ? 8'b10011111 :
	(value==4'd2) ? 8'b00100100 :
	(value==4'd3) ? 8'b00001100 :
	(value==4'd4) ? 8'b10011000 :
	(value==4'd5) ? 8'b01001000 :
	(value==4'd6) ? 8'b01000000 :
	(value==4'd7) ? 8'b00011111 :
	(value==4'd8) ? 8'b00000000 :
	(value==4'd9) ? 8'b00001000 :
	8'b11111111 ;	
endmodule
