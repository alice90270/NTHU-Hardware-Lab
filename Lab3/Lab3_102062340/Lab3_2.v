`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:41:53 03/19/2015 
// Design Name: 
// Module Name:    Lab3_2 
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
module Lab3_2(cout, BCD, dir, en, reset, clk );
input en, dir, reset, clk;
output reg[3:0] BCD;
output cout;
wire[3:0] outputs;


Lab3_1 counter(.cout(cout), .outputs(outputs),.inputs(BCD),.en(en),.dir(dir));

always@ (posedge clk or negedge reset)
begin
	if(reset==0) BCD=0;
	else BCD=outputs;
end

endmodule

