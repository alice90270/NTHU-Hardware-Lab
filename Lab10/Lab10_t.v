`timescale 1ns / 1ps
module Lab10_t;
	reg clk, rst_n, cancel, tea, coke, sprite, money_5, money_10, money_50;
	wire drop_tea, drop_coke, drop_sprite;
	wire [3:0] DIGIT;
	wire [7:0] DISPLAY;

Lab10 lab10(clk, rst_n, cancel, tea, coke, sprite, money_5, money_10, money_50, drop_tea, drop_coke, drop_sprite, DIGIT, DISPLAY );
	
	always #1 clk=~clk;	
	initial begin
	$shm_open();
	$shm_probe("ASM");	
end
	
	initial begin
		$monitor($time, "Tea=%b, Coke=%b, Sprite=%b, money=%d",
			drop_tea, drop_coke, drop_sprite, lab10.sum
		);
		clk=0; 
		rst_n=1;
		cancel=1; 
		tea =1;
		coke =1;
		sprite =1;
		money_5=1;
		money_10 =1;
		money_50=1;
		
		#2 rst_n=0;
		#2 rst_n=1;
		#2 money_5=0;
		#2 money_5=1;
		#2 money_10=0;
		#2 money_10=1;
		#50;
		$display("========================Drop tea, No Change.========================");
		#2 tea=0;
		#2 tea=1;
		#500;
		$display("========================================================================\n");
		
		#2 rst_n=0;
		#2 rst_n=1;
		#2 money_5=0;
		#2 money_5=1;
		#2 money_5=0;
		#2 money_5=1;
		#2 money_10=0;
		#2 money_10=1;
		#50;
		$display("========================Drop Coke, No Change.========================");
		#2 coke=0;
		#2 coke=1;
		#500;
		$display("========================================================================\n");
		
		#2 rst_n=0;
		#2 rst_n=1;
		#2 money_10=0;
		#2 money_10=1;
		#2 money_50=0;
		#2 money_50=1;
		#50;
		$display("========================Drop Sprite, 5 Changes.========================");
		#2 sprite=0;
		#2 sprite=1;
		#500;
		$display("========================================================================\n");
		
		#2 rst_n=0;
		#2 rst_n=1;
		#2 money_5=0;
		#2 money_5=1;
		#2 money_5=0;
		#2 money_5=1;
		#2 money_10=0;
		#2 money_10=1;
		#2 money_10=0;
		#2 money_10=1;
		#2 money_10=0;
		#2 money_10=1;
		#2 money_10=0;
		#2 money_10=1;
		#2 money_50=0;
		#2 money_50=1;
		#50;
		$display("========================Cancel, 10 Changes.========================");
		#2 cancel=0;
		#2 cancel=1;
		#500;
		$display("========================================================================\n");
		
		$finish;
		
	end

endmodule