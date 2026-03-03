//------------------------------------------------------------
// FIFO Agent
// Encapsulates sequencer, driver, and monitor.
// Active: sequencer + driver + monitor
// Passive: monitor only
//------------------------------------------------------------

class FIFO_Agent extends uvm_component;

    // Factory registration
    `uvm_component_utils(FIFO_Agent)

    // Active/passive configuration flag
    bit is_active;

    // Sub-components
    FIFO_Sequencer sequencer;
    FIFO_Driver    driver;
    FIFO_Monitor   monitor;

    // Constructor
    function new(string name = "agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: create sub-components based on is_active
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(bit)::get(this, "", "is_active", is_active))
            `uvm_fatal("AGENT", "Active/passive configuration flag not found");

        if (is_active) begin
            `uvm_info("AGENT", "Agent set to ACTIVE", UVM_LOW);
            sequencer = FIFO_Sequencer::type_id::create("sequencer", this);
            driver    = FIFO_Driver::type_id::create("driver", this);
        end
        else begin
            `uvm_info("AGENT", "Agent set to PASSIVE", UVM_LOW);
        end

        monitor = FIFO_Monitor::type_id::create("monitor", this);
    endfunction

    // Connect phase: link sequencer to driver in active mode
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (is_active)
            driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass