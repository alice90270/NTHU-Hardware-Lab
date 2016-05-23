module lab8(CLK, RESET, LCD_ENABLE, LCD_RW, LCD_DI, LCD_CS1, LCD_CS2, LCD_RST,LCD_DATA);
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
	reg[7:0] INDEX;
	reg[1:0] ENABLE;
	reg CLEAR;
	reg LCD_RW;
	reg LCD_DI;
	reg LCD_RST;
	wire LCD_CLK;
	wire LCD_CS1;
	wire LCD_CS2;
	wire LCD_ENABLE;
	reg[5:0] start;
	reg[20:0] slow;
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
	always@(INDEX)
	begin
		case(INDEX)
		8'h00 : UPPER_PATTERN = 8'h00; //SPACE
		8'h01 : UPPER_PATTERN = 8'h00;
		8'h02 : UPPER_PATTERN = 8'h00;
		8'h03 : UPPER_PATTERN = 8'h00;
		8'h04 : UPPER_PATTERN = 8'h00;
		8'h05 : UPPER_PATTERN = 8'h00;
		8'h06 : UPPER_PATTERN = 8'h00;
		8'h07 : UPPER_PATTERN = 8'h00;
		8'h08 : UPPER_PATTERN = 8'h00; // SPACE
		8'h09 : UPPER_PATTERN = 8'h00;
		8'h0A : UPPER_PATTERN = 8'h00;
		8'h0B : UPPER_PATTERN = 8'h00;
		8'h0C : UPPER_PATTERN = 8'h00;
		8'h0D : UPPER_PATTERN = 8'h00;
		8'h0E : UPPER_PATTERN = 8'h00;
		8'h0F : UPPER_PATTERN = 8'h00;
		8'h10 : UPPER_PATTERN = 8'h00; // SPACE
		8'h11 : UPPER_PATTERN = 8'h00;
		8'h12 : UPPER_PATTERN = 8'h00;
		8'h13 : UPPER_PATTERN = 8'h00;
		8'h14 : UPPER_PATTERN = 8'h00;
		8'h15 : UPPER_PATTERN = 8'h00;
		8'h16 : UPPER_PATTERN = 8'h00;
		8'h17 : UPPER_PATTERN = 8'h08;
		8'h18 : UPPER_PATTERN = 8'hF8; // H
		8'h19 : UPPER_PATTERN = 8'hF8;
		8'h1A : UPPER_PATTERN = 8'h88;
		8'h1B : UPPER_PATTERN = 8'h80;
		8'h1C : UPPER_PATTERN = 8'h80;
		8'h1D : UPPER_PATTERN = 8'h88;
		8'h1E : UPPER_PATTERN = 8'hF8;
		8'h1F : UPPER_PATTERN = 8'hF8;
		8'h20 : UPPER_PATTERN = 8'h08; // E
		8'h21 : UPPER_PATTERN = 8'h08;
		8'h22 : UPPER_PATTERN = 8'hF8;
		8'h23 : UPPER_PATTERN = 8'hF8;
		8'h24 : UPPER_PATTERN = 8'h88;
		8'h25 : UPPER_PATTERN = 8'hC8;
		8'h26 : UPPER_PATTERN = 8'h18;
		8'h27 : UPPER_PATTERN = 8'h38;
		8'h28 : UPPER_PATTERN = 8'h08; // L
		8'h29 : UPPER_PATTERN = 8'hF8;
		8'h2A : UPPER_PATTERN = 8'hF8;
		8'h2B : UPPER_PATTERN = 8'h08;
		8'h2C : UPPER_PATTERN = 8'h00;
		8'h2D : UPPER_PATTERN = 8'h00;
		8'h2E : UPPER_PATTERN = 8'h00;
		8'h2F : UPPER_PATTERN = 8'h00;
		8'h30 : UPPER_PATTERN = 8'h08; // L
		8'h31 : UPPER_PATTERN = 8'hF8;
		8'h32 : UPPER_PATTERN = 8'hF8;
		8'h33 : UPPER_PATTERN = 8'h08;
		8'h34 : UPPER_PATTERN = 8'h00;
		8'h35 : UPPER_PATTERN = 8'h00;
		8'h36 : UPPER_PATTERN = 8'h00;
		8'h37 : UPPER_PATTERN = 8'h00;
		8'h38 : UPPER_PATTERN = 8'hE0; // O
		8'h39 : UPPER_PATTERN = 8'hF0;
		8'h3A : UPPER_PATTERN = 8'h18;
		8'h3B : UPPER_PATTERN = 8'h08;
		8'h3C : UPPER_PATTERN = 8'h08;
		8'h3D : UPPER_PATTERN = 8'h18;
		8'h3E : UPPER_PATTERN = 8'hF0;
		8'h3F : UPPER_PATTERN = 8'hE0;
		8'h40 : UPPER_PATTERN = 8'h00; //SPACE
		8'h41 : UPPER_PATTERN = 8'h00;
		8'h42 : UPPER_PATTERN = 8'h00;
		8'h43 : UPPER_PATTERN = 8'h00;
		8'h44 : UPPER_PATTERN = 8'h00;
		8'h45 : UPPER_PATTERN = 8'h00;
		8'h46 : UPPER_PATTERN = 8'h00;
		8'h47 : UPPER_PATTERN = 8'h00;
		8'h48 : UPPER_PATTERN = 8'h08; // L
		8'h49 : UPPER_PATTERN = 8'hF8;
		8'h4A : UPPER_PATTERN = 8'hF8;
		8'h4B : UPPER_PATTERN = 8'h08;
		8'h4C : UPPER_PATTERN = 8'h00;
		8'h4D : UPPER_PATTERN = 8'h00;
		8'h4E : UPPER_PATTERN = 8'h00;
		8'h4F : UPPER_PATTERN = 8'h00;
		8'h50 : UPPER_PATTERN = 8'h00; // C
		8'h51 : UPPER_PATTERN = 8'hE0;
		8'h52 : UPPER_PATTERN = 8'hF0;
		8'h53 : UPPER_PATTERN = 8'h18;
		8'h54 : UPPER_PATTERN = 8'h08;
		8'h55 : UPPER_PATTERN = 8'h08;
		8'h56 : UPPER_PATTERN = 8'h18;
		8'h57 : UPPER_PATTERN = 8'h30;
		8'h58 : UPPER_PATTERN = 8'h08; // D
		8'h59 : UPPER_PATTERN = 8'hF8;
		8'h5A : UPPER_PATTERN = 8'hF8;
		8'h5B : UPPER_PATTERN = 8'h08;
		8'h5C : UPPER_PATTERN = 8'h18;
		8'h5D : UPPER_PATTERN = 8'hF0;
		8'h5E : UPPER_PATTERN = 8'hE0;
		8'h5F : UPPER_PATTERN = 8'h00;
		8'h60 : UPPER_PATTERN = 8'h00; // !
		8'h61 : UPPER_PATTERN = 8'h00;
		8'h62 : UPPER_PATTERN = 8'h00;
		8'h63 : UPPER_PATTERN = 8'hF8;
		8'h64 : UPPER_PATTERN = 8'hF8;
		8'h65 : UPPER_PATTERN = 8'h00;
		8'h66 : UPPER_PATTERN = 8'h00;
		8'h67 : UPPER_PATTERN = 8'h00;
		8'h68 : UPPER_PATTERN = 8'h00; // SPACE
		8'h69 : UPPER_PATTERN = 8'h00;
		8'h6A : UPPER_PATTERN = 8'h00;
		8'h6B : UPPER_PATTERN = 8'h00;
		8'h6C : UPPER_PATTERN = 8'h00;
		8'h6D : UPPER_PATTERN = 8'h00;
		8'h6E : UPPER_PATTERN = 8'h00;
		8'h6F : UPPER_PATTERN = 8'h00;
		8'h70 : UPPER_PATTERN = 8'h00; // SPACE
		8'h71 : UPPER_PATTERN = 8'h00;
		8'h72 : UPPER_PATTERN = 8'h00;
		8'h73 : UPPER_PATTERN = 8'h00;
		8'h74 : UPPER_PATTERN = 8'h00;
		8'h75 : UPPER_PATTERN = 8'h00;
		8'h76 : UPPER_PATTERN = 8'h00;
		8'h77 : UPPER_PATTERN = 8'h00;
		8'h78 : UPPER_PATTERN = 8'h00; // SPACE
		8'h79 : UPPER_PATTERN = 8'h00;
		8'h7A : UPPER_PATTERN = 8'h00;
		8'h7B : UPPER_PATTERN = 8'h00;
		8'h7C : UPPER_PATTERN = 8'h00;
		8'h7D : UPPER_PATTERN = 8'h00;
		8'h7E : UPPER_PATTERN = 8'h00;
		8'h7F : UPPER_PATTERN = 8'h00;
		endcase
	end

	always@(INDEX)
	begin
		case(INDEX)
		8'h00 : LOWER_PATTERN = 8'h00; // SPACE
		8'h01 : LOWER_PATTERN = 8'h00;
		8'h02 : LOWER_PATTERN = 8'h00;
		8'h03 : LOWER_PATTERN = 8'h00;
		8'h04 : LOWER_PATTERN = 8'h00;
		8'h05 : LOWER_PATTERN = 8'h00;
		8'h06 : LOWER_PATTERN = 8'h00;
		8'h07 : LOWER_PATTERN = 8'h00;
		8'h08 : LOWER_PATTERN = 8'h00; // SPACE
		8'h09 : LOWER_PATTERN = 8'h00;
		8'h0A : LOWER_PATTERN = 8'h00;
		8'h0B : LOWER_PATTERN = 8'h00;
		8'h0C : LOWER_PATTERN = 8'h00;
		8'h0D : LOWER_PATTERN = 8'h00;
		8'h0E : LOWER_PATTERN = 8'h00;
		8'h0F : LOWER_PATTERN = 8'h00;
		8'h10 : LOWER_PATTERN = 8'h00; // SPACE
		8'h11 : LOWER_PATTERN = 8'h00;
		8'h12 : LOWER_PATTERN = 8'h00;
		8'h13 : LOWER_PATTERN = 8'h00;
		8'h14 : LOWER_PATTERN = 8'h00;
		8'h15 : LOWER_PATTERN = 8'h00;
		8'h16 : LOWER_PATTERN = 8'h00;
		8'h17 : LOWER_PATTERN = 8'h08;
		8'h18 : LOWER_PATTERN = 8'h0F; // H
		8'h19 : LOWER_PATTERN = 8'h0F;
		8'h1A : LOWER_PATTERN = 8'h08;
		8'h1B : LOWER_PATTERN = 8'h00;
		8'h1C : LOWER_PATTERN = 8'h00;
		8'h1D : LOWER_PATTERN = 8'h08;
		8'h1E : LOWER_PATTERN = 8'h0F;
		8'h1F : LOWER_PATTERN = 8'h0F;
		8'h20 : LOWER_PATTERN = 8'h08; // E
		8'h21 : LOWER_PATTERN = 8'h08;
		8'h22 : LOWER_PATTERN = 8'h0F;
		8'h23 : LOWER_PATTERN = 8'h0F;
		8'h24 : LOWER_PATTERN = 8'h08;
		8'h25 : LOWER_PATTERN = 8'h09;
		8'h26 : LOWER_PATTERN = 8'h0C;
		8'h27 : LOWER_PATTERN = 8'h0E;
		8'h28 : LOWER_PATTERN = 8'h08; // L
		8'h29 : LOWER_PATTERN = 8'h0F;
		8'h2A : LOWER_PATTERN = 8'h0F;
		8'h2B : LOWER_PATTERN = 8'h08;
		8'h2C : LOWER_PATTERN = 8'h08;
		8'h2D : LOWER_PATTERN = 8'h08;
		8'h2E : LOWER_PATTERN = 8'h08;
		8'h2F : LOWER_PATTERN = 8'h0C;
		8'h30 : LOWER_PATTERN = 8'h08; // L
		8'h31 : LOWER_PATTERN = 8'h0F;
		8'h32 : LOWER_PATTERN = 8'h0F;
		8'h33 : LOWER_PATTERN = 8'h08;
		8'h34 : LOWER_PATTERN = 8'h08;
		8'h35 : LOWER_PATTERN = 8'h08;
		8'h36 : LOWER_PATTERN = 8'h08;
		8'h37 : LOWER_PATTERN = 8'h0C;
		8'h38 : LOWER_PATTERN = 8'h03; // O
		8'h39 : LOWER_PATTERN = 8'h07;
		8'h3A : LOWER_PATTERN = 8'h0C;
		8'h3B : LOWER_PATTERN = 8'h08;
		8'h3C : LOWER_PATTERN = 8'h08;
		8'h3D : LOWER_PATTERN = 8'h0C;
		8'h3E : LOWER_PATTERN = 8'h07;
		8'h3F : LOWER_PATTERN = 8'h03;	
		8'h40 : LOWER_PATTERN = 8'h00; // SPACE
		8'h41 : LOWER_PATTERN = 8'h00;
		8'h42 : LOWER_PATTERN = 8'h00;
		8'h43 : LOWER_PATTERN = 8'h00;
		8'h44 : LOWER_PATTERN = 8'h00;
		8'h45 : LOWER_PATTERN = 8'h00;
		8'h46 : LOWER_PATTERN = 8'h00;
		8'h47 : LOWER_PATTERN = 8'h00;
		8'h48 : LOWER_PATTERN = 8'h08; // L
		8'h49 : LOWER_PATTERN = 8'h0F;
		8'h4A : LOWER_PATTERN = 8'h0F;
		8'h4B : LOWER_PATTERN = 8'h08;
		8'h4C : LOWER_PATTERN = 8'h08;
		8'h4D : LOWER_PATTERN = 8'h08;
		8'h4E : LOWER_PATTERN = 8'h08;
		8'h4F : LOWER_PATTERN = 8'h0C;
		8'h50 : LOWER_PATTERN = 8'h00; // C
		8'h51 : LOWER_PATTERN = 8'h03;
		8'h52 : LOWER_PATTERN = 8'h07;
		8'h53 : LOWER_PATTERN = 8'h0C;
		8'h54 : LOWER_PATTERN = 8'h08;
		8'h55 : LOWER_PATTERN = 8'h08;
		8'h56 : LOWER_PATTERN = 8'h0C;
		8'h57 : LOWER_PATTERN = 8'h06;
		8'h58 : LOWER_PATTERN = 8'h08; // D
		8'h59 : LOWER_PATTERN = 8'h0F;
		8'h5A : LOWER_PATTERN = 8'h0F;
		8'h5B : LOWER_PATTERN = 8'h08;
		8'h5C : LOWER_PATTERN = 8'h0C;
		8'h5D : LOWER_PATTERN = 8'h07;
		8'h5E : LOWER_PATTERN = 8'h03;
		8'h5F : LOWER_PATTERN = 8'h00;
		8'h60 : LOWER_PATTERN = 8'h00; // !
		8'h61 : LOWER_PATTERN = 8'h00;
		8'h62 : LOWER_PATTERN = 8'h00;
		8'h63 : LOWER_PATTERN = 8'h00;
		8'h64 : LOWER_PATTERN = 8'h0C;
		8'h65 : LOWER_PATTERN = 8'h0C;
		8'h66 : LOWER_PATTERN = 8'h00;
		8'h67 : LOWER_PATTERN = 8'h00;
		8'h68 : LOWER_PATTERN = 8'h00; // SPACE
		8'h69 : LOWER_PATTERN = 8'h00;
		8'h6A : LOWER_PATTERN = 8'h00;
		8'h6B : LOWER_PATTERN = 8'h00;
		8'h6C : LOWER_PATTERN = 8'h00;
		8'h6D : LOWER_PATTERN = 8'h00;
		8'h6E : LOWER_PATTERN = 8'h00;
		8'h6F : LOWER_PATTERN = 8'h00;
		8'h70 : LOWER_PATTERN = 8'h00; // SPACE
		8'h71 : LOWER_PATTERN = 8'h00;
		8'h72 : LOWER_PATTERN = 8'h00;
		8'h73 : LOWER_PATTERN = 8'h00;
		8'h74 : LOWER_PATTERN = 8'h00;
		8'h75 : LOWER_PATTERN = 8'h00;
		8'h76 : LOWER_PATTERN = 8'h00;
		8'h77 : LOWER_PATTERN = 8'h00;
		8'h78 : LOWER_PATTERN = 8'h00; // SPACE
		8'h79 : LOWER_PATTERN = 8'h00;
		8'h7A : LOWER_PATTERN = 8'h00;
		8'h7B : LOWER_PATTERN = 8'h00;
		8'h7C : LOWER_PATTERN = 8'h00;
		8'h7D : LOWER_PATTERN = 8'h00;
		8'h7E : LOWER_PATTERN = 8'h00;
		8'h7F : LOWER_PATTERN = 8'h00;
		endcase
	end
	/******************************
	* Initialize and Write LCD Data *
	******************************/
	always@(negedge LCD_CLK or negedge RESET)begin
		if(!RESET)begin
			CLEAR <= 1'b1;
			STATE <= 3'b0;
			DELAY <= 2'b00;
			X_PAGE <= 3'o0;
			INDEX = 0;
			LCD_RST<= 1'b0;
			ENABLE <= 2'b00;
			LCD_SEL<= 2'b11;
			LCD_DI <= 1'b0;
			LCD_RW <= 1'b0;
		end
		
		else begin
			if(ENABLE < 2'b10)begin
				ENABLE <= ENABLE + 1;
				DELAY[1]<= 1'b1;
			end
			else if(DELAY != 2'b00)
				DELAY <= DELAY -1;
			else if(STATE == 3'o0)begin
				STATE <= 3'o1;
				LCD_RST <= 1'b1;
				LCD_DATA<= 8'h3F;
				ENABLE <= 2'b00;
			end
			else if(STATE == 3'o1)
			begin
				STATE <= 3'o2;
				LCD_DATA<= {2'b11,start};
				ENABLE <= 2'b00;
				start <= start+1;
			end
			else if(STATE == 3'o2)
			begin
				STATE <= 3'o3;
				LCD_DATA<= 8'h40;
				ENABLE <= 2'b00;
			end
			else if(STATE == 3'o3)
			begin
				STATE <= 3'o4;
				LCD_DI <= 1'b0;
				INDEX = 0;
				LCD_DATA<= {5'b10111,X_PAGE};
				ENABLE <= 2'b00;
			end
			else if(STATE == 3'o4)
			begin
				if(CLEAR)
				begin
					if(INDEX < 64)
					begin
						INDEX = INDEX + 1;
						LCD_DI <= 1'b1;
						LCD_DATA<= 8'h00;
						ENABLE <= 2'b00;
					end
					else if(X_PAGE < 3'o7)
					begin
						STATE <= 3'o3;
						X_PAGE <= X_PAGE + 1;
					end
					else
					begin
						STATE <= 3'o3;
						X_PAGE <= 3'o6;  //跳到顯示的地方
						CLEAR <= 1'b0;
					end
			end
			
			else
				if((X_PAGE == 3'o6)||(X_PAGE == 3'o7))
				begin
					if(INDEX < 128)
					begin
						LCD_DI <= 1'b1;
						if(X_PAGE == 3'o6)
							LCD_DATA <= UPPER_PATTERN;
						else
							LCD_DATA <= LOWER_PATTERN;
						
						if(INDEX < 64)
							LCD_SEL <= 2'b01;
						else
							LCD_SEL <= 2'b10;
						
						INDEX = INDEX + 1;
						ENABLE<= 2'b00;
					end
					
					else
					begin
						if(X_PAGE==3'o7)begin
							if(slow[12])begin
								STATE <= 3'o1;
								LCD_SEL <= 2'b11;
								LCD_DI <= 0;
								LCD_RW <= 0;
								slow <= 0;
							end
							else slow <= slow +1;
						end
						else begin
							LCD_SEL <= 2'b11;
							STATE <= 3'o3;
							X_PAGE <= X_PAGE + 1;
						end
					end
				end
			end
		end
	end
	assign LCD_ENABLE = ENABLE[0];
	assign LCD_CS1 = LCD_SEL[0];
	assign LCD_CS2 = LCD_SEL[1];

endmodule
