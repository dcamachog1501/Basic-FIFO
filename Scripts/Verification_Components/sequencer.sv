// UVM sequencer class for FIFO sequence items
class FIFO_Sequencer extends uvm_sequencer #(FIFO_Seq_Item);

    // Register this sequencer with the UVM factory
    `uvm_component_utils(FIFO_Sequencer)

    // Constructor: initializes the sequencer with a name and parent component
    function new(string name="FIFO_Sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass