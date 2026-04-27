//------------------------------------------------------------
// FIFO Module
// Parameterized FIFO implementation with LOAD, POP, and RST.
//------------------------------------------------------------

// Package with FIFO configuration parameters
package fifo_config_pkg;
    parameter FIFO_LENGTH = 16;  // Default FIFO depth
    parameter FIFO_WIDTH  = 32;  // Default FIFO data width
endpackage

// Import configuration package
import fifo_config_pkg::*;

// FIFO module definition
module FIFO #(
    parameter LENGTH = FIFO_LENGTH,  // Number of slots in FIFO
    parameter WIDTH  = FIFO_WIDTH    // Width of each slot
)(
    FIFO_if.dut_mp inf               // DUT interface connection
);

    // Interface signal aliases
    wire LOAD;
    wire POP;
    wire EMPTY;
    wire FULL;
    wire CLK;
    wire RST;
    wire [WIDTH-1:0] VALUE_IN;
    reg  [WIDTH-1:0] VALUE_OUT;
    
    // FIFO storage array: LENGTH slots, each WIDTH bits wide
    reg [LENGTH-1:0][WIDTH-1:0] slots;

    // Control registers
    reg [$clog2(LENGTH):0]   taken_slots; // Counter for occupied slots
    reg [$clog2(LENGTH)-1:0] read_ptr;    // Read pointer index
    reg [$clog2(LENGTH)-1:0] write_ptr;   // Write pointer index

    // Status flags assignments
    assign inf.EMPTY = (taken_slots == 0);       // FIFO empty when no slots taken
    assign inf.FULL  = (taken_slots == LENGTH);  // FIFO full when all slots taken

    // Map interface signals to internal wires/regs
    assign LOAD          = inf.LOAD;
    assign POP           = inf.POP;
    assign EMPTY         = inf.EMPTY;
    assign FULL          = inf.FULL;
    assign CLK           = inf.CLK;
    assign RST           = inf.RST;
    assign VALUE_IN      = inf.VALUE_IN;
    assign inf.VALUE_OUT = VALUE_OUT;

    // FIFO behavior: synchronous logic with reset
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            // Reset FIFO state
            taken_slots <= 0;
            read_ptr    <= 0;
            write_ptr   <= 0;
            VALUE_OUT   <= 0;
        end
        else begin
            // POP operation: retrieve oldest value if not EMPTY
            if (POP) begin
                if (!EMPTY) begin
                    VALUE_OUT <= slots[read_ptr];
                    read_ptr  <= (read_ptr == LENGTH-1) ? 0 : (read_ptr + 1);
                end
                else begin
                    VALUE_OUT <= 0; // Output zero if POP attempted on empty FIFO
                end
            end
            
            // LOAD operation: push new value if not FULL
            if (LOAD & !FULL) begin
                slots[write_ptr] <= VALUE_IN;
                write_ptr        <= (write_ptr == LENGTH-1) ? 0 : (write_ptr + 1);
            end

            // Update occupied slots counter
            if (LOAD && (~POP && ~FULL || ~FULL && EMPTY))
                taken_slots <= taken_slots + 1;
            else if (POP && ~LOAD && ~EMPTY)
                taken_slots <= taken_slots - 1;
        end
    end
endmodule
