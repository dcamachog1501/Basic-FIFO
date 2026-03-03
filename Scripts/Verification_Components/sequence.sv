//------------------------------------------------------------
// FIFO Sequence
// Generates a specified number of FIFO transactions.
//------------------------------------------------------------

class FIFO_Sequence extends uvm_sequence #(FIFO_Seq_Item#(FIFO_WIDTH));

    // Number of transactions to generate
    int trans_amount;

    // Factory registration
    `uvm_object_utils(FIFO_Sequence)

    // Constructor: set sequence name and transaction count
    function new(string name = "sequence");
        super.new(name);
    endfunction

    // Sequence body: create and send 'trans_amount' items
    task body();
        for (int i = 0; i < this.trans_amount; i++) begin
            FIFO_Seq_Item #(FIFO_WIDTH) seq_item =
                FIFO_Seq_Item#(FIFO_WIDTH)::type_id::create(); // Create item via factory

            start_item(seq_item);   // Handshake with sequencer
            seq_item.randomize();   // Randomize transaction fields
            finish_item(seq_item);  // Send item to driver
        end

        `uvm_info("SEQUENCE",
                  $sformatf("Finished generating %0d items", this.trans_amount),
                  UVM_LOW)
    endtask

endclass