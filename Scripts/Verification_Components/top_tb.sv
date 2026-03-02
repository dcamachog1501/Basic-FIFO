//------------------------------------------------------------
// Top-level Testbench (top_tb)
// Instantiates DUT, interface, clock, and launches UVM test.
//------------------------------------------------------------
`include "uvm_macros.svh"             // UVM macros for registration/messaging
import uvm_pkg::*;                    // Import UVM package

module top_tb;

    // Clock signal
    bit CLK;

    // Instantiate interface and bind clock
    FIFO_if vif(.CLK(CLK));

    // Instantiate DUT and connect to interface modport
    FIFO fifo (.inf(vif.dut_mp));

    //--------------------------------------------------------
    // Clock generation: 20 time unit period
    //--------------------------------------------------------
    initial begin
        CLK = 0;
        forever #10 CLK = ~CLK;
    end

    //--------------------------------------------------------
    // UVM configuration and test invocation
    //--------------------------------------------------------
    initial begin
        // Provide virtual interface to UVM components via config DB
        uvm_config_db#(virtual FIFO_if)::set(null,"*","fifo_if",vif);

        // Run specified UVM test
        run_test("FIFO_Test");

        // End simulation cleanly
        $finish();
    end

endmodule