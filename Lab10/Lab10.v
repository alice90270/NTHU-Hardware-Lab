module Lab10(clk, rst_n, cancel, tea, coke, sprite, money_5, money_10, money_50, drop_tea, drop_coke, drop_sprite, DIGIT, DISPLAY );
	input clk, rst_n, cancel, tea, coke, sprite, money_5, money_10, money_50;
	output reg drop_tea, drop_coke, drop_sprite;
	output reg[3:0] DIGIT;
	output reg[7:0] DISPLAY;
	
	reg[25:0] countclk; //設定從0開始?
	wire reset, db_cancel, db5, db10, db50, db_tea, db_coke, db_sprite;
	reg[3:0] shift_rst, shift_cancel, shift_m5, shift_m10, shift_m50, shift_tea, shift_coke, shift_sprite;
	reg[2:0] state;
	reg[5:0] sum;
	reg flag;
	reg[3:0] tens;
	reg[7:0] buff;
	reg[3:0] DECODE_BCD;
	reg op_cancel,op5,op10,op50,op_tea,op_coke,op_sprite;
	parameter origin = 3'd0;
	parameter nothing = 3'd1;
	parameter buyA	= 3'd2;
	parameter buyAB = 3'd3;
	parameter buyABC = 3'd4;
	parameter change = 3'd5;	
	
	onepulse pulse0(PB_debounced.(op_cancel), clock.(clk), PB_single_pulse.(db_cancel));
	onepulse pulse1(PB_debounced.(op5), clock.(clk), PB_single_pulse.(db5));
	onepulse pulse2(PB_debounced.(op10), clock.(clk), PB_single_pulse.(db10));
	onepulse pulse3(PB_debounced.(op50), clock.(clk), PB_single_pulse.(db50));
	onepulse pulse4(PB_debounced.(op_tea), clock.(clk), PB_single_pulse.(db_tea));
	onepulse pulse5(PB_debounced.(op_coke), clock.(clk), PB_single_pulse.(db_coke));
	onepulse pulse6(PB_debounced.(op_sprite), clock.(clk), PB_single_pulse.(db_sprite));
	
