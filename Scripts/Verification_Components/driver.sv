//------------------------------------------------------------
// FIFO Driver
// Drives DUT interface signals based on sequence items
// received from sequencer.
//------------------------------------------------------------
class FIFO_driver extends uvm_driver #(FIFO_Seq_Item);

    // Virtual interface handle to connect to DUT signals
    virtual FIFO_if fifo_if;

    // Register component with UVM factory
    `uvm_component_utils(FIFO_driver)

    //--------------------------------------------------------
    // Constructor
    //--------------------------------------------------------
    function new(string name="FIFO_Driver",uvm_component parent);
        super.new(name,parent);
    endfunction

    //--------------------------------------------------------
    // Build phase: retrieve interface from config DB
    //--------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get virtual interface from config DB
        if(!uvm_config_db#(virtual FIFO_if)::get(null,"","fifo_if",this.fifo_if))
            `uvm_fatal("DRIVER","ABORTING -- Interface couldn't be retrieved!");
    endfunction

    //--------------------------------------------------------
    // Run phase: main driver loop
    //--------------------------------------------------------
    task void run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever 
        begin
            // If reset is active, reset interface signals
            if(this.fifo_if.RST)
                this.reset_if();
            else
            begin
                // Try to get next sequence item from sequencer
                FIFO_Seq_Item seq_item;
                this.seq_item_port.try_next_item(seq_item);

                if(seq_item)
                begin
                    // Drive DUT interface with sequence item
                    this.drive_if(seq_item);

                    // Notify sequencer that item is done
                    this.seq_item_port.item_done();
                end
                else
                    // No item available, release interface
                    this.release_if();
            end
        end
    endtask

    //--------------------------------------------------------
    // Reset interface signals
    //--------------------------------------------------------
    task void reset_if();
        `uvm_info("DRIVER","Reseting Interface ...",UVM_LOW);

        this.fifo_if.drv_mp.LOAD      <= 0;
        this.fifo_if.drv_mp.POP       <= 0;
        this.fifo_if.drv_mp.VALUE_IN  <= 0;
        this.fifo_if.drv_mp.VALID_DRV <= 0;
    endtask

    //--------------------------------------------------------
    // Drive interface with sequence item
    //--------------------------------------------------------
    task void drive_if(FIFO_Seq_Item seq_item);
        // Synchronize to driver clocking block
        @(this.fifo_if.drv_cb);

        `uvm_info("DRIVER","Driving Interface ...",UVM_LOW);
        `uvm_info("DRIVER",seq_item.convert2string(),UVM_LOW);

        // Apply sequence item values to DUT interface
        this.fifo_if.drv_mp.LOAD      <= seq_item.LOAD;
        this.fifo_if.drv_mp.POP       <= seq_item.POP;
        this.fifo_if.drv_mp.VALUE_IN  <= seq_item.VALUE_IN;
        this.fifo_if.drv_mp.VALID_DRV <= 1;
    endtask

    //--------------------------------------------------------
    // Release interface (set signals to idle)
    //--------------------------------------------------------
    task void release_if ();
        // Synchronize to driver clocking block
        @(this.fifo_if.drv_cb);

        `uvm_info("DRIVER","Releasing Interface ...",UVM_LOW);
        
        // Clear signals
        this.fifo_if.drv_mp.LOAD      <= 0;
        this.fifo_if.drv_mp.POP       <= 0;
        this.fifo_if.drv_mp.VALUE_IN  <= 0;
        this.fifo_if.drv_mp.VALID_DRV <= 0;
    endtask

endclass