//------------------------------------------------------------
// FIFO Monitor
// Observes DUT interface signals, creates sequence items,
// and broadcasts them via analysis port.
//------------------------------------------------------------

class FIFO_Monitor extends uvm_monitor;

    // Factory registration
    `uvm_component_utils(FIFO_Monitor)

    // Analysis port for observed transactions
    uvm_analysis_port #(FIFO_Seq_Item#(FIFO_WIDTH)) mon_analysis_port;

    // Virtual interface handle
    virtual FIFO_if fifo_if;

    // Constructor
    function new(string name = "monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: retrieve interface and create analysis port
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual FIFO_if)::get(null, "", "fifo_if", fifo_if))
            `uvm_fatal("MONITOR", "Interface could not be retrieved");

        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    // Run phase: sample DUT signals and broadcast transactions
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            @(fifo_if.mon_mp.mon_cb);

            if (fifo_if.mon_mp.mon_cb.VALID_DRV) begin
                FIFO_Seq_Item #(FIFO_WIDTH) seq_item =FIFO_Seq_Item#(FIFO_WIDTH)::type_id::create();
				
              	seq_item.RST       = fifo_if.mon_mp.mon_cb.RST;
                seq_item.LOAD      = fifo_if.mon_mp.mon_cb.LOAD;
                seq_item.POP       = fifo_if.mon_mp.mon_cb.POP;
                seq_item.VALUE_IN  = fifo_if.mon_mp.mon_cb.VALUE_IN;
                seq_item.EMPTY     = fifo_if.mon_mp.mon_cb.EMPTY;
                seq_item.FULL      = fifo_if.mon_mp.mon_cb.FULL;
                seq_item.VALUE_OUT = fifo_if.mon_mp.mon_cb.VALUE_OUT;

                `uvm_info("MONITOR",$sformatf("Snooped transaction: %s",seq_item.convert2string()),UVM_LOW);
                
                mon_analysis_port.write(seq_item);
            end
        end
    endtask

endclass