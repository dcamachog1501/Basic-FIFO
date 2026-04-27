//------------------------------------------------------------
// FIFO Reference Model
// Behavioral model of a FIFO queue used for checking DUT behavior.
//------------------------------------------------------------
class FIFO_Ref_Model;

    // Internal storage: dynamic queue with maximum length FIFO_LENGTH
    // Each element is FIFO_WIDTH bits wide
    bit [FIFO_WIDTH-1:0] queue [$:FIFO_LENGTH];

    // Pop the front element from the queue and return it
    function bit [FIFO_WIDTH-1:0] pop_front();
        return this.queue.pop_front();
    endfunction

    // Push a new element to the back of the queue
    function void push_back(bit [FIFO_WIDTH-1:0] value);
        if(!is_full())
            this.queue.push_back(value);
    endfunction

    // Check if the queue is empty
    function bit is_empty();
        return this.queue.size() == 0;
    endfunction

    // Check if the queue is full (occupancy == FIFO_LENGTH)
    function bit is_full();
        return this.queue.size() == FIFO_LENGTH;
    endfunction

    // Return the current occupancy (number of elements stored)
    function int get_occupancy();
        return this.queue.size();
    endfunction 

    // Reset the queue by deleting all elements
    function void reset();
        this.queue.delete();
    endfunction

endclass