`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:48:13 03/05/2015 
// Design Name: 
// Module Name:    lab1_3 
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
module lab1_3(a , b , cin , sum, cout);
   
input a, b, c , cin ; 
output sum , cout;
reg sum, cout;   
wire t1, t2, t3;

	always @(a or b or cin)
	begin
		t1= a ^ b;
		sum= t1 ^ cin;
		t3= t1 && cin;
		t2= a && b;
		out= t1 || t2;
	end

endmodule