/*********************************************************
					state machine
**********************************************************/

	always @ (posedge clk or negedge reset) begin
		if(!reset) begin
			state <= origin;
		end
		else begin
			case(state)
				origin:	begin
					if(!db5 || !db10 || !db50) state <= nothing;
					else if(!cancel) state <= change;
					else state <= origin;
				end
				nothing: begin
					if(!db_cancel) state <= change;
					else if(sum > 6'd14) state <= buyA;
					else if(sum > 6'd19) state <= buyAB;
					else if(sum > 6'd24) state <= buyABC;
					else state <= nothing;
				end
				buyA: begin
					if(!db_cancel || flag==1'd1) state <= change;
					else if(sum < 6'd15) state <= nothing;
					else if(sum > 6'd19) state <= buyAB;
					else if(sum > 6'd24) state <= buyABC;
					else state <= buyA;
				end
				buyAB: begin
					if(!db_cancel ||  flag==1'd1) state <= change;
					else if(sum < 6'd20) state <= buyA;
					else if(sum > 6'd24) state <= buyABC;
					else state <= buyAB;
				end
				buyABC: begin
					if(!db_cancel || flag==1'd1) state <= change;
					else if(sum < 6'd25) state <= buyAB;
					else state <= buyABC;
				end
				change: begin
					if(sum == 6'd0) state <= origin;
					else state <= change;
				end
				default: begin
				state <= origin;
				end
			endcase
		end
	
	end
	
/*********************************************************
					button debounce
**********************************************************/
// RESET
	always@(posedge clk) begin
		shift_rst[3:1] <= shift_rst[2:0];
		shift_rst[0] <= rst_n;
	end
	assign reset= ((shift_rst== 4'b0000) ? 1'b0 : 1'b1);
// CANCEL	
	always@(posedge clk) begin
		shift_cancel[3:1] <= shift_cancel[2:0];
		shift_cancel[0] <= cancel;
	end
	assign op_cancel= ((shift_cancel== 4'b0000) ? 1'b0 : 1'b1);
// $5	
	always@(posedge clk) begin
		shift_m5[3:1] <= shift_m5[2:0];
		shift_m5[0] <= money_5;
	end
	assign op5= ((shift_m5== 4'b0000) ? 1'b0 : 1'b1);
// $10		
	always@(posedge clk) begin
		shift_m10[3:1] <= shift_m10[2:0];
		shift_m10[0] <= money_10;
	end
	assign op10=  ((shift_m10== 4'b0000) ? 1'b0 : 1'b1);
// $50		
	always@(posedge clk) begin
		shift_m50[3:1] <= shift_m50[2:0];
		shift_m50[0] <= money_50;
	end
	assign op50= ((shift_m50== 4'b0000) ? 1'b0 : 1'b1);
// tea		
	always@(posedge clk) begin
		shift_tea[3:1] <= shift_tea[2:0];
		shift_tea[0] <= tea;
	end
	assign op_tea=	((shift_tea== 4'b0000) ? 1'b0 : 1'b1);
// coke
	always@(posedge clk) begin
		shift_coke[3:1] <= shift_coke[2:0];
		shift_coke[0] <= coke;
	end
	assign op_coke= ((shift_coke== 4'b0000) ? 1'b0 : 1'b1);
// sprite	
	always@(posedge clk) begin
		shift_sprite[3:1] <= shift_sprite[2:0];
		shift_sprite[0] <= sprite;
	end
	assign op_sprite=((shift_sprite== 4'b0000) ? 1'b0 : 1'b1);
	
/*********************************************************
					change $
**********************************************************/
	always @(posedge clk or negedge reset) begin
		if(!reset)begin
			sum <= 6'd0;
			drop_tea <= 1'b1;
			drop_coke <= 1'b1;
			drop_sprite <= 1'b1;
			flag<=1'b0;
		end
		else begin
			//deposit & choose drink
			if(state!=change)begin
				if(!db5)
					sum <= sum + 6'd5;
				if(!db10)
					sum <= sum + 6'd10;
				if(!db50)
					sum <= sum + 6'd50;
				if(sum >= 6'd50) sum <= 6'd50;
				
				if(!db_tea && (state==buyA || state==buyAB || state==buyABC))begin
					sum <= sum - 6'd15;
					flag <=1'b1;
				end
				if(!db_coke && (state==buyAB || state==buyABC)) begin
					sum <= sum - 6'd20;
					flag <=1'b1;
				end
				if(!db_sprite && state==buyABC)begin
					sum <= sum - 6'd25;
					flag <=1'b1;
				end
			end
			else begin
				if(countclk[25]==1'b1)begin
					countclk<=25'b0;
					flag<=1'd0;
					if(sum>6'd0)	sum <= sum - 6'd5;
					else sum <= 6'd0;
				end
				else begin
					countclk=countclk+1'b1;
				end
				
			end
			//LED	
			if(flag==1'b1)begin
				drop_tea<=1'b1; 
				drop_coke<=1'b1;
				drop_sprite<=1'b1;
			end
			else begin
				case(state)
					buyA: drop_tea<=1'b0;
					buyAB: begin
						drop_tea<=1'b0;
						drop_coke<=1'b0;
					end
					buyABC: begin
						drop_tea<=1'b0; 
						drop_coke<=1'b0;
						drop_sprite<=1'b0;
					end
					default:begin
						drop_tea<=1'b1; 
						drop_coke<=1'b1;
						drop_sprite<=1'b1;
					end
				endcase	
			end
			
		end
	end

/*********************************************************
					enale DIGIT
**********************************************************/
	always@(posedge clk or negedge reset)begin
		if (!reset)
			DIGIT <= 4'b0011;
		else begin
		 case(DIGIT)
			4'b0011: DIGIT<=4'b0111;
			default: DIGIT<={DIGIT[2],DIGIT[3],1'b1,1'b1};
		 endcase
		end
	end

/*********************************************************
					data display
**********************************************************/
	always@(DIGIT or sum) begin
		
		if(sum<6'd10)  tens=4'd0; 
		if(sum>=6'd10) tens=4'd1;
		if(sum>=6'd20) tens=4'd2;
		if(sum>=6'd30) tens=4'd3;
		if(sum>=6'd40) tens=4'd4;
		if(sum>=6'd50) tens=4'd5;
			
		case(tens)
			6'd0: begin
				buff[7:4]=4'd0;
				buff[3:0]=sum[3:0];
			end
			6'd1: begin
				buff[7:4]=4'd1;
				buff[3:0]=sum-6'd10;
			end
			6'd2: begin
				buff[7:4]=4'd2;
				buff[3:0]=sum-6'd20;
			end
			6'd3: begin
				buff[7:4]=4'd3;
				buff[3:0]=sum-6'd30;
			end
			6'd4: begin
				buff[7:4]=4'd4;
				buff[3:0]=sum-6'd40;
			end
			6'd5: begin
				buff[7:4]=4'd5;
				buff[3:0]=4'd0;
			end	
			default:  begin
				buff[7:4]=4'd0;
				buff[3:0]=4'd0;
			end
		endcase

		case(DIGIT)
			4'b0111:DECODE_BCD = buff[7:4];
			4'b1011:DECODE_BCD = buff[3:0];
		endcase
	end
	
/*********************************************************
					seven segment
**********************************************************/
	always@(DECODE_BCD) begin
		case(DECODE_BCD)
			4'd0 : DISPLAY = 8'b00000011;//0
			4'd1 : DISPLAY = 8'b10011111;//1
			4'd2 : DISPLAY = 8'b00100100;//2
			4'd3 : DISPLAY = 8'b00001100;//3
			4'd4 : DISPLAY = 8'b10011000;//4
			4'd5 : DISPLAY = 8'b01001000;//5
			4'd6 : DISPLAY = 8'b01000000;//6
			4'd7 : DISPLAY = 8'b00011111;//7
			4'd8 : DISPLAY = 8'b00000000;//8
			4'd9 : DISPLAY = 8'b00011000;//9
			default:DISPLAY = 8'b00000011;
		endcase
	end	
	
endmodule

// Single Pulse circuit 
// the output will go high for only one clock cycle
module onepulse (PB_debounced, clock, PB_single_pulse);

   input PB_debounced; 
   input clock; 
   output PB_single_pulse; 
   //declare the outputs
   reg PB_single_pulse;
   //declare the internal registers
   reg PB_debounced_delay; 
   reg Power_on; 
   //start the process	
   always @(posedge clock)
   begin
      //Power_on will be initialized to 0 (default value) by Xilinx tool
      if (Power_on == 1'b0)
      begin
      	 //This code resets the critical signals once at power up
         PB_single_pulse <= 1'b0 ; 
         PB_debounced_delay <= 1'b1 ; 
         Power_on <= 1'b1 ; 
      end
      else
      begin
      	//A single clock cycle pulse is produced when the switch is hit
	//no matter how long the switch is held down.
	//The switch input must already be debounced.
         if (PB_debounced == 1'b1 & PB_debounced_delay == 1'b0)
            PB_single_pulse <= 1'b1 ; 
         else
            PB_single_pulse <= 1'b0 ; 
            
         PB_debounced_delay <= PB_debounced ; 
      end 
   end 
endmodule

