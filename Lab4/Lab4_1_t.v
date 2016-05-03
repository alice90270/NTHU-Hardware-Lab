`timescale 1ps / 1ps
module Lab4_1_t;
  
  reg clk;
  reg rst_n;
  reg start_stop;
  reg dir;
  wire [3:0] BCD1;
  wire [3:0] BCD0;
  wire cout;
  reg pass;
  
  integer i;
  wire [6:0] BCDoutput;
  assign BCDoutput = BCD1*10 + BCD0;
  
  lab4_1 u1(.cout(cout), .BCD1(BCD1), .BCD0(BCD0), .clk(clk), .reset(rst_n), .en(start_stop), .dir(dir));
  
  always #5 clk = ~clk;
  
  initial begin
    pass = 1'b1;
    clk = 1'b1;
    rst_n = 1'b0;
	 #1;
    
    // up counter
	$display("up counter");
    rst_n = 1'b1;
    start_stop = 1'b1;
    dir = 1'b1;
	 #1;
    
    for(i = 0; i <= 98; i = i+1) begin
      if(BCDoutput !== i || cout !== 1'b0) begin
        printerror;
        pass = 0;
      end
      else begin
        printresult;
      end
      #10;
    end
    
    if(BCDoutput !== 99 || cout !== 1'b1) begin
      printerror;
      pass = 0;
    end
    else begin
      printresult;
    end
    #10;
    
    for(i = 0; i <= 98; i = i+1) begin
      if(BCDoutput !== i || cout !== 1'b0) begin
        printerror;
        pass = 0;
      end
      else begin
        printresult;
      end
      #10;
    end
    
    if(BCDoutput !== 99 || cout !== 1'b1) begin
      printerror;
      pass = 0;
    end
    else begin
      printresult;
    end
    
    
    start_stop = 1'b0;
	 #1;
    if(BCDoutput !== 99 || cout !== 1'b0) begin
      printerror;
      pass = 0;
    end
    else begin
      printresult;
    end
    
    for(i = 1; i <= 5; i = i+1) begin
      #10;
      if(BCDoutput !== 99 || cout !== 1'b0) begin
        printerror;
        pass = 0;
      end
      else begin
        printresult;
      end
    end
    
    
    // down counter
	$display("down counter");
    start_stop = 1'b1;
    dir = 1'b0;
    printresult;
	 #1;
    
    for(i = 99; i > 0; i = i-1) begin
      if(BCDoutput !== i || cout !== 1'b0) begin
        printerror;
        pass = 0;
      end
      else begin
        printresult;
      end
      #10;
    end
    
    if(BCDoutput !== 0 || cout !== 1'b1) begin
      printerror;
      pass = 0;
    end
    else begin
      printresult;
    end
    #10;
    
    for(i = 99; i > 0; i = i-1) begin
      if(BCDoutput !== i || cout !== 1'b0) begin
        printerror;
        pass = 0;
      end
      else begin
        printresult;
      end
      #10;
    end
    
    if(BCDoutput !== 0 || cout !== 1'b1) begin
      printerror;
      pass = 0;
    end
    else begin
      printresult;
    end
    
    
    start_stop = 1'b0;
	 #1;
    if(BCDoutput !== 0 || cout !== 1'b0) begin
      printerror;
      pass = 0;
    end
    else begin
      printresult;
    end
    
    for(i = 1; i <= 5; i = i+1) begin
      #10;
      if(BCDoutput !== 0 || cout !== 1'b0) begin
        printerror;
        pass = 0;
      end
      else begin
        printresult;
      end
    end
    
    
    if(pass === 1'b1)
      $display("PASS");
    $finish;
  end

  task printerror;
    begin
      $display("Error at cout=%b, BCD=%d%d, start_stop=%b, dir=%b", cout, BCD1, BCD0, start_stop, dir);
    end
  endtask
  
  task printresult;
    begin
      $display("cout=%b, BCD=%d%d, start_stop=%b, dir=%b", cout, BCD1, BCD0, start_stop, dir);
    end
  endtask
  
endmodule
