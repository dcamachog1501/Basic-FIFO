//------------------------------------------------------------
// FIFO Sequencer
// Provides sequence items to the driver.
//------------------------------------------------------------

class FIFO_Sequencer extends uvm_sequencer #(FIFO_Seq_Item#(FIFO_WIDTH));

    // Factory registration
    `uvm_component_utils(FIFO_Sequencer)

    // Constructor
    function new(string name = "FIFO_Sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass