`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:53:29 03/12/2015 
// Design Name: 
// Module Name:    Lab2_1 
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
module Lab2_1(A_lt_B,A_gt_B,A_eq_B,
					A1,A0,B1,B0);
	input A1,A0,B1,B0;
	output A_lt_B,A_gt_B,A_eq_B;
	wire t1,t2,t3,t4,t5,t6,t7,t8;
	
	xor(t5,A0,B0);
	xor(t6,A1,B1);
	nand(t1,A0,t5);
	nand(t2,B0,t5);
	nand(t3,A1,t6);
	nand(t4,B1,t6);
	or(t7,t1,t6);
	or(t8,t2,t6);
	nand(A_gt_B,t3,t7);
	nand(A_lt_B,t4,t8);
	nor(A_eq_B,t5,t6);
	

endmodule
