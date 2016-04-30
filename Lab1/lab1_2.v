`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:58 03/05/2015 
// Design Name: 
// Module Name:    lab1_2 
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
module lab1_2(a , b , cin , sum, cout); 
input a, b, cin ; 
output sum , cout;   

assign sum= (a ^ b) ^ cin;
assign cout= ((a ^ b)&& cin ) || (a && b);

endmodule 
