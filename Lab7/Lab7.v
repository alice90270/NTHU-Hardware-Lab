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
	reg [3:0] SCAN_CODE;
	reg [3:0] DEBOUNCE_COUNT;
	reg PRESS;
	wire PRESS_VALID;
	reg [3:0]add_count,sub_count,reset_count;
	reg[3:0] DECODE_BCD;
	reg[15:0] KEY_BUFFER;
	reg[3:0] KEY_CODE;
	reg[1:0] state;
	reg[7:0]result;

/***********************
* Clock Divider*
***********************/
	always@(posedge clk)
	begin
		/*if(!reset)
		DIVIDER <= {12'h000,2'b00};
		else*/
		DIVIDER <= DIVIDER + 1;
	end
	assign clk_15 = DIVIDER[14];
	
/********************
* Debounce Add Sub Circuit *
********************/
	always@(posedge clk_15)
		begin
		if(!reset)
		add_count <= 4'h0;
		else if(add)
		add_count <= 4'h0;
		else if(add_count <= 4'hE)
		add_count <= add_count + 1;
		end
		assign DB_add = (add_count == 4'hD) ?1'b1 : 1'b0;
	
	always@(posedge clk_15)
		begin
		if(!reset)
		sub_count <= 4'h0;
		else if(sub)
		sub_count <= 4'h0;
		else if(sub_count <= 4'hE)
		sub_count <= sub_count + 1;
		end
		assign DB_sub = (sub_count == 4'hD) ?1'b1 : 1'b0;
		
	always@(posedge clk_15)
		begin
		if(reset)
		reset_count <= 4'h0;
		else if(reset_count <= 4'hE)
		reset_count <= reset_count + 1;
		end
		assign DB_reset = (reset_count == 4'hD) ?1'b1 : 1'b0;
	

/********************
* State *
********************/
	always @(posedge clk_15 or posedge DB_reset)
	begin
		if(DB_reset) 
			state<= 2'b00;
		else
			begin
			case(state)
				2'b00:	
					begin
						if(PRESS_VALID)	state <= 2'b01;
						else 			state <= 2'b00;
					end
				2'b01:
					begin
						if(PRESS_VALID)	state <= 2'b10;
						else 			state <= 2'b01;
					end
				2'b10:
					begin
						if(DB_reset)	state <= 2'b00;
						else 			state <= 2'b10;
					end
				default:state<= 2'b00;
			endcase
			end
	end

/********************
* Keyboard *
********************/
	/***************************
	* Scanning Code Generator *
	***************************/
		always@(posedge clk or posedge DB_reset)
		begin
			if(DB_reset)
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
		always@(posedge clk_15 or posedge DB_reset)
		begin
			if(DB_reset)
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
		always@(negedge clk_15 or posedge DB_reset)
		begin
			if(DB_reset)
			begin
				KEY_CODE <= 4'hC;	//show 0000
				KEY_BUFFER <= 16'h0000;
			end
			else begin
				case(state)
					2'b00:	
						begin
						KEY_BUFFER[7:0] <= 8'b00000000;
							if(PRESS_VALID)	
								begin
									case(SCAN_CODE)
										4'hC : KEY_BUFFER[15:12] <= 4'h0; // 0
										4'hD : KEY_BUFFER[15:12] <= 4'h1; // 1
										4'h9 : KEY_BUFFER[15:12] <= 4'h2; // 2
										4'h5 : KEY_BUFFER[15:12] <= 4'h3; // 3
										4'hE : KEY_BUFFER[15:12] <= 4'h4; // 4
										4'hA : KEY_BUFFER[15:12] <= 4'h5; // 5
										4'h6 : KEY_BUFFER[15:12] <= 4'h6; // 6
										4'hF : KEY_BUFFER[15:12] <= 4'h7; // 7
										4'hB : KEY_BUFFER[15:12] <= 4'h8; // 8 -8 
										4'h7 : KEY_BUFFER[15:12] <= 4'h9; // 9 -7
										4'h8 : KEY_BUFFER[15:12] <= 4'hA; // A -6
										4'h4 : KEY_BUFFER[15:12] <= 4'hB; // B -5
										4'h3 : KEY_BUFFER[15:12] <= 4'hC; // C -4
										4'h2 : KEY_BUFFER[15:12] <= 4'hD; // D -3
										4'h1 : KEY_BUFFER[15:12] <= 4'hE; // E -2
										4'h0 : KEY_BUFFER[15:12] <= 4'hF; // F -1
									endcase
									
								end
							else 	KEY_BUFFER[15:12] <= 4'h0;
						end
					2'b01:
						begin
						KEY_BUFFER[7:0] <= 8'b00000000;
							if(PRESS_VALID)	
								begin
									case(SCAN_CODE)
										4'hC : KEY_BUFFER[11:8] <= 4'h0; // 0
										4'hD : KEY_BUFFER[11:8] <= 4'h1; // 1
										4'h9 : KEY_BUFFER[11:8] <= 4'h2; // 2
										4'h5 : KEY_BUFFER[11:8] <= 4'h3; // 3
										4'hE : KEY_BUFFER[11:8] <= 4'h4; // 4
										4'hA : KEY_BUFFER[11:8] <= 4'h5; // 5
										4'h6 : KEY_BUFFER[11:8] <= 4'h6; // 6
										4'hF : KEY_BUFFER[11:8] <= 4'h7; // 7
										4'hB : KEY_BUFFER[11:8] <= 4'h8; // 8 -8 
										4'h7 : KEY_BUFFER[11:8] <= 4'h9; // 9 -7
										4'h8 : KEY_BUFFER[11:8] <= 4'hA; // A -6
										4'h4 : KEY_BUFFER[11:8] <= 4'hB; // B -5
										4'h3 : KEY_BUFFER[11:8] <= 4'hC; // C -4
										4'h2 : KEY_BUFFER[11:8] <= 4'hD; // D -3
										4'h1 : KEY_BUFFER[11:8] <= 4'hE; // E -2
										4'h0 : KEY_BUFFER[11:8] <= 4'hF; // F -1
									endcase
								end
							else 	KEY_BUFFER[11:8] <= 4'h0;
						end
					2'b10:
						begin
							if(DB_add)	
								begin
									KEY_BUFFER[7:0] <= $signed(KEY_BUFFER[15:12])+$signed(KEY_BUFFER[11:8]);
								end
							else if(DB_sub)
								begin
									KEY_BUFFER[7:0] <= $signed(KEY_BUFFER[15:12])-$signed(KEY_BUFFER[11:8]);
								end
							else 	KEY_BUFFER[7:0] <= KEY_BUFFER[7:0];
						end
					default:	KEY_BUFFER[7:0] <= 8'b00000000;
				endcase
			end
		end
		
	/***************************
	* DIGIT Display Location *
	***************************/
		always@(negedge clk_15 or posedge DB_reset)
		begin
			if (DB_reset)
			DIGIT <= 4'b0000;
			else
			begin
			 case(DIGIT)
				4'b0000: DIGIT<=4'b1110;
				default: DIGIT<={DIGIT[2],DIGIT[1],DIGIT[0],DIGIT[3]};
			 endcase
			end
		end
	/****************************
	* Data Display Multiplexer*
	****************************/
		always@(DIGIT or KEY_BUFFER) 
		begin
			if(KEY_BUFFER[7])
				begin
				result = ~(KEY_BUFFER[7:0]-1);
				end
			else				result = KEY_BUFFER[7:0];
			case(DIGIT)
				4'b1011:DECODE_BCD = KEY_BUFFER[11:8];	//B
				4'b0111:DECODE_BCD = KEY_BUFFER[15:12];	//A
				//result
				4'b1101:
					if(result >= 8'd10)	DECODE_BCD = 4'b0001;
					else				DECODE_BCD = 4'b0000;
				4'b1110:
					if(result >= 8'd10)	DECODE_BCD = result-8'd10;
					else 				DECODE_BCD = result;
			endcase
		end
	/********************************
	* Hex To Seven DISPLAY Decoder *
	********************************/
		always@(DECODE_BCD)
		begin
			if(DIGIT==4'b1110)
				begin
				case(DECODE_BCD)
					4'h0 : DISPLAY[7:0] = 8'b00000011;//0
					4'h1 : DISPLAY[7:0] = 8'b10011111;//1
					4'h2 : DISPLAY[7:0] = 8'b00100100;//2
					4'h3 : DISPLAY[7:0] = 8'b00001100;//3
					4'h4 : DISPLAY[7:0] = 8'b10011000;//4
					4'h5 : DISPLAY[7:0] = 8'b01001000;//5
					4'h6 : DISPLAY[7:0] = 8'b01000000;//6
					4'h7 : DISPLAY[7:0] = 8'b00011111;//7
					4'h8 : DISPLAY[7:0] = 8'b00000000;//8
					4'h9 : DISPLAY[7:0] = 8'b00011000;//9
					default: DISPLAY[7:0] = 8'b00000011;
				endcase
				if(KEY_BUFFER[7])	DISPLAY[8]=1'b0;
				else				DISPLAY[8]=1'b1;
				end
			else
				begin
				case(DECODE_BCD)
					4'h0 : DISPLAY = 9'b100000011;//0
					4'h1 : DISPLAY = 9'b110011111;//1
					4'h2 : DISPLAY = 9'b100100100;//2
					4'h3 : DISPLAY = 9'b100001100;//3
					4'h4 : DISPLAY = 9'b110011000;//4
					4'h5 : DISPLAY = 9'b101001000;//5
					4'h6 : DISPLAY = 9'b101000000;//6
					4'h7 : DISPLAY = 9'b100011111;//7
					4'h8 : DISPLAY = 9'b000000000;//8
					4'h9 : DISPLAY = 9'b000011111;//9
					4'hA : DISPLAY = 9'b001000000;//A
					4'hB : DISPLAY = 9'b001001000;//B
					4'hC : DISPLAY = 9'b010011000;//C
					4'hD : DISPLAY = 9'b000001100;//D
					4'hE : DISPLAY = 9'b000100100;//E
					4'hF : DISPLAY = 9'b010011111;//F
				endcase
				end
		end
		
endmodule

		
