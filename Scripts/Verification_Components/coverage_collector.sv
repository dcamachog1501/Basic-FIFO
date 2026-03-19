class FIFO_Coverage_Collector #(parameter int WIDTH = fifo_config_pkg::FIFO_WIDTH,
                                parameter int LENGTH = fifo_config_pkg::FIFO_LENGTH)
    extends uvm_subscriber#(FIFO_Seq_Item#(WIDTH));

    `uvm_component_param_utils(FIFO_Coverage_Collector#(WIDTH,LENGTH))

    FIFO_Ref_Model ref_queue;
    FIFO_Seq_Item#(WIDTH) eval_seq_item;
    uvm_analysis_imp #(FIFO_Seq_Item#(WIDTH), FIFO_Coverage_Collector#(WIDTH,LENGTH)) cov_analysis_imp;



    covergroup flag_cg;

        flag_EMPTY_cp       : coverpoint eval_seq_item.EMPTY iff (!eval_seq_item.RST);
        flag_FULL_cp        : coverpoint eval_seq_item.FULL iff (!eval_seq_item.RST);

        flag_EMPTY_trans_cp : coverpoint eval_seq_item.EMPTY iff (!eval_seq_item.RST) {
                                        bins trans_01 = (0 => 1);
                                        bins trans_10 = (1 => 0);} 

        flag_FULL_trans_cp  : coverpoint eval_seq_item.FULL  iff (!eval_seq_item.RST) {
                                        bins trans_01 = (0 => 1);
                                        bins trans_10 = (1 => 0);}
    endgroup

    covergroup input_control_cg;

        input_LOAD_cp : coverpoint eval_seq_item.LOAD iff (!eval_seq_item.RST);
        input_POP_cp  : coverpoint eval_seq_item.POP iff (!eval_seq_item.RST);

    endgroup

    covergroup reset_cg;

        reset_EMPTY_cp        : coverpoint eval_seq_item.EMPTY  iff (eval_seq_item.RST) { bins EMPTY_HIGH = {1};
                                                                                          illegal_bins  EMPTY_LOW  = {0};}

        reset_FULL_cp         : coverpoint eval_seq_item.FULL iff (eval_seq_item.RST) { bins FULL_LOW = {0};
                                                                                        illegal_bins  FULL_HIGH = {1};}

        reset_VALUE_OUT_cp   : coverpoint eval_seq_item.VALUE_OUT iff (eval_seq_item.RST) { bins VALUE_OUT_0 = {0};
                                                                                            illegal_bins  VALUE_OUT_NOT_0 = {[1:$]};}

        reset_RST_cp         : coverpoint eval_seq_item.RST iff (eval_seq_item.RST) { bins RST_HIGH = {1};} 

        cross_RST_conditions : cross reset_EMPTY_cp,reset_FULL_cp,reset_RST_cp,reset_VALUE_OUT_cp;

    endgroup

    covergroup occupancy_cg;

        occupancy_cp : coverpoint ref_queue.get_occupancy()  iff(!eval_seq_item.RST) {
                bins empty = {0};
                bins low_occupancy  = {[1:LENGTH/2-1]};
                bins mid_occupancy  = {LENGTH/2};
                bins high_occupancy = {[(LENGTH/2)+1:LENGTH-1]};
                bins full_occupancy = {LENGTH};
        }
        
        cross_occupancy : cross occupancy_cp,eval_seq_item.POP,eval_seq_item.LOAD;

    endgroup

    covergroup simultaneous_ops_cg;

        sim_ops_cp : coverpoint {eval_seq_item.LOAD,eval_seq_item.POP}  iff (!eval_seq_item.RST) {
                bins only_pop  = {2'b10};
                bins only_load = {2'b01};
                bins both_ops  = {2'b11};
        }

    endgroup

    covergroup boundary_ops_cg;

        load_when_full_cp: coverpoint eval_seq_item.LOAD iff(!eval_seq_item.RST && ref_queue.is_full());
        pop_when_empty_cp: coverpoint eval_seq_item.POP  iff(!eval_seq_item.RST && ref_queue.is_empty());

    endgroup

    function new(string name = "coverage_collector", uvm_component parent);
        super.new(name,parent);

        this.ref_queue = new();

        cov_analysis_imp = new("cov_analysis_imp", this);

        this.flag_cg = new();
        this.input_control_cg = new();
        this.reset_cg = new();
        this.occupancy_cg = new();
        this.simultaneous_ops_cg = new();
        this.boundary_ops_cg = new();
    endfunction

  function void write(FIFO_Seq_Item t);

        eval_seq_item = t;
        
    if(eval_seq_item.RST)
            this.ref_queue.reset();

        else
        begin
          if(eval_seq_item.LOAD)
            this.ref_queue.push_back(eval_seq_item.VALUE_IN);

          if(eval_seq_item.POP)
                this.ref_queue.pop_front();
        end
        this.flag_cg.sample();
        this.input_control_cg.sample();
        this.reset_cg.sample();
        this.occupancy_cg.sample();
        this.simultaneous_ops_cg.sample();
        this.boundary_ops_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
     `uvm_info(get_full_name(),$sformatf("Coverage for flag_cg: %0.2f %%", this.flag_cg.get_coverage()),UVM_LOW);
     `uvm_info(get_full_name(),$sformatf("Coverage for input_control_cg: %0.2f %%", this.input_control_cg.get_coverage()),UVM_LOW);
     `uvm_info(get_full_name(),$sformatf("Coverage for reset_cg: %0.2f %%", this.reset_cg.get_coverage()),UVM_LOW);
     `uvm_info(get_full_name(),$sformatf("Coverage for occupancy_cg: %0.2f %%", this.occupancy_cg.get_coverage()),UVM_LOW);
     `uvm_info(get_full_name(),$sformatf("Coverage for simultaneous_ops_cg: %0.2f %%", this.simultaneous_ops_cg.get_coverage()),UVM_LOW);
     `uvm_info(get_full_name(),$sformatf("Coverage for boundary_ops_cg: %0.2f %%", this.boundary_ops_cg.get_coverage()),UVM_LOW);
     endfunction

endclass