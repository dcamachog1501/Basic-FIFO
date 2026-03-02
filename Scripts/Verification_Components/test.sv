//------------------------------------------------------------
// FIFO Test
// Top-level UVM test: instantiates environment, configures agent,
// runs sequence, and controls simulation duration.
//------------------------------------------------------------
class FIFO_Test extends uvm_test;

    // Register test with UVM factory
    `uvm_component_utils(FIFO_Test)

    // Sub-components
    FIFO_Environment env;
    FIFO_Sequence    seq;

    //--------------------------------------------------------
    // Constructor
    //--------------------------------------------------------
    function new(string name = "FIFO_Test", uvm_component parent);
        super.new(name,parent);
    endfunction

    //--------------------------------------------------------
    // Build phase: create environment and configure agent
    //--------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create environment using factory
        this.env = FIFO_Environment::type_id::create("environment",this);

        // Configure agent to active mode
        uvm_config_db#(bit)::set(this,"environment.agent","is_active",1);
    endfunction

    //--------------------------------------------------------
    // End of elaboration: log confirmation and print hierarchy
    //--------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        `uvm_info("TEST","Finished Building TB!",UVM_LOW);
        print(); // Print component hierarchy for debugging
    endfunction

    //--------------------------------------------------------
    // Run phase: raise objection, run sequence, drop objection
    //--------------------------------------------------------
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        // Keep simulation alive
        phase.raise_objection(this);

        // Create and configure sequence
        this.seq = FIFO_Sequence::type_id::create("sequence");
        this.seq.trans_amount = 32;

        // Start sequence on agent’s sequencer
        this.seq.start(this.env.agent.sequencer);

        // Allow phase to end once sequence completes
        phase.drop_objection(this);
    endtask

endclass