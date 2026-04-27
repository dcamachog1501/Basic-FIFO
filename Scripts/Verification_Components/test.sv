//------------------------------------------------------------
// FIFO Test
// Top-level UVM test: instantiates environment, configures agent,
// runs sequence, and controls simulation duration.
//------------------------------------------------------------

class FIFO_Test extends uvm_test;

    // Factory registration
    `uvm_component_utils(FIFO_Test)

    // Sub-components
    FIFO_Environment        env;
    FIFO_Random_Sequence    random_seq;
    FIFO_Reset_Sequence     reset_seq;
    FIFO_Boundary_Sequence  boundary_seq;

    // Constructor
    function new(string name = "FIFO_Test", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: create environment and configure agent
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = FIFO_Environment::type_id::create("environment", this);
        uvm_config_db#(bit)::set(this, "environment.agent", "is_active", 1);
    endfunction

    // End of elaboration: log confirmation and print hierarchy
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        `uvm_info("TEST", "Finished building testbench", UVM_LOW);
        print();
    endfunction

    // Run phase: raise objection, run sequence, drop objection
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
        
        // DUT Restart Sequence (Assert RST for 5 posedge)
        `uvm_info("TEST", "Restarting DUT for 5 Cycles ...", UVM_LOW);

        reset_seq = FIFO_Reset_Sequence::type_id::create("reset_sequence");
        reset_seq.trans_amount = 5;
        reset_seq.start(env.agent.sequencer);

        // Main Sequence (Main Stimulus Generation Sequence)
        `uvm_info("TEST", "Executing Random Stimulus Sequence ...", UVM_LOW);
        
        random_seq = FIFO_Random_Sequence::type_id::create("random_sequence");
        random_seq.randomize();
        random_seq.start(env.agent.sequencer);
        
        // Resetting the DUT before procceding with the next stimulus
        reset_seq.start(env.agent.sequencer);

        // Boundary Sequence (Boundary Stimulus Generation Sequence)
        `uvm_info("TEST", "Executing Random Stimulus Sequence ...", UVM_LOW);
        
        boundary_seq = FIFO_Boundary_Sequence::type_id::create("boundary_sequence");
        boundary_seq.randomize();
        boundary_seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask

endclass