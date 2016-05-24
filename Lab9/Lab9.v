module Lab9(CLK, RESET, LCD_ENABLE, LCD_RW, LCD_DI, LCD_CS1, LCD_CS2, LCD_RST,LCD_DATA);
	input CLK;
	input RESET;
	output LCD_ENABLE;
	output LCD_RW;
	output LCD_DI;
	output LCD_CS1;
	output LCD_CS2;
	output LCD_RST;
	output[7:0] LCD_DATA;
	reg[7:0] LCD_DATA;
	reg[7:0] UPPER_PATTERN;
	reg[7:0] LOWER_PATTERN;
	reg[1:0] LCD_SEL;
	reg[2:0] STATE;
	reg[2:0] X_PAGE;
	reg[8:1] DIVIDER;
	reg[1:0] DELAY;
	reg[7:0] INDEX, INDEX_DATA;
	reg[1:0] ENABLE;
	reg CLEAR;
	reg LCD_RW;
	reg LCD_DI;
	reg LCD_RST;
	wire LCD_CLK;
	reg LCD_CS1;
	reg LCD_CS2;
	wire LCD_ENABLE;
	reg[5:0] start;
	reg[20:0] slow;
	
	reg [1:0] counter;
	reg [7:0] shift_count;
	reg [2:0] addr_X;
	
	parameter RST = 3'd0;
	parameter ON = 3'd1;
	parameter SETZ = 3'd2;
	parameter SETY = 3'd3;
	parameter SETX = 3'd4;
	parameter WRITE_BLANK = 3'd5;
	parameter WRITE_WORDS = 3'd6;
	
	/***********************
	* Clock Divider *
	***********************/
	always@(posedge CLK or negedge RESET)
	begin
	if(!RESET)
	DIVIDER <= 8'h00;
	else
	DIVIDER <= DIVIDER + 1;
	end
	assign LCD_CLK = DIVIDER[8];
	
	/***********************
	* Display Patterns *
	***********************/
	always@(INDEX_DATA)
	begin
		case(INDEX_DATA)
		8'h00 : UPPER_PATTERN = 8'h08; // H
		8'h01 : UPPER_PATTERN = 8'hF8;
		8'h02 : UPPER_PATTERN = 8'hF8;
		8'h03 : UPPER_PATTERN = 8'h88;
		8'h04 : UPPER_PATTERN = 8'h80;
		8'h05 : UPPER_PATTERN = 8'h80;
		8'h06 : UPPER_PATTERN = 8'h88;
		8'h07 : UPPER_PATTERN = 8'hF8;
		8'h08 : UPPER_PATTERN = 8'hF8;
		8'h09 : UPPER_PATTERN = 8'h08; // E
		8'h0A : UPPER_PATTERN = 8'h08;
		8'h0B : UPPER_PATTERN = 8'hF8;
		8'h0C : UPPER_PATTERN = 8'hF8;
		8'h0D : UPPER_PATTERN = 8'h88;
		8'h0E : UPPER_PATTERN = 8'hC8;
		8'h0F : UPPER_PATTERN = 8'h18;
		8'h10 : UPPER_PATTERN = 8'h38;
		8'h11 : UPPER_PATTERN = 8'h08; // L
		8'h12 : UPPER_PATTERN = 8'hF8;
		8'h13 : UPPER_PATTERN = 8'hF8;
		8'h14 : UPPER_PATTERN = 8'h08;
		8'h15 : UPPER_PATTERN = 8'h00;
		8'h16 : UPPER_PATTERN = 8'h00;
		8'h17 : UPPER_PATTERN = 8'h00;
		8'h18 : UPPER_PATTERN = 8'h00;
		8'h19 : UPPER_PATTERN = 8'h08; // L
		8'h1A : UPPER_PATTERN = 8'hF8;
		8'h1B : UPPER_PATTERN = 8'hF8;
		8'h1C : UPPER_PATTERN = 8'h08;
		8'h1D : UPPER_PATTERN = 8'h00;
		8'h1E : UPPER_PATTERN = 8'h00;
		8'h1F : UPPER_PATTERN = 8'h00;
		8'h20 : UPPER_PATTERN = 8'h00;
		8'h21 : UPPER_PATTERN = 8'hE0; // O
		8'h22 : UPPER_PATTERN = 8'hF0;
		8'h23 : UPPER_PATTERN = 8'h18;
		8'h24 : UPPER_PATTERN = 8'h08;
		8'h25 : UPPER_PATTERN = 8'h08;
		8'h26 : UPPER_PATTERN = 8'h18;
		8'h27 : UPPER_PATTERN = 8'hF0;
		8'h28 : UPPER_PATTERN = 8'hE0;
		8'h29 : UPPER_PATTERN = 8'h00; //SPACE
		8'h2A : UPPER_PATTERN = 8'h00;
		8'h2B : UPPER_PATTERN = 8'h00;
		8'h2C : UPPER_PATTERN = 8'h00;
		8'h2D : UPPER_PATTERN = 8'h00;
		8'h2E : UPPER_PATTERN = 8'h00;
		8'h2F : UPPER_PATTERN = 8'h00;
		8'h30 : UPPER_PATTERN = 8'h00;
		8'h31 : UPPER_PATTERN = 8'h08; // L
		8'h32 : UPPER_PATTERN = 8'hF8;
		8'h33 : UPPER_PATTERN = 8'hF8;
		8'h34 : UPPER_PATTERN = 8'h08;
		8'h35 : UPPER_PATTERN = 8'h00;
		8'h36 : UPPER_PATTERN = 8'h00;
		8'h37 : UPPER_PATTERN = 8'h00;
		8'h38 : UPPER_PATTERN = 8'h00;
		8'h39 : UPPER_PATTERN = 8'h00; // C
		8'h3A : UPPER_PATTERN = 8'hE0;
		8'h3B : UPPER_PATTERN = 8'hF0;
		8'h3C : UPPER_PATTERN = 8'h18;
		8'h3D : UPPER_PATTERN = 8'h08;
		8'h3E : UPPER_PATTERN = 8'h08;
		8'h3F : UPPER_PATTERN = 8'h18;
		8'h40 : UPPER_PATTERN = 8'h30;
		8'h41 : UPPER_PATTERN = 8'h08; // D
		8'h42 : UPPER_PATTERN = 8'hF8;
		8'h43 : UPPER_PATTERN = 8'hF8;
		8'h44 : UPPER_PATTERN = 8'h08;
		8'h45 : UPPER_PATTERN = 8'h18;
		8'h46 : UPPER_PATTERN = 8'hF0;
		8'h47 : UPPER_PATTERN = 8'hE0;
		8'h48 : UPPER_PATTERN = 8'h00;
		8'h49 : UPPER_PATTERN = 8'h00; // !
		endcase
	end

	always@(INDEX_DATA)
	begin
		case(INDEX_DATA)
		8'h00 : LOWER_PATTERN = 8'h08; // H
		8'h01 : LOWER_PATTERN = 8'h0F;
		8'h02 : LOWER_PATTERN = 8'h0F;
		8'h03 : LOWER_PATTERN = 8'h08;
		8'h04 : LOWER_PATTERN = 8'h00;
		8'h05 : LOWER_PATTERN = 8'h00;
		8'h06 : LOWER_PATTERN = 8'h08;
		8'h07 : LOWER_PATTERN = 8'h0F;
		8'h08 : LOWER_PATTERN = 8'h0F;
		8'h09 : LOWER_PATTERN = 8'h08; // E
		8'h0A : LOWER_PATTERN = 8'h08;
		8'h0B : LOWER_PATTERN = 8'h0F;
		8'h0C : LOWER_PATTERN = 8'h0F;
		8'h0D : LOWER_PATTERN = 8'h08;
		8'h0E : LOWER_PATTERN = 8'h09;
		8'h0F : LOWER_PATTERN = 8'h0C;
		8'h10 : LOWER_PATTERN = 8'h0E;
		8'h11 : LOWER_PATTERN = 8'h08; // L
		8'h12 : LOWER_PATTERN = 8'h0F;
		8'h13 : LOWER_PATTERN = 8'h0F;
		8'h14 : LOWER_PATTERN = 8'h08;
		8'h15 : LOWER_PATTERN = 8'h08;
		8'h16 : LOWER_PATTERN = 8'h08;
		8'h17 : LOWER_PATTERN = 8'h08;
		8'h18 : LOWER_PATTERN = 8'h0C;
		8'h19 : LOWER_PATTERN = 8'h08; // L
		8'h1A : LOWER_PATTERN = 8'h0F;
		8'h1B : LOWER_PATTERN = 8'h0F;
		8'h1C : LOWER_PATTERN = 8'h08;
		8'h1D : LOWER_PATTERN = 8'h08;
		8'h1E : LOWER_PATTERN = 8'h08;
		8'h1F : LOWER_PATTERN = 8'h08;
		8'h20 : LOWER_PATTERN = 8'h0C;
		8'h21 : LOWER_PATTERN = 8'h03; // O
		8'h22 : LOWER_PATTERN = 8'h07;
		8'h23 : LOWER_PATTERN = 8'h0C;
		8'h24 : LOWER_PATTERN = 8'h08;
		8'h25 : LOWER_PATTERN = 8'h08;
		8'h26 : LOWER_PATTERN = 8'h0C;
		8'h27 : LOWER_PATTERN = 8'h07;
		8'h28 : LOWER_PATTERN = 8'h03;	
		8'h29 : LOWER_PATTERN = 8'h00; // SPACE
		8'h2A : LOWER_PATTERN = 8'h00;
		8'h2B : LOWER_PATTERN = 8'h00;
		8'h2C : LOWER_PATTERN = 8'h00;
		8'h2D : LOWER_PATTERN = 8'h00;
		8'h2E : LOWER_PATTERN = 8'h00;
		8'h2F : LOWER_PATTERN = 8'h00;
		8'h30 : LOWER_PATTERN = 8'h00;
		8'h31 : LOWER_PATTERN = 8'h08; // L
		8'h32 : LOWER_PATTERN = 8'h0F;
		8'h33 : LOWER_PATTERN = 8'h0F;
		8'h34 : LOWER_PATTERN = 8'h08;
		8'h35 : LOWER_PATTERN = 8'h08;
		8'h36 : LOWER_PATTERN = 8'h08;
		8'h37 : LOWER_PATTERN = 8'h08;
		8'h38 : LOWER_PATTERN = 8'h0C;
		8'h39 : LOWER_PATTERN = 8'h00; // C
		8'h3A : LOWER_PATTERN = 8'h03;
		8'h3B : LOWER_PATTERN = 8'h07;
		8'h3C : LOWER_PATTERN = 8'h0C;
		8'h3D : LOWER_PATTERN = 8'h08;
		8'h3E : LOWER_PATTERN = 8'h08;
		8'h3F : LOWER_PATTERN = 8'h0C;
		8'h40 : LOWER_PATTERN = 8'h06;
		8'h41 : LOWER_PATTERN = 8'h08; // D
		8'h42 : LOWER_PATTERN = 8'h0F;
		8'h43 : LOWER_PATTERN = 8'h0F;
		8'h44 : LOWER_PATTERN = 8'h08;
		8'h45 : LOWER_PATTERN = 8'h0C;
		8'h46 : LOWER_PATTERN = 8'h07;
		8'h47 : LOWER_PATTERN = 8'h03;
		8'h48 : LOWER_PATTERN = 8'h00;
		8'h49 : LOWER_PATTERN = 8'h00; // !
		endcase
	end
	/******************************
	* Initialize and Write LCD Data *
	******************************/
	assign LCD_ENABLE = (counter == 2'd1) ? 1 : 0;
	
	
	always@(negedge LCD_CLK or negedge RESET)begin
		if(!RESET)
			counter <= 2'b0;
		else
			counter <= counter + 1;
	end
	
	always@(negedge LCD_CLK or negedge RESET)begin
		if(!RESET)begin
			INDEX <= 8'b0;
		end
		else begin
			if(counter == 2'd3) begin
				if(STATE == WRITE_BLANK)
					if(addr_X == 3'd3 || addr_X == 3'd4)
						INDEX <= (INDEX == 8'd127) ? 8'b0 : INDEX + 1;
					else
						INDEX <= (INDEX == 8'd63) ? 8'b0 : INDEX + 1;
				else if(STATE == WRITE_WORDS)
					INDEX <= (INDEX == 8'd127) ? 8'b0 : INDEX + 1;
				else
					INDEX <= 8'b0;
			end
		end
	end
	
	always@(negedge LCD_CLK or negedge RESET)begin
		if(!RESET)begin
			STATE <= RST;
			addr_X <= 0;
			shift_count <= 8'd127;
			INDEX_DATA <= 8'd0;
		end
		else begin
			case(STATE)
			RST: begin
				INDEX_DATA <= 8'd0;
				addr_X <= 0;
				if(counter == 2'd3)
					STATE <= ON;
			end
			ON: begin
				INDEX_DATA <= 8'd0;
				addr_X <= 0;
				if(counter == 2'd3)
					STATE <= SETZ;
			end
			SETZ: begin
				INDEX_DATA <= 8'd0;
				addr_X <= 0;
				if(counter == 2'd3)
					STATE <= SETY;
			end
			SETY: begin
				INDEX_DATA <= 8'd0;
				addr_X <= 0;
				if(counter == 2'd3)
					STATE <= SETX;
			end
			SETX: begin
				if(counter == 2'd3)
					if(shift_count < 8'd183 || (addr_X != 3'd3 && addr_X != 3'd4) ) begin
						STATE <= WRITE_BLANK;
						INDEX_DATA <= 8'd0;
						end
					else begin
						STATE <= WRITE_WORDS;
						INDEX_DATA <= ~shift_count + 1;
					end
			end
			WRITE_BLANK: begin
				INDEX_DATA <= 8'd0;
				if(counter == 2'd3) begin
					if(addr_X == 3'd3) begin
						if(INDEX == 8'd127) begin
							STATE <= SETX;
							addr_X <= addr_X +  1;
						end
						else if(INDEX == shift_count) begin
							STATE <= WRITE_WORDS;
						end
					end
					else if(addr_X == 3'd4) begin
						if(INDEX == 8'd127) begin
							STATE <= SETX;
							addr_X <= addr_X +  1;
							if(shift_count== 8'd183) 
								shift_count <= 8'd127;
							else	
								shift_count <= shift_count-1;
						end
						else if(INDEX == shift_count) begin
							STATE <= WRITE_WORDS;
						end
					end
					
					else begin
						if(INDEX == 8'd63) begin
							STATE <= SETX;
							addr_X <= (addr_X == 3'd7) ? 3'd0 : addr_X +  1;
						end
					end
				end
			end

			WRITE_WORDS: begin
				if(counter == 2'd3) begin
					if(addr_X == 3'd3) begin
						if(INDEX == 8'd127) begin
							STATE <= SETX;
							addr_X <= addr_X +  1;
						end
						else if(INDEX_DATA == 8'h49) begin
							STATE <= WRITE_BLANK;
						end
						else INDEX_DATA <= INDEX_DATA+1;
					end
					else if(addr_X == 3'd4) begin
						if(INDEX == 8'd127) begin
							STATE <= SETX;
							addr_X <= addr_X +  1;
							if(shift_count== 8'd183) 
								shift_count <= 8'd127;
							else	
								shift_count <= shift_count-1;
						end
						else if(INDEX_DATA == 8'h49) begin
							STATE <= WRITE_BLANK;
						end
						else INDEX_DATA <= INDEX_DATA+1;
					end
				end
			end
			default: begin	
				shift_count <= 8'd0;
				INDEX_DATA <= 8'd0;
				addr_X <= 0;
				STATE <= RST;
			end
		endcase
		end
	end
	
	always@(*) begin
		case(STATE)
			RST: begin
				LCD_CS1 = 1'b1;
				LCD_CS2 = 1'b1;
				LCD_RW = 1'b0;
				LCD_DI = 1'b0;
				LCD_RST = 1'b0;
				LCD_DATA = 8'b0;
			end
			ON: begin
				LCD_CS1 = 1'b1;
				LCD_CS2 = 1'b1;
				LCD_RW = 1'b0;
				LCD_DI = 1'b0;
				LCD_RST = 1'b1;
				LCD_DATA = 8'b00111111;
			end
			SETZ: begin
				LCD_CS1 = 1'b1;
				LCD_CS2 = 1'b1;
				LCD_RW = 1'b0;
				LCD_DI = 1'b0;
				LCD_RST = 1'b1;
				LCD_DATA = 8'b11000000;
			end
			SETY: begin
				LCD_CS1 = 1'b1;
				LCD_CS2 = 1'b1;
				LCD_RW = 1'b0;
				LCD_DI = 1'b0;
				LCD_RST = 1'b1;
				LCD_DATA = 8'b01000000;
			end
			SETX: begin
				LCD_CS1 = 1'b1;
				LCD_CS2 = 1'b1;
				LCD_RW = 1'b0;
				LCD_DI = 1'b0;
				LCD_RST = 1'b1;
				LCD_DATA = {5'b10111,addr_X};
			end
			WRITE_BLANK: begin
				LCD_RW = 1'b0;
				LCD_DI = 1'b1;
				LCD_RST = 1'b1;
				LCD_DATA = 8'b00000000;
				if(addr_X == 3'd3) begin
					LCD_CS1 = (INDEX < 8'd64) ? 1'b1 : 1'b0;
					LCD_CS2 = (INDEX < 8'd64) ? 1'b0 : 1'b1;
				end
				else if(addr_X == 3'd4) begin
					LCD_CS1 = (INDEX < 8'd64) ? 1'b1 : 1'b0;
					LCD_CS2 = (INDEX < 8'd64) ? 1'b0 : 1'b1;
				end
				else begin
					LCD_CS1 = 1'b1;
					LCD_CS2 = 1'b1;
				end
			end
			WRITE_WORDS: begin
				LCD_RW = 1'b0;
				LCD_DI = 1'b1;
				LCD_RST = 1'b1;
				if(addr_X == 3'd3) begin
					LCD_DATA = UPPER_PATTERN;
					LCD_CS1 = (INDEX < 8'd64) ? 1'b1 : 1'b0;
					LCD_CS2 = (INDEX < 8'd64) ? 1'b0 : 1'b1;
				end
				else if(addr_X == 3'd4) begin
					LCD_DATA = LOWER_PATTERN;
					LCD_CS1 = (INDEX < 8'd64) ? 1'b1 : 1'b0;
					LCD_CS2 = (INDEX < 8'd64) ? 1'b0 : 1'b1;
				end
				else begin
					LCD_DATA = 8'b0;
					LCD_CS1 = 1'b1;
					LCD_CS2 = 1'b1;
				end
			end
			default: begin
				LCD_CS1 = 1'b1;
				LCD_CS2 = 1'b1;
				LCD_RW = 1'b0;
				LCD_DI = 1'b0;
				LCD_RST = 1'b0;
				LCD_DATA = 8'b0;
			end
		endcase
	end

endmodule
