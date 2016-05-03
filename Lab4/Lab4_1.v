`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:54:36 03/26/2015 
// Design Name: 
// Module Name:    Lab4_1 
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
module Lab4_1(BCD0,BCD1,dir,en,reset,clk);
input clk;
input reset;
input en;
input dir;
wire  cout_en;
wire cout;
output [3:0]BCD0;
output [3:0]BCD1;

Lab3_2 one_digitBCD1(.cout(cout_en), .BCD(BCD0), .dir(dir), .en(en), .reset(reset), .clk(clk));
Lab3_2 one_digitBCD2(.cout(cout), .BCD(BCD1), .dir(dir), .en(cout_en), .reset(reset), .clk(clk));

endmodule
