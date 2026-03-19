//------------------------------------------------------------
// FIFO Scoreboard
// Reference model for FIFO behavior.
// Compares DUT outputs against expected results and logs errors.
//------------------------------------------------------------

`include "fifo_ref_model.sv"

class FIFO_Scoreboard extends uvm_scoreboard;

    // Factory registration
    `uvm_component_utils(FIFO_Scoreboard)

    // Analysis implementation port
    uvm_analysis_imp #(FIFO_Seq_Item#(FIFO_WIDTH), FIFO_Scoreboard) sb_analysis_imp;

    FIFO_Ref_Model sb_queue;

    // Error reasons dictionary
    string reasons_dict [string];

    // Queue of error codes
    string errors_queue [$];

    // Last value popped from scoreboard FIFO
    bit [FIFO_WIDTH-1:0] last_popped_value;

    // Constructor: initialize reasons dictionary
    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);

        sb_queue = new();
        reasons_dict = '{
            "POP_NOT_FULL"            : "Popping from FIFO raised the FULL flag",
            "POP_EMPTY_NOT_EMPTY"     : "Popping from FIFO didn't raise EMPTY flag (FIFO is EMPTY)",
            "POP_FULL_STILL_FULL"     : "Popping from full FIFO didn't lower FULL flag",
            "POP_NOT_EMPTY"           : "Popping from non-empty FIFO raised EMPTY flag (FIFO isn't EMPTY)",
            "POP_MISMATCH"            : "Popped value didn't match scoreboard value",
            "LOAD_FULL_NOT_FULL"      : "Loading to FIFO didn't raise FULL flag (FIFO is FULL)",
            "LOAD_NOT_FULL"           : "Loading intermediate value raised FULL flag (FIFO isn't FULL)",
            "LOAD_NOT_EMPTY"          : "Loading raised EMPTY flag",
            "LOAD_OUTPUT_NOT_STEADY"  : "Loading changed output value"
        };
    endfunction

    // Build phase: create analysis implementation port
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_analysis_imp = new("sb_analysis_imp", this);
    endfunction

    // Write method: entry point for transactions
    function void write(FIFO_Seq_Item seq_item);
        bit errors_found = 0;

        FIFO_Seq_Item expected_result = perform_trans(seq_item);

        if (seq_item.POP)
            errors_found |= !check_pop(seq_item);

        if (seq_item.LOAD)
            errors_found |= !check_load(seq_item);

        if (errors_found)
            print_errors(seq_item, expected_result);
        else
            print_success(seq_item, expected_result);
    endfunction

    // Print success message
    function void print_success(FIFO_Seq_Item seq_item, FIFO_Seq_Item expected_result);
        `uvm_info("SCOREBOARD", "PASS! Received Transaction:", UVM_LOW)
        seq_item.print();
        $display("Expected Result:");
        expected_result.print();
    endfunction

    // Print error messages with reasons
    function void print_errors(FIFO_Seq_Item seq_item, FIFO_Seq_Item expected_result);
        `uvm_error("SCOREBOARD", "FAIL! Received Transaction:")
        seq_item.print();
        $display("Expected Result:");
        expected_result.print();
        $display("Errors Found:");

        while (errors_queue.size() > 0) begin
            string error_code = errors_queue.pop_front();
            $display("%s : %s", error_code, reasons_dict[error_code]);
        end
    endfunction

    // Perform transaction: update reference FIFO and generate expected result
    function FIFO_Seq_Item perform_trans(FIFO_Seq_Item seq_item);
        FIFO_Seq_Item #(FIFO_WIDTH) output_seq_item =
            FIFO_Seq_Item#(FIFO_WIDTH)::type_id::create();

        output_seq_item.LOAD     = seq_item.LOAD;
        output_seq_item.POP      = seq_item.POP;
        output_seq_item.VALUE_IN = seq_item.VALUE_IN;

        if (seq_item.POP) begin
            last_popped_value    = (sb_queue.is_empty()) ? 0 : sb_queue.pop_front();
            output_seq_item.VALUE_OUT = last_popped_value;
            output_seq_item.EMPTY     = sb_queue.is_empty();
            output_seq_item.FULL      = sb_queue.is_full();
        end

        if (seq_item.LOAD) begin
            sb_queue.push_back(seq_item.VALUE_IN);
            output_seq_item.VALUE_OUT = last_popped_value;
            output_seq_item.FULL      = sb_queue.is_full();
            output_seq_item.EMPTY     = sb_queue.is_empty();
        end

        return output_seq_item;
    endfunction

    // Check POP behavior
    function bit check_pop(FIFO_Seq_Item seq_item);
        if (seq_item.FULL)
            errors_queue.push_back("POP_NOT_FULL");

        if (sb_queue.is_empty() && ~seq_item.EMPTY)
            errors_queue.push_back("POP_EMPTY_NOT_EMPTY");

        if (~sb_queue.is_empty() && seq_item.EMPTY)
            errors_queue.push_back("POP_NOT_EMPTY");

        if (last_popped_value != seq_item.VALUE_OUT)
            errors_queue.push_back("POP_MISMATCH");

        return errors_queue.size() == 0;
    endfunction

    // Check LOAD behavior
    function bit check_load(FIFO_Seq_Item seq_item);
        if (seq_item.EMPTY)
            errors_queue.push_back("LOAD_NOT_EMPTY");

        if (sb_queue.is_full() && ~seq_item.FULL)
            errors_queue.push_back("LOAD_FULL_NOT_FULL");

        if (~sb_queue.is_full() && seq_item.FULL)
            errors_queue.push_back("LOAD_NOT_FULL");

        if (last_popped_value != seq_item.VALUE_OUT)
            errors_queue.push_back("LOAD_OUTPUT_NOT_STEADY");

        return errors_queue.size() == 0;
    endfunction
endclass