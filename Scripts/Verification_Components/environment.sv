//------------------------------------------------------------
// FIFO Environment
// Encapsulates agent and scoreboard.
// Provides configuration knob to set agent active/passive.
//------------------------------------------------------------

class FIFO_Environment extends uvm_env;

    // Factory registration
    `uvm_component_utils(FIFO_Environment)

    // Sub-components
    FIFO_Agent      agent;
    FIFO_Scoreboard scoreboard;
    FIFO_Coverage_Collector cov_collector;

    // Active/passive configuration flag
    bit is_agent_active;

    // Constructor
    function new(string name = "environment", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: create agent and scoreboard, configure agent
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent      = FIFO_Agent::type_id::create("agent", this);
        scoreboard = FIFO_Scoreboard::type_id::create("scoreboard", this);
        cov_collector = FIFO_Coverage_Collector#(fifo_config_pkg::FIFO_WIDTH,fifo_config_pkg::FIFO_LENGTH)::type_id::create("coverage_collector", this);


        if (!uvm_config_db#(bit)::get(this, "", "is_agent_active", is_agent_active)) begin
            `uvm_info("ENVIRONMENT","Agent configuration not found, defaulting to ACTIVE",UVM_LOW);
            uvm_config_db#(bit)::set(this, "agent", "is_active", 1);
        end
        else begin
            uvm_config_db#(bit)::set(this, "agent", "is_active", is_agent_active);
        end
    endfunction

    // Connect phase: link monitor analysis port to scoreboard
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.mon_analysis_port.connect(scoreboard.sb_analysis_imp);
        agent.monitor.mon_analysis_port.connect(cov_collector.cov_analysis_imp);
    endfunction

endclass