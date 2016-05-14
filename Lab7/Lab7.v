`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:03:53 04/16/2015 
// Design Name: 
// Module Name:    Lab7 
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
module Lab7(ROW, DIGIT, DISPLAY, COLUMN, clk, reset, add, sub );
	input clk, reset, add, sub;
	input [3:0] COLUMN;
	output reg [3:0] ROW, DIGIT;
	output reg [8:0] DISPLAY;
	reg[14:1] DIVIDER;
	wire DB_add, DB_sub, DB_reset;
	reg[3:0] shift_reg,shift_reg1,shift_reg2; // use shift_regto filter pushbutton bounce
	reg[8:0] Result;
	reg[4:0] A,B;
	reg flag;
	reg [3:0] SCAN_CODE;
	reg [3:0] DEBOUNCE_COUNT;
	reg PRESS;
	wire PRESS_VALID;
	
	reg[3:0] DECODE_BCD;
	reg[3:0] ENABLE;
	reg [7:0] SEGMENT;
	reg[15:0] KEY_BUFFER;
	reg[3:0] KEY_CODE;

/***********************
* Clock Divider*
***********************/
	always@(posedge clk or negedge reset)
	begin
		if(!reset)
		DIVIDER <= {12'h000,2'b00};
		else
		DIVIDER <= DIVIDER + 1;
	end
	assign clk_15 = DIVIDER[14];
	
/********************
* Debounce Circuit *
********************/
	always@( clk_15 or  add)
	begin
	shift_reg[3:1] <= shift_reg[2:0];
	shift_reg[0] <= DB_add;
	end
	assign DB_add = ((shift_reg== 4'b0000) ? 1'b0 : 1'b1);
	
	always@( clk_15 or  sub)
	begin
	shift_reg1[3:1] <= shift_reg1[2:0];
	shift_reg1[0] <= DB_sub;
	end
	assign DB_sub = ((shift_reg1== 4'b0000) ? 1'b0 : 1'b1);
	
	always@( clk_15 or  reset)
	begin
	shift_reg2[3:1] <= shift_reg2[2:0];
	shift_reg2[0] <= DB_reset;
	end
	assign DB_reset = ((shift_reg2== 4'b0000) ? 1'b0 : 1'b1);	
	
	
/********************
* Adder & Subtracter *
********************/
	always@(DB_add or DB_sub or DB_reset)
	begin
		if(DB_add==1)
		begin
		flag=1;
		Result <= A+B;
		end
		
		else if(DB_sub==1)
			begin
			flag=2;
			Result <= A-B;
			end
		else if(DB_reset==1)	
			begin
				A <=4'b0000;
				B <=-4'b0000;
				flag=0;
			end
		else flag=0;
	end
	

/********************
* Keyboard *
********************/
	/***************************
	* Scanning Code Generator *
	***************************/
		always@(posedge clk or negedge DB_reset)
		begin
			if(!DB_reset)
			SCAN_CODE <= 4'h0;
			else if(PRESS)
			SCAN_CODE <= SCAN_CODE + 1;
		end

	/*********************
	* Scanning Keyboard *
	*********************/
		always@(SCAN_CODE,COLUMN)
		begin
			case(SCAN_CODE[3:2])
			2'b00 : ROW = 4'b1110;
			2'b01 : ROW = 4'b1101;
			2'b10 : ROW = 4'b1011;
			2'b11 : ROW = 4'b0111;
			endcase
			case(SCAN_CODE[1:0])
			2'b00 : PRESS = COLUMN[0];
			2'b01 : PRESS = COLUMN[1];
			2'b10 : PRESS = COLUMN[2];
			2'b11 : PRESS = COLUMN[3];
			endcase
		end
	/********************
	* Debounce Circuit *
	********************/
		always@(posedge clk_15 or negedge DB_reset)
		begin
			if(!DB_reset)
			DEBOUNCE_COUNT <= 4'h0;
			else if(PRESS)
			DEBOUNCE_COUNT <= 4'h0;
			else if(DEBOUNCE_COUNT <= 4'hE)
			DEBOUNCE_COUNT <= DEBOUNCE_COUNT + 1;
		end
		assign PRESS_VALID = (DEBOUNCE_COUNT == 4'hD) ?1'b1 : 1'b0;
	/*********************************
	* Fetch Key Code * Shift Buffer *
	**********************************/
		always@(negedge clk_15 or negedge DB_reset)
		begin
			if(!DB_reset)
			begin
				KEY_CODE <= 4'hC;	//show 0000
				KEY_BUFFER <= 16'h0000;
			end
			else if(PRESS_VALID)
			begin
				KEY_CODE <= SCAN_CODE;
				KEY_BUFFER[15:4] <= KEY_BUFFER[11:0];
				
				case(SCAN_CODE)
					4'hC : KEY_BUFFER[3:0] <= 4'h0; // 0
					4'hD : KEY_BUFFER[3:0] <= 4'h1; // 1
					4'h9 : KEY_BUFFER[3:0] <= 4'h2; // 2
					4'h5 : KEY_BUFFER[3:0] <= 4'h3; // 3
					4'hE : KEY_BUFFER[3:0] <= 4'h4; // 4
					4'hA : KEY_BUFFER[3:0] <= 4'h5; // 5
					4'h6 : KEY_BUFFER[3:0] <= 4'h6; // 6
					4'hF : KEY_BUFFER[3:0] <= 4'h7; // 7
					4'hB : KEY_BUFFER[3:0] <= 4'h8; // 8 -8
					4'h7 : KEY_BUFFER[3:0] <= 4'h9; // 9 -7
					4'h8 : KEY_BUFFER[3:0] <= 4'hA; // A -6
					4'h4 : KEY_BUFFER[3:0] <= 4'hB; // B -5
					4'h3 : KEY_BUFFER[3:0] <= 4'hC; // C -4
					4'h2 : KEY_BUFFER[3:0] <= 4'hD; // D -3
					4'h1 : KEY_BUFFER[3:0] <= 4'hE; // E -2
					4'h0 : KEY_BUFFER[3:0] <= 4'hF; // F -1
				endcase
				
				if(flag==0)
					begin
					A[3:0] <= 4'h0;
					B[3:0] <= 4'h0;
					Result <= 8'h00;
					end
				else if(flag==1)
					begin
					A[3:0] <= KEY_BUFFER[3:0];
					flag=flag+1;
					end
				else if(flag==2)
					begin
					B[3:0] <= KEY_BUFFER[3:0];
					flag=flag+1;
					end
			end		
		end
		
	/***************************
	* Enable Display Location *
	***************************/
		always@(negedge clk_15 or negedge DB_reset)
		begin
			if (!DB_reset)
			ENABLE <= 4'b0000;
			else
			begin
			 case(ENABLE)
				4'b0000: ENABLE<=4'b1110;
				default: ENABLE<={ENABLE[2],ENABLE[1],ENABLE[0],ENABLE[3]};
			 endcase
			end
		end
	/****************************
	* Data Display Multiplexer*
	****************************/
		always@(ENABLE or A or B or Result) 
		begin
			case(ENABLE)
				4'b1110:DECODE_BCD = Result[3:0];
				4'b1101:DECODE_BCD = Result[7:4];
				4'b1011:DECODE_BCD = B[3:0];
				4'b0111:DECODE_BCD = A[3:0];
			endcase
		end
	/********************************
	* Hex To Seven Segment Decoder *
	********************************/
		always@(DECODE_BCD)
		begin
				case(DECODE_BCD)
					4'h0 : SEGMENT = 9'b100000011;//0
					4'h1 : SEGMENT = 9'b110011111;//1
					4'h2 : SEGMENT = 9'b100100100;//2
					4'h3 : SEGMENT = 9'b100001100;//3
					4'h4 : SEGMENT = 9'b110011000;//4
					4'h5 : SEGMENT = 9'b101001000;//5
					4'h6 : SEGMENT = 9'b101000000;//6
					4'h7 : SEGMENT = 9'b100011111;//7
					4'h8 : SEGMENT = 9'b000000000;//8
					4'h9 : SEGMENT = 9'b000011000;//9
					4'hA : SEGMENT = 9'b000010000;//A
					4'hB : SEGMENT = 9'b011000000;//B
					4'hC : SEGMENT = 9'b001100011;//C
					4'hD : SEGMENT = 9'b010000100;//D
					4'hE : SEGMENT = 9'b001100000;//E
					4'hF : SEGMENT = 9'b001110000;//F
				endcase
		end

endmodule

