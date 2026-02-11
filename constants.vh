
//FIFO DEFAULT VALUES
parameter FIFO_LENGTH      = 16; 
parameter FIFO_WIDTH       = 1041;


// SIZE SELECTION PARAMETERS (Used for size selection accross the implementation)
parameter SIZE_BYTE        = 3'b000;
parameter SIZE_HALF_WORD   = 3'b001;
parameter SIZE_WORD        = 3'b010;
parameter SIZE_DOUBLE_WORD = 3'b011;
parameter SIZE_4_WORD      = 3'b100;
parameter SIZE_8_WORD      = 3'b101;
parameter SIZE_16_WORD     = 3'b110;
parameter SIZE_32_WORD     = 3'b111;

//BURST TYPE PARAMETERS (Used in FIFO to signal the required transaction type)

parameter IDLE             = 2'b00;
parameter SINGLE           = 2'b01;
parameter INCREMENTAL      = 2'b10;
parameter WRAPPING         = 2'b11;

