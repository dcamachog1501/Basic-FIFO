//------------------------------------------------------------
// FIFO Driver
// Drives DUT interface signals based on sequence items
// received from sequencer.
//------------------------------------------------------------

class FIFO_Driver extends uvm_driver #(FIFO_Seq_Item#(FIFO_WIDTH));

    // Virtual interface handle
    virtual FIFO_if fifo_if;

    // Factory registration
    `uvm_component_utils(FIFO_Driver)

    // Constructor
    function new(string name = "driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: retrieve interface from config DB
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual FIFO_if)::get(null, "", "fifo_if", fifo_if))
            `uvm_fatal("DRIVER", "Interface could not be retrieved");
    endfunction

    // Run phase: main driver loop
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            if (fifo_if.RST)
                reset_if();
            else begin
                FIFO_Seq_Item seq_item;
                seq_item_port.try_next_item(seq_item);

                if (seq_item) begin
                    drive_if(seq_item);
                    seq_item_port.item_done();
                end
                else
                    release_if();
            end
        end
    endtask

    // Reset interface signals
    task reset_if();
        `uvm_info("DRIVER", "Resetting interface", UVM_LOW);

        fifo_if.drv_mp.drv_cb.LOAD      <= 0;
        fifo_if.drv_mp.drv_cb.POP       <= 0;
        fifo_if.drv_mp.drv_cb.VALUE_IN  <= 0;
        fifo_if.drv_mp.drv_cb.VALID_DRV <= 0;
    endtask

    // Drive interface with sequence item
    task drive_if(FIFO_Seq_Item seq_item);
        @(fifo_if.drv_cb);

        `uvm_info("DRIVER", "Driving interface", UVM_LOW);
        `uvm_info("DRIVER", seq_item.convert2string(), UVM_LOW);

        fifo_if.drv_mp.drv_cb.LOAD      <= seq_item.LOAD;
        fifo_if.drv_mp.drv_cb.POP       <= seq_item.POP;
        fifo_if.drv_mp.drv_cb.VALUE_IN  <= seq_item.VALUE_IN;
        fifo_if.drv_mp.drv_cb.VALID_DRV <= 1;
    endtask

    // Release interface (set signals to idle)
    task release_if();
        @(fifo_if.drv_cb);

        `uvm_info("DRIVER", "Releasing interface", UVM_LOW);

        fifo_if.drv_mp.drv_cb.LOAD      <= 0;
        fifo_if.drv_mp.drv_cb.POP       <= 0;
        fifo_if.drv_mp.drv_cb.VALUE_IN  <= 0;
        fifo_if.drv_mp.drv_cb.VALID_DRV <= 0;
    endtask

endclass