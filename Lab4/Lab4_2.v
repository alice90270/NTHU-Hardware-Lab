`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:23:00 03/26/2015 
// Design Name: 
// Module Name:    Lab4_2 
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
module Lab4_2(DISPLAY,DIGIT,dir,en,reset,clk);
input dir,en,reset,clk;
output [7:0] DISPLAY;
output [3:0] DIGIT;
wire[3:0] BCD0_decoder;
wire[3:0] BCD1_decoder;
wire clk_div23,clk_div15;

clock_divider23(clk_div23,clk);
clock_divider15(clk_div15,clk);

	Lab4_1 two_digitBCD(.BCD0(BCD0_decoder),.BCD1(BCD1_decoder),.dir(dir),.en(en),.reset(reset),.clk(clk_div23));
	sevenSegement segment7(.DISPLAY(DISPLAY),.DIGIT(DIGIT),.BCD0(BCD0_decoder),.BCD1(BCD1_decoder),.clk(clk_div15));

endmodule

module clock_divider15(clk_div, clk);
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

module clock_divider23(clk_div, clk);
input clk;
output clk_div;
reg[22:0] num;
wire[22:0] next_num;
	always@(posedge clk)
		begin
		num<= next_num;
		end
	assign next_num= num+ 1;
	assign clk_div= num[22];
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
