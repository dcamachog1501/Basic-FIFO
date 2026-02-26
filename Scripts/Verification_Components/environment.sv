//------------------------------------------------------------
// FIFO Environment
// UVM environment that encapsulates agent and scoreboard.
// Provides configuration knob to set agent active/passive.
//------------------------------------------------------------
class FIFO_Environment extends uvm_env;

    // Register component with UVM factory
    `uvm_component_utils(FIFO_Environment)

    // Sub-components of the environment
    FIFO_Agent      agent;
    FIFO_Scoreboard scoreboard;

    // Configuration knob: controls agent active/passive state
    bit is_agent_active;

    //--------------------------------------------------------
    // Constructor
    //--------------------------------------------------------
    function void new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    //--------------------------------------------------------
    // Build phase: create agent and scoreboard, configure agent
    //--------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create agent and scoreboard using factory
        this.agent      = FIFO_Agent::type_id::create("agent",this);
        this.scoreboard = FIFO_Scoreboard::type_id::create("scoreboard",this);

        // Retrieve agent active/passive configuration from config DB
        if(!uvm_config_db#(bit)::get(this,"","is_agent_active",this.is_agent_active)) begin
            // If missing, assume active state and log warning
            `uvm_info("ENVIRONMENT","[WARNING] Missing configuration for agent's configuration, assuming active state",UVM_LOW);
            uvm_config_db#(bit)::set(this,"agent","is_active",1);
        end
        else
            // Pass retrieved configuration to agent
            uvm_config_db#(bit)::set(this,"agent","is_active",this.is_agent_active);
    endfunction

    //--------------------------------------------------------
    // Connect phase: connect monitor analysis port to scoreboard
    //--------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Route transactions from monitor to scoreboard
        this.agent.monitor.mon_analysis_port.connect(this.scoreboard.sb_analysis_imp);
    endfunction

endclass