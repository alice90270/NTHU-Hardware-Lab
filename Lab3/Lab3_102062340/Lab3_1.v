`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:41:38 03/19/2015 
// Design Name: 
// Module Name:    Lab3_1 
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
module Lab3_1(cout, outputs,inputs,en,dir);
input en;
input dir;
input [3:0]inputs;
output [3:0]outputs;
output cout;
reg[3:0] outputs;
reg cout;


	always@(inputs or en or dir)
	begin
	if(en==0)
		begin
		outputs=inputs;
		cout=0;
		end
		
	else 
		begin
		if(dir==1)	//count up
			begin
			if(inputs>=4'b1001) 
				begin
				if(inputs==4'b1001) cout=1;
				else	cout=0;
				outputs=4'b0000;
				end
			else
				begin
				outputs=inputs+1;
				cout=0;
				end
			end
			
			
		if(dir==0)	//cout down
			begin
			if(inputs==4'b0000) 
				begin
				cout=1;
				outputs=4'b1001;
				end
			else if(inputs>4'b1001) 
				begin
				cout=0;
				outputs=4'b0000;
				end
			else
				begin
				outputs=inputs-1;
				cout=0;
				end
			end
		end
	end
endmodule
