`include "../constants.vh"   // Include shared constants (FIFO_LENGTH, FIFO_WIDTH)

// UVM sequence item class for FIFO transactions
class FIFO_Seq_Item #(WIDTH=FIFO_WIDTH) extends uvm_sequence_item;

    // Transaction fields
    rand bit             LOAD, POP;          // Control signals: load and pop
    bit                  EMPTY, FULL;        // Status flags: empty and full
    rand bit [WIDTH-1:0] VALUE_IN;           // Input data value
    rand bit [WIDTH-1:0] VALUE_OUT;          // Output data value

    // Register fields with UVM factory and automation
    `uvm_object_utils_begin(FIFO_Seq_Item)
        `uvm_field_int(LOAD,      UVM_ALL_ON)   // Register LOAD as integral field
        `uvm_field_int(POP,       UVM_ALL_ON)   // Register POP as integral field
        `uvm_field_int(EMPTY,     UVM_ALL_ON)   // Register EMPTY as integral field
        `uvm_field_int(FULL,      UVM_ALL_ON)   // Register FULL as integral field
        `uvm_field_int(VALUE_IN,  UVM_ALL_ON)   // Register VALUE_IN as integral field
        `uvm_field_int(VALUE_OUT, UVM_ALL_ON)   // Register VALUE_OUT as integral field
    `uvm_object_utils_end

    // Constructor
    function new(string name = "FIFO_Seq_Item");
        super.new(name);
    endfunction

    // Convert transaction content to string for debug/printing
    function string convert2string();
        return $sformat(
            "TRANS CONTENT -- LOAD : %0b , POP : %0b , EMPTY : %0b , FULL : %0b , VALUE_IN : %0h , VALUE_OUT : %0h"
        );
    endfunction

endclass