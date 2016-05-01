`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:53:51 03/12/2015 
// Design Name: 
// Module Name:    Lab2_2 
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
module Lab2_2(A_lt_B,A_gt_B,A_eq_B,
					A3,A2,A1,A0,B3,B2,B1,B0					
    );
input A3,A2,A1,A0,B3,B2,B1,B0	;
output A_lt_B,A_gt_B,A_eq_B;
wire w1,w2,w3,w4,w5,w6,t1,t2,t3,t4,t5,t6,t7,t8;

	 Lab2_1 two_bit_cmp1(.A_gt_B(w1),.A_eq_B(w2),.A_lt_B(w3),.A0(A0),.B0(B0),.A1(A1),.B1(B1));
	 Lab2_1 two_bit_cmp2(.A_gt_B(w4),.A_eq_B(w5),.A_lt_B(w6),.A0(w1),.B0(w3),.A1(A2),.B1(B2));
	xor(t5,w4,w6);
	xor(t6,A3,B3);
	nand(t1,w4,t5);
	nand(t2,w6,t5);
	nand(t3,A3,t6);
	nand(t4,B3,t6);
	or(t7,t1,t6);
	or(t8,t2,t6);
	nand(A_gt_B,t3,t7);
	nand(A_lt_B,t4,t8);
	nor(A_eq_B,t5,t6);
	
endmodule
