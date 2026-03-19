class FIFO_Ref_Model;

    bit [FIFO_WIDTH-1:0] queue [$:FIFO_LENGTH];

    function bit [FIFO_WIDTH-1:0] pop_front();
        return this.queue.pop_front();
    endfunction

    function void push_back(bit [FIFO_WIDTH-1:0] value);
        this.queue.push_back(value);
    endfunction

    function bit is_empty();
        return this.queue.size() == 0;
    endfunction

    function bit is_full();
        return this.queue.size() == FIFO_LENGTH;
    endfunction

    function int get_occupancy();
        return this.queue.size();
    endfunction 

    function void reset();
        this.queue.delete();
    endfunction

endclass