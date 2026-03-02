`include "../constants.vh"   // Include shared constants (FIFO_LENGTH, FIFO_WIDTH)

module FIFO #(
    parameter LENGTH = FIFO_LENGTH,  // Number of slots in FIFO
    parameter WIDTH  = FIFO_WIDTH    // Width of each slot
)(
    FIFO_if.dut_mp inf //Passing interface
);

    // Packed array representing FIFO slots
    reg [LENGTH-1:0][WIDTH-1:0] slots;

    reg [$clog2(LENGTH):0]taken_slots;     // Counter for number of occupied slots
    reg [$clog2(LENGTH)-1:0]read_ptr;      // Pointer to the next value to be popped
    reg [$clog2(LENGTH)-1:0]write_ptr;     // Pointer to the next available slot

    // Status flags based on slot usage
    assign inf.EMPTY = (taken_slots == 0);
    assign inf.FULL  = (taken_slots == LENGTH);
    
    // Main FIFO behavior: triggered on LOAD, POP, or RST
    always @(posedge inf.CLK or posedge inf.RST) begin
        if (inf.RST) begin
            // Reset: Counter and pointers
            taken_slots <= 0;
            read_ptr    <= 0;
            write_ptr   <= 0;

            //Reset: Clear output value
            inf.VALUE_OUT   <= 0;
        end
        else begin
            // LOAD operation: push new value if not FULL
            if (inf.LOAD & !inf.FULL) begin
                slots[write_ptr] <= inf.VALUE_IN;
                taken_slots      <= taken_slots + 1;
                write_ptr        <= (write_ptr == LENGTH-1)? 0 : (write_ptr+1) ;
            end

            // POP operation: retrieve oldest value if not EMPTY
            if (inf.POP) begin
                if (!inf.EMPTY) begin
                    inf.VALUE_OUT    <= slots[read_ptr]; // Output oldest slot
                    taken_slots      <= taken_slots - 1;
                    read_ptr         <= (read_ptr == LENGTH-1)? 0: (read_ptr+1) ;
                end
                else begin
                    inf.VALUE_OUT    <= 0; // If empty, output zero
                end
            end
        end
    end

endmodule