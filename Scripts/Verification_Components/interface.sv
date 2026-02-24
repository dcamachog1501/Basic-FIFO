//------------------------------------------------------------
// FIFO Interface
// Defines signals, clocking blocks, and modports for
// driver, monitor, and DUT connectivity.
//------------------------------------------------------------
interface FIFO_if # (
    parameter WIDTH   // Width of FIFO data
)(
    input CLK        // Clock input
);

    //--------------------------------------------------------
    // DUT interface signals
    //--------------------------------------------------------
    logic LOAD, POP, RST;                // Control signals
    logic [WIDTH-1:0] VALUE_IN;          // Data input
    logic EMPTY, FULL;                   // Status flags
    logic [WIDTH-1:0] VALUE_OUT;         // Data output
    logic VALID_DRV;                     // Driver valid flag
                                         // (set when driver applies transaction)

    //--------------------------------------------------------
    // Driver clocking block
    // Defines outputs driven by the driver
    //--------------------------------------------------------
    clocking drv_cb @(posedge CLK);
        output LOAD, LOAD_TMP, POP, POP_TMP, VALUE_IN, VALID_DRV;
    endclocking
    
    //--------------------------------------------------------
    // Monitor clocking block
    // Defines inputs sampled by the monitor
    //--------------------------------------------------------
    clocking mon_cb @(posedge CLK);
        input LOAD, POP, VALUE_IN, EMPTY, FULL, VALUE_OUT, VALID_DRV;
    endclocking

    //--------------------------------------------------------
    // Modports
    //--------------------------------------------------------
    // Driver modport: connects driver to driver clocking block
    modport drv_mp (clocking drv_cb);

    // Monitor modport: connects monitor to monitor clocking block
    modport mon_mp (clocking mon_cb);

    // DUT modport: connects DUT to interface signals
    modport dut_mp (
        input  LOAD, RST, POP, CLK, VALUE_IN,
        output EMPTY, FULL, VALUE_OUT
    );

endinterface