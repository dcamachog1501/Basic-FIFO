//------------------------------------------------------------
// FIFO Interface
// Defines signals, clocking blocks, and modports for
// driver, monitor, and DUT connectivity.
//------------------------------------------------------------

interface FIFO_if #(
    parameter WIDTH = FIFO_WIDTH   // FIFO data width
)(
    input CLK                      // Clock input
);

    // DUT interface signals
    logic LOAD, POP, RST;                // Control
    logic [WIDTH-1:0] VALUE_IN;          // Data input
    logic EMPTY, FULL;                   // Status flags
    logic [WIDTH-1:0] VALUE_OUT;         // Data output
    logic VALID_DRV;                     // Driver valid flag

    // Driver clocking block
    clocking drv_cb @(posedge CLK);
      //Applying Outputs in the NBA region (TB in Module Block)
      output #0 LOAD, POP, VALUE_IN, VALID_DRV,RST;
    endclocking

    // Monitor clocking block
    clocking mon_cb @(posedge CLK);
      	// Sampling Inputs in the Preponed Region (TB in Module Block)
        input #0 LOAD, POP, VALUE_IN, EMPTY, FULL, VALUE_OUT, VALID_DRV; 
    endclocking

    // Modports
    modport drv_mp (clocking drv_cb);    // Driver
    modport mon_mp (clocking mon_cb);    // Monitor
    modport dut_mp (
        input  LOAD, RST, POP, CLK, VALUE_IN,
        output EMPTY, FULL, VALUE_OUT
    );                                   // DUT

endinterface