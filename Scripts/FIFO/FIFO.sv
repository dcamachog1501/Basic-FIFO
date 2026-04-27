//------------------------------------------------------------
// FIFO Module
// Parameterized FIFO implementation with LOAD, POP, and RST.
//------------------------------------------------------------

package fifo_config_pkg;
    parameter FIFO_LENGTH = 16;
    parameter FIFO_WIDTH  = 32;
endpackage

import fifo_config_pkg::*;

module FIFO #(
    parameter LENGTH = FIFO_LENGTH,  // Number of slots
    parameter WIDTH  = FIFO_WIDTH    // Slot width
)(
    FIFO_if.dut_mp inf               // DUT interface
);

    // FIFO storage
    reg [LENGTH-1:0][WIDTH-1:0] slots;

    // Control registers
    reg [$clog2(LENGTH):0]   taken_slots; // Occupied slots counter
    reg [$clog2(LENGTH)-1:0] read_ptr;    // Read pointer
    reg [$clog2(LENGTH)-1:0] write_ptr;   // Write pointer

    // Status flags
    assign inf.EMPTY = (taken_slots == 0);
    assign inf.FULL  = (taken_slots == LENGTH);

    // FIFO behavior
    always @(posedge inf.CLK or posedge inf.RST) begin
        if (inf.RST) begin
            taken_slots <= 0;
            read_ptr    <= 0;
            write_ptr   <= 0;
            inf.VALUE_OUT <= 0;
        end
        else begin
            
            // POP: retrieve oldest value if not EMPTY
            if (inf.POP) begin
                if (!inf.EMPTY) begin
                    inf.VALUE_OUT <= slots[read_ptr];
                    taken_slots   <= taken_slots - 1;
                    read_ptr      <= (read_ptr == LENGTH-1) ? 0 : (read_ptr + 1);
                end
                else begin
                    inf.VALUE_OUT <= 0;
                end
            end
            
            // LOAD: push new value if not FULL
            if (inf.LOAD & !inf.FULL) begin
                slots[write_ptr] <= inf.VALUE_IN;
                taken_slots      <= taken_slots + 1;
                write_ptr        <= (write_ptr == LENGTH-1) ? 0 : (write_ptr + 1);
            end
        end
    end
endmodule