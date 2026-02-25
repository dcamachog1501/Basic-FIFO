//------------------------------------------------------------
// FIFO Agent
// UVM agent that encapsulates sequencer, driver, and monitor.
// Active agents: sequencer + driver + monitor
// Passive agents: monitor only
//------------------------------------------------------------
class FIFO_Agent extends uvm_component;

    // Register component with UVM factory
    `uvm_component_utils(FIFO_Agent)

    // Active/passive configuration flag
    bit is_active;

    // Sub-components of the agent
    FIFO_Sequencer sequencer;
    FIFO_Driver    driver;
    FIFO_Monitor   monitor;

    //--------------------------------------------------------
    // Constructor
    //--------------------------------------------------------
    function new (string name = "FIFO_Agent", uvm_component parent);
        super.new(name,parent);
    endfunction

    //--------------------------------------------------------
    // Build phase: create sub-components based on is_active
    //--------------------------------------------------------
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        // Retrieve active/passive configuration from config DB
        if(!uvm_config_db#(bit)::get(this,"","is_active",this.is_active))
            `uvm_fatal("AGENT","-- ABORTING: Unable to retreive active configuration flag");
        
        // Active agent: create sequencer and driver
        if(this.is_active) begin
            `uvm_info("AGENT","Setting agent to ACTIVE",UVM_LOW);
            this.sequencer = FIFO_Sequencer::type_id::create("sequencer",this);
            this.driver    = FIFO_Driver::type_id::create("driver",this);
        end
        else
            `uvm_info("AGENT","Setting agent to PASSIVE",UVM_LOW);
        
        // Monitor is always created (both active and passive)
        this.monitor = FIFO_Monitor::type_id::create("monitor",this);
    endfunction

    //--------------------------------------------------------
    // Connect phase: connect sequencer to driver in active mode
    //--------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if(this.is_active)
            this.driver.seq_item_port.connect(this.sequencer.seq_item_export);
    endfunction

endclass