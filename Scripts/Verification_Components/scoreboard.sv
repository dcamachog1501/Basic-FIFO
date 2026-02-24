`include "../constants.vh"

//------------------------------------------------------------
// FIFO Scoreboard
// Reference model for FIFO behavior, compares DUT outputs
// against expected results and logs errors.
//------------------------------------------------------------
class FIFO_Scoreboard extends uvm_scoreboard;

    // Register component with UVM factory
    `uvm_component_utils(FIFO_Scoreboard)

    // Analysis implementation port to receive transactions
    uvm_analysis_imp #(FIFO_Seq_Item,FIFO_Scoreboard) sb_analysis_imp;

    // Reference FIFO queue (bounded to FIFO_LENGTH)
    bit[FIFO_WIDTH-1:0] sb_queue [$:FIFO_LENGTH];

    // Dictionary mapping error codes to human-readable reasons
    string reasons_dict [string];

    // Queue of error codes detected during checks
    string errors_queue [$];

    // Last value popped from the scoreboard FIFO
    bit[FIFO_WIDTH-1:0] last_popped_value;

    //--------------------------------------------------------
    // Constructor: initialize reasons dictionary
    //--------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name,parent);

        reasons_dict='{ "POP_NOT_FULL"             : "Popping from FIFO raised the FULL flag",
                        "POP_EMPTY_NOT_EMPTY"      : "Popping from FIFO didn't raise the EMPTY flag (FIFO is empty)",
                        "POP_FULL_STILL_FULL"      : "Popping from a full FIFO didn't lower the FULL flag",
                        "POP_NOT_EMPTY"            : "Popping from not empty FIFO raised the EMPTY flag (FIFO still has items)",
                        "POP_MIDDLE_RAISED_EMPTY"  : "Popping from a still populated FIFO raised the EMPTY flag (FIFO still has items)",
                        "POP_MIDDLE_RAISED_FULL"   : "Popping from the FIFO raised the FULL flag",
                        "POP_MISMATCH"             : "Popped value from FIFO didn't match SB's value",
                        "LOAD_FULL_NOT_FULL"       : "Loading to full FIfO didn't raised the FULL flag (FIFO is full)",
                        "LOAD_NOT_FULL"            : "Loading an intermediate value raised the FULL flag (FIFO is still not full)",
                        "LOAD_NOT_EMPTY"           : "Loading to the FIFO raised the EMPTY flag",
                        "LOAD_OUTPUT_NOT_STEADY"   : "Loading to the FIFO changed the output value"};
    endfunction

    //--------------------------------------------------------
    // Build phase: create analysis implementation port
    //--------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        this.sb_analysis_imp= new("sb_analysis_imp",this);
    endfunction

    //--------------------------------------------------------
    // Write method: main entry point for transactions
    //--------------------------------------------------------
    function void write(FIFO_Seq_Item seq_item);

        bit errors_found = 0;

        // Compute expected result from reference model
        FIFO_Seq_Item expected_result=this.perform_trans(seq_item);

        // Run checks depending on operation type
        if(seq_item.POP)
            errors_found |= !this.check_pop(seq_item);

        if (seq_item.LOAD)
            errors_found |= !this.check_load(seq_item);

        // Report results
        if(errors_found)
            this.print_errors(seq_item,expected_result);
        else
            this.print_success(seq_item,expected_result);
    endfunction
    
    //--------------------------------------------------------
    // Print success message
    //--------------------------------------------------------
    function void print_success(FIFO_Seq_Item seq_item, FIFO_Seq_Item expected_result);
        `uvm_info("SCOREBOARD", $sformatf("PASS! Received Transaction: "))
        seq_item.print();
        $display("Expected Result: ");
        expected_result.print();
    endfunction

    //--------------------------------------------------------
    // Print error messages with reasons
    //--------------------------------------------------------
    function void print_errors(FIFO_Seq_Item seq_item, FIFO_Seq_Item expected_result);
        `uvm_error("SCOREBOARD",$sformatf("FAIL! Received Transaction:"))
        seq_item.print();
        $display("Expected Result: ");
        expected_result.print();
        $display("Errors Found: ");

        while(this.errors_queue.size()>0)
        begin
            string error_code = this.errors_queue.pop_front();
            $display("%s : %s",error_code,this.reasons_dict[error_code])
        end
    endfunction

    //--------------------------------------------------------
    // Perform transaction: update reference FIFO and
    // generate expected result
    //--------------------------------------------------------
    function FIFO_Seq_Item perform_trans(FIFO_Seq_Item seq_item);

        FIFO_Seq_Item output_seq_item = new FIFO_Seq_Item();

        output_seq_item.LOAD     = seq_item.LOAD;
        output_seq_item.POP      = seq_item.POP;
        output_seq_item.VALUE_IN = seq_item.VALUE_IN;        

        // POP operation
        if(seq_item.POP)
        begin
            this.last_popped_value    = (this.is_empty())?0:this.sb_queue.pop_front();
            output_seq_item.VALUE_OUT = this.last_popped_value;
            output_seq_item.EMPTY     = this.is_empty();
            output_seq_item.FULL      = this.is_full();
        end

        // LOAD operation
        if (seq_item.LOAD)
        begin
            this.sb_queue.push_back(seq_item.VALUE_IN);
            output_seq_item.VALUE_OUT = this.last_popped_value;
            output_seq_item.FULL      = this.is_full();
            output_seq_item.EMPTY     = this.is_empty();
        end

        return output_seq_item;
    endfunction

    //--------------------------------------------------------
    // Check POP behavior against scoreboard model
    //--------------------------------------------------------
    function bit check_pop(FIFO_Seq_Item seq_item);

        // CASE 0: After a POP, FULL flag shouldn't be raised
        if(seq_item.FULL)
            this.errors_queue.push_back("POP_NOT_FULL");
        
        // CASE 1.1: If after popping the FIFO goes empty, EMPTY flag should be raised
        if(this.is_empty() && ~seq_item.EMPTY)
            this.errors_queue.push_back("POP_EMPTY_NOT_EMPTY");

        // CASE 1.2: If after popping FIFO not empty, EMPTY flag shouldn't be raised
        if(~this.is_empty() && seq_item.EMPTY)
            this.errors_queue.push_back("POP_NOT_EMPTY");

        // CASE 2: Popped value should match scoreboard's popped value
        if(this.last_popped_value != seq_item.VALUE_OUT)
            this.errors_queue.push_back("POP_MISMATCH");

        return this.errors_queue.size() == 0;
    endfunction

    //--------------------------------------------------------
    // Check LOAD behavior against scoreboard model
    //--------------------------------------------------------
    function bit check_load(FIFO_Seq_Item seq_item);

        // CASE 0: After a LOAD, EMPTY flag shouldn't be raised
        if(seq_item.EMPTY)
            this.errors_queue.push_back("LOAD_NOT_EMPTY");

        // CASE 1.1: If after loading FIFO goes full, FULL flag should be raised
        if(this.is_full() && ~seq_item.FULL)
            this.errors_queue.push_back("LOAD_FULL_NOT_FULL");

        // CASE 1.2: If after loading FIFO not full, FULL flag shouldn't be raised
        if(~this.is_full() && seq_item.FULL)
            this.errors_queue.push_back("LOAD_NOT_FULL");

        // CASE 2: When loading, FIFO output must remain steady
        if(this.last_popped_value != seq_item.VALUE_OUT)
            this.errors_queue.push_back("LOAD_OUTPUT_NOT_STEADY");

        return this.errors_queue.size() == 0;
    endfunction

    //--------------------------------------------------------
    // Utility: check if FIFO is empty
    //--------------------------------------------------------
    function bit is_empty();
        return this.sb_queue.size() == 0;
    endfunction

    //--------------------------------------------------------
    // Utility: check if FIFO is full
    //--------------------------------------------------------
    function bit is_full();
        return this.sb_queue.size() == FIFO_LENGTH;
    endfunction

endclass