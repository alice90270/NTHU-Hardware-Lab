// Single Pulse circuit
// the output will go high for only one clock cycle
module onepulse (PB_single_pulse, PB_debounced, clock);
  input PB_debounced;
  input clock;
  output PB_single_pulse;
  reg PB_single_pulse;
  reg PB_debounced_delay;
    
  always @(posedge clock)
  begin
    if (PB_debounced == 1'b0 & PB_debounced_delay == 1'b1)
      PB_single_pulse <= 1'b0;
    else
      PB_single_pulse <= 1'b1;

    PB_debounced_delay <= PB_debounced;
  end
endmodule
