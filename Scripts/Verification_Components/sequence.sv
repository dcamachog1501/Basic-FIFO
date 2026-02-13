// UVM sequence class for generating FIFO transactions
class FIFO_Sequence extends uvm_sequence #(FIFO_Seq_Item);

    // Number of transactions to generate in this sequence
    int trans_amount;

    // Register this sequence with the UVM factory
    `uvm_object_utils(FIFO_Sequence)

    // Constructor: allows specifying the number of transactions
    function new (string name="FIFO_Sequence", int trans_amount=0);
        super.new(name);
        this.trans_amount = trans_amount;
    endfunction

    // Main sequence behavior: generates 'trans_amount' transactions
    task body;

        // Loop to create and send the specified number of items
        for (int i = 0; i < this.trans_amount; i++) begin
            FIFO_Seq_Item seq_item = FIFO_Seq_Item::type_id::create(); // Creating the sequence_item to send (Using the Factory)
            start_item(seq_item);                                      // Handshake with sequencer
            seq_item.randomize();                                      // Randomize transaction fields
            finish_item(seq_item);                                     // Send item to driver
        end

        // Informational message once sequence completes
        `uvm_info("SEQUENCE",
                  $sformat("Finished Generating %0d Items", this.trans_amount),
                  UVM_LOW)

    endtask

endclass