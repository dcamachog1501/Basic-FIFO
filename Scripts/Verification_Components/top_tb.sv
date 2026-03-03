//------------------------------------------------------------
// Top-level Testbench (top_tb)
// Instantiates DUT, interface, clock, and launches UVM test.
//------------------------------------------------------------

`include "uvm_macros.svh"   // UVM macros

import uvm_pkg::*;          // UVM base package
import fifo_config_pkg::*;  // FIFO configuration parameters

// Include UVM component definitions
`include "interface.sv"
`include "sequence_item.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "sequence.sv"
`include "test.sv"

module top_tb;

    // Clock signal
    bit CLK;

    // Interface instantiation
    FIFO_if vif(.CLK(CLK));

    // DUT instantiation
    FIFO fifo (.inf(vif.dut_mp));

    // Clock generation: 20 time unit period
    initial begin
        CLK = 0;
        forever #10 CLK = ~CLK;
    end

    // UVM configuration and test invocation
    initial begin
        uvm_config_db#(virtual FIFO_if)::set(null, "*", "fifo_if", vif);
        run_test("FIFO_Test");
        $finish();
    end

    // Waveform dump setup
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end

endmodule