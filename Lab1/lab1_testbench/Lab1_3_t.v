`timescale 1ns/10ps

module lab1_test;

  reg a,b,cin;
  wire sum,cout;

  lab1_3 fa3(.a(a),.b(b),.cin(cin),.sum(sum),.cout(cout));
  
  initial
  begin
     #5 a = 1'b0; b = 1'b0; cin = 1'b0;
	 #5;
     if(cout!=1'b0||sum!=1'b0)
	 begin
	     printerror;
	 end
	 $display($time, " a = %b, b = %b, cin = %b, sum = %b, cout = %b",a,b,cin,sum,cout);
	 
	 #5 a = 1'b0; b = 1'b0; cin = 1'b1;
	 #5;
     if(cout!=1'b0||sum!=1'b1)
	 begin
	     printerror;
	 end
	 $display($time, " a = %b, b = %b, cin = %b, sum = %b, cout = %b",a,b,cin,sum,cout);
	 
	 #5 a = 1'b0; b = 1'b1; cin = 1'b0;
	 #5;
     if(cout!=1'b0||sum!=1'b1)
	 begin
	     printerror;
	 end
	 $display($time, " a = %b, b = %b, cin = %b, sum = %b, cout = %b",a,b,cin,sum,cout);
	 
	 #5 a = 1'b0; b = 1'b1; cin = 1'b1;
	 #5;
     if(cout!=1'b1||sum!=1'b0)
	 begin
	     printerror;
	 end
	 $display($time, " a = %b, b = %b, cin = %b, sum = %b, cout = %b",a,b,cin,sum,cout);
	 
	 #5 a = 1'b1; b = 1'b0; cin = 1'b0;
	 #5;
     if(cout!=1'b0||sum!=1'b1)
	 begin
	     printerror;
	 end
	 $display($time, " a = %b, b = %b, cin = %b, sum = %b, cout = %b",a,b,cin,sum,cout);
	 
	 #5 a = 1'b1; b = 1'b0; cin = 1'b1;
	 #5;
     if(cout!=1'b1||sum!=1'b0)
	 begin
	     printerror;
	 end
	 $display($time, " a = %b, b = %b, cin = %b, sum = %b, cout = %b",a,b,cin,sum,cout);
	 
	 #5 a = 1'b1; b = 1'b1; cin = 1'b0;
	 #5;
     if(cout!=1'b1||sum!=1'b0)
	 begin
	     printerror;
	 end
	 $display($time, " a = %b, b = %b, cin = %b, sum = %b, cout = %b",a,b,cin,sum,cout);
	 
	 #5 a = 1'b1; b = 1'b1; cin = 1'b1;
	 #5;
     if(cout!=1'b1||sum!=1'b1)
	 begin
	     printerror;
	 end
	 $display($time, " a = %b, b = %b, cin = %b, sum = %b, cout = %b",a,b,cin,sum,cout);
  end
  
  task printerror;
    begin
	    $display("Error:              a = %b, b = %b, cin = %b, sum = %b, cout = %b",a,b,cin,sum,cout);
	end
  endtask
  
endmodule
