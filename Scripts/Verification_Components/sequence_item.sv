//------------------------------------------------------------
// FIFO Sequence Item
// Defines transaction fields for FIFO operations.
//------------------------------------------------------------

class FIFO_Seq_Item #(WIDTH = FIFO_WIDTH) extends uvm_sequence_item;

    // Transaction fields
    rand bit             LOAD, POP;          // Control signals
    bit                  EMPTY, FULL;        // Status flags
    rand bit [WIDTH-1:0] VALUE_IN;           // Input data
    bit      [WIDTH-1:0] VALUE_OUT;          // Output data
    bit                  RST;                // Reset Flag

    // Factory registration and field automation
    `uvm_object_utils_begin(FIFO_Seq_Item#(WIDTH))
        `uvm_field_int(LOAD,      UVM_ALL_ON)
        `uvm_field_int(POP,       UVM_ALL_ON)
        `uvm_field_int(EMPTY,     UVM_ALL_ON)
        `uvm_field_int(FULL,      UVM_ALL_ON)
        `uvm_field_int(VALUE_IN,  UVM_ALL_ON)
        `uvm_field_int(VALUE_OUT, UVM_ALL_ON)
        `uvm_field_int(RST, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "seq_item");
        super.new(name);
    endfunction

    // Convert transaction content to string
    function string convert2string();
        return $sformatf("RST:%0b LOAD:%0b POP:%0b EMPTY:%0b FULL:%0b VALUE_IN:%0h VALUE_OUT:%0h",RST,LOAD, POP, EMPTY, FULL, VALUE_IN, VALUE_OUT);
    endfunction

endclass