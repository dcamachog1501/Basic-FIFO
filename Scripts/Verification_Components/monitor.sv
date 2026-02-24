//------------------------------------------------------------
// FIFO Monitor
// Observes DUT interface signals, creates sequence items,
// and broadcasts them via analysis port.
//------------------------------------------------------------
class FIFO_monitor extends uvm_monitor;

    // Register component with UVM factory
    `uvm_component_utils(FIFO_monitor)

    // Analysis port to send observed transactions to subscribers
    uvm_analysis_port #(FIFO_Seq_Item) mon_analysis_port;

    // Virtual interface handle to connect to DUT signals
    virtual FIFO_if fifo_if;

    //--------------------------------------------------------
    // Constructor
    //--------------------------------------------------------
    function new(string name="FIFO_Monitor", uvm_component parent);
        super.new(name,parent)
    endfunction

    //--------------------------------------------------------
    // Build phase: retrieve interface and create analysis port
    //--------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get virtual interface from config DB
        if(!uvm_config_db#(virtual FIFO_if)::get(null,"","fifo_if",this.fifo_if))
            `uvm_fatal("MONITOR","ABORTING -- Interface couldn't be retrieved!");
        
        // Create analysis port
        this.mon_analysis_port = new("mon_analysis_port",this);
    endfunction

    //--------------------------------------------------------
    // Run phase: continuously sample DUT signals
    //--------------------------------------------------------
    task void run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever
        begin
            // Synchronize to monitor clocking block
            @(this.fifo_if.mon_mp.mon_cb)

            // Only capture transaction when VALID_DRV is asserted
            if(this.fifo_if.mon_mp.mon_cb.VALID_DRV)
            begin
                // Create new sequence item
                FIFO_Seq_Item seq_item = FIFO_Seq_Item::type_id::create();

                // Sample DUT signals into sequence item
                seq_item.LOAD      = this.fifo_if.mon_mp.mon_cb.LOAD;
                seq_item.POP       = this.fifo_if.mon_mp.mon_cb.POP;
                seq_item.VALUE_IN  = this.fifo_if.mon_mp.mon_cb.VALUE_IN;
                seq_item.EMPTY     = this.fifo_if.mon_mp.mon_cb.EMPTY;
                seq_item.FULL      = this.fifo_if.mon_mp.mon_cb.FULL;
                seq_item.VALUE_OUT = this.fifo_if.mon_mp.mon_cb.VALUE_OUT;
                seq_item.VALID_DRV = this.fifo_if.mon_mp.mon_cb.VALID_DRV;

                // Print snooped transaction for debug
                `uvm_info("MONITOR",$sformatf("Snooped pkg: %s",seq_item.convert2string()),UVM_LOW);

                // Broadcast transaction to connected subscribers
                this.mon_analysis_port.write(seq_item);
            end
        end
    endtask

endclass