`timescale 1ns / 1ps
module Lab3_1_t;
  
  reg en;
  reg dir;
  reg [3:0] inputs;
  wire [3:0] outputs;
  wire cout;
  reg pass;
  
  Lab3_1 u1(.cout(cout), .outputs(outputs), .inputs(inputs), .dir(dir), .en(en));
  
  initial begin
    pass = 1'b1;
    
    // up counter
    #5 dir = 1'b1;
    for(inputs = 4'd0; inputs < 4'd9; inputs = inputs+4'd1) begin
      en = 1'b0;
      #5;
      if(outputs !== inputs || cout !== 1'b0) begin
        printerror;
        pass = 1'b0;
      end
      en = 1'b1;
      #5;
      if(outputs !== inputs+4'd1 || cout !== 1'b0) begin
        printerror;
        pass = 1'b0;
      end
    end
   
    inputs = 4'd9; en = 1'b0;
    #5;
    if(outputs !== inputs || cout !== 1'b0) begin
      printerror;
      pass = 1'b0;
    end
    
    en = 1'b1;
    #5;
    if(outputs !== 4'd0 || cout !== 1'b1) begin
      printerror;
      pass = 1'b0;
    end
   
    for(inputs = 4'd10; inputs > 4'd0; inputs = inputs+4'd1) begin
      en = 1'b0;
      #5;
      if(outputs !== inputs || cout !== 1'b0) begin
        printerror;
        pass = 1'b0;
      end
      en = 1'b1;
      #5;
      if(outputs !== 4'd0 || cout !== 1'b0) begin
        printerror;
        pass = 1'b0;
      end
    end
    
    // down counter
    dir = 1'b0;
    for(inputs = 4'd1; inputs <= 4'd9; inputs = inputs+4'd1) begin
      en = 1'b0;
      #5;
      if(outputs !== inputs || cout !== 1'b0) begin
        printerror;
        pass = 1'b0;
      end
      en = 1'b1;
      #5;
      if(outputs !== inputs-4'd1 || cout !== 1'b0) begin
        printerror;
        pass = 1'b0;
      end
    end
   
    for(inputs = 4'd10; inputs > 4'd0; inputs = inputs+4'd1) begin
      en = 1'b0;
      #5;
      if(outputs !== inputs || cout !== 1'b0) begin
        printerror;
        pass = 1'b0;
      end
      en = 1'b1;
      #5;
      if(outputs !== 4'd0 || cout !== 1'b0) begin
        printerror;
        pass = 1'b0;
      end
    end
    
    inputs = 4'd0; en = 1'b0;
    #5;
    if(outputs !== inputs || cout !== 1'b0) begin
      printerror;
      pass = 1'b0;
    end
    
    en = 1'b1;
    #5;
    if(outputs !== 4'd9 || cout !== 1'b1) begin
      printerror;
      pass = 1'b0;
    end

    #5;
    if(pass === 1'b1)
      $display("PASS");
    $finish;
  end

  task printerror;
    begin
      $display("Error at en=%b, dir=%b, inputs=%d, outputs=%d, cout=%b", en, dir, inputs, outputs, cout);
    end
  endtask
  
endmodule
