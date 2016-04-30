`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:44 03/05/2015 
// Design Name: 
// Module Name:    lab1_1 
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
module lab1_1(a, b, cin, sum, cout);
input a, b, cin;
output sum, cout;
wire t1, t2, t3;

xor(t1, a, b);
xor(sum, t1, cin);
and(t3, t1, cin);
and(t2, a, b);
or(cout, t2, t3);

endmodule
