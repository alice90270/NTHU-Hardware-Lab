`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:45:50 04/06/2012 
// Design Name: 
// Module Name:    state_ctrl 
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

module state_ctrl(state, start, pause, clk, reset);

	input start; //start or stop
	input pause;
	input clk;
	input reset;
	output [1:0] state;
	
	reg [1:0] state, next_state;
	
	parameter INIT = 2'b00;
	parameter RUN = 2'b01;
	parameter PAUSE = 2'b10;
	
	always @(posedge clk or negedge reset) begin
		if(!reset) begin
			state <= INIT;
		end
		else begin
			state <= next_state;
		end
	end
	
	always @(*) begin
		case(state)
			INIT:
				if(start==0)
					next_state = RUN;
				else
					next_state = state;
			RUN:
				if(start==0)
					next_state = INIT;
				else if(pause==0)
					next_state = PAUSE;
				else
					next_state = state;
			PAUSE:
				if(start==0)
					next_state = RUN;
				else if(pause==0)
					next_state = PAUSE;
				else
					next_state = state;
			default:
				next_state = INIT;
		endcase
	end

endmodule
