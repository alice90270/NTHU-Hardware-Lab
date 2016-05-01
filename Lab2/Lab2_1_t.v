`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:14:14 03/06/2011 
// Design Name: 
// Module Name:    Lab2_b_t 
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


module Lab2_1_t;

	reg [1:0] A, B;
	wire A_lt_B, A_gt_B, A_eq_B;
	reg pass;
	
	Lab2_1 U1(.A1(A[1]), .A0(A[0]), .B1(B[1]), .B0(B[0]), .A_lt_B(A_lt_B), .A_gt_B(A_gt_B), .A_eq_B(A_eq_B));
	
	initial begin
		#0 pass = 1'b1; A = 2'b00; B = 2'b00;
		$display("Starting simulation");
		$monitor("%g\t A1A0=%b\t B1B0=%b\t A_lt_B=%b\t A_gt_B=%b\t A_eq_B=%b", $time, A, B, A_lt_B, A_gt_B, A_eq_B);
		#80 $display("%g Terminating simulation", $time);
		if(pass === 1'b1)
			$display("[PASS]");
		$finish;
	end
	
	always #20 A = A + 1;
	always #5 B = B + 1;
	
	always @(A or B) begin
		#0	if({A_lt_B, A_gt_B, A_eq_B} != {A<B,A>B,A==B})
			printerror;
	end
	
	task printerror;
		begin
			pass = 1'b0;
			$display("Error:\t A1A0=%b\t B1B0=%b\t A_lt_B=%b\t A_gt_B=%b\t A_eq_B=%b", A, B, A_lt_B, A_gt_B, A_eq_B);
		end
	endtask
	
endmodule
