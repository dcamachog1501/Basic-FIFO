//------------------------------------------------------------
// FIFO Boundary Sequence
// Fills and empties the FIFO and performs operations at the 
// boundaries.
//------------------------------------------------------------

class FIFO_Boundary_Sequence extends uvm_sequence #(FIFO_Seq_Item#(FIFO_WIDTH));

    // Factory registration
    `uvm_object_utils(FIFO_Boundary_Sequence)

    // Constructor: set sequence name and transaction count
    function new(string name = "boundary_sequence");
        super.new(name);
    endfunction

    // Sequence body: create and send 'trans_amount' items
    task body();

        for (int i = 0; i < FIFO_LENGTH+1; i++) begin
            FIFO_Seq_Item #(FIFO_WIDTH) seq_item =FIFO_Seq_Item#(FIFO_WIDTH)::type_id::create(); // Create item via factory
            start_item(seq_item);                                                                // Handshake with sequencer
            seq_item.randomize();
            seq_item.LOAD = 1;
            seq_item.POP  = 0;
            finish_item(seq_item);                                                               // Send item to driver
        end

        for (int i = 0; i < FIFO_LENGTH+1; i++) begin
            FIFO_Seq_Item #(FIFO_WIDTH) seq_item =FIFO_Seq_Item#(FIFO_WIDTH)::type_id::create(); // Create item via factory
            start_item(seq_item);                                                                // Handshake with sequencer
            seq_item.randomize();
            seq_item.LOAD = 0;
            seq_item.POP  = 1;
            finish_item(seq_item);                                                               // Send item to driver
        end

        `uvm_info("BOUNDARY_SEQUENCE",
                  $sformatf("Finished generating boundary transactions"),
                  UVM_LOW)
    endtask

endclass