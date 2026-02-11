`include "FIFO.v"   // Include the FIFO design file

module FIFO_tb;

  // Control and status signals
  logic LOAD, RST, POP, EMPTY, FULL;

  // Data signals (wide bus: 1041 bits)
  logic [1040:0] VALUE_IN, VALUE_OUT;

  // Clock signal
  logic CLK;

  // Instantiate the FIFO DUT
  FIFO DUT (
    .LOAD(LOAD),
    .RST(RST),
    .POP(POP),
    .EMPTY(EMPTY),
    .FULL(FULL),
    .VALUE_IN(VALUE_IN),
    .VALUE_OUT(VALUE_OUT)
  );

  // Storage array to keep track of expected values
  reg [15:0][1040:0] slots;

  // Clock generation: toggles every 10 time units
  always #10 CLK = ~CLK;

  // Dump waveform data for simulation analysis
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
  // Reset sequence
  initial begin
    CLK = 0;
    LOAD = 0;
    POP = 0;
    VALUE_IN = 0;

    RST = 1;   // Assert reset
    #5;
    RST = 0;   // Deassert reset
  end

  // Test stimulus
  initial begin
    #10;

    // Load 16 random values into FIFO
    for (int i = 0; i < 16; i++) begin
      VALUE_IN = $random;   // Generate random input
      LOAD = 1;             // Assert LOAD to push into FIFO
      slots[i] = VALUE_IN;  // Save expected value
      #10;
      LOAD = 0;             // Deassert LOAD
      #10;
    end

    // Pop 16 values from FIFO and check against expected
    for (int i = 0; i < 16; i++) begin
      POP = 1;              // Assert POP to retrieve from FIFO
      #10;
      if (slots[i] == VALUE_OUT)
        $display("TEST PASSED! Expected: 0x%0h, Received: 0x%0h", slots[i], VALUE_OUT);
      else
        $display("TEST FAILED! Expected: 0x%0h, Received: 0x%0h", slots[i], VALUE_OUT);
      POP = 0;              // Deassert POP
      #10;
    end
  
    $finish; // End simulation
  end

endmodule