module Control_Logic (
    input   wire           clk,
    input   wire           reset,

    // External input/output
    input   wire   [2:0]   cascade_in,
    output  reg    [2:0]   cascade_out,
    output  wire           cascade_io,

    input   wire           SP_EN_n,

    input   wire           INTA_n,
    output  reg            INT,

    // Internal bus
    input   wire   [7:0]   internal_bus,
    input   wire           ICW_1,
    input   wire           ICW_2_4,
    input   wire           OCW_1,
    input   wire           OCW_2,
    input   wire           OCW_3,

    input   wire           read,
    output  reg            control_logic_out_flag,
    output  reg    [7:0]   control_logic_data_out,

    // Registers to interrupt detecting logics
    output  reg            LTIM,

    // Registers to Read logics
    output  reg            EN_RD_REG,
    output  reg            read_register_isr_or_irr,

    // Signals from interrupt detectiong logics
    input   wire   [7:0]   interrupt,
    input   wire   [7:0]   highest_level_in_service,

    // Interrupt control signals
    output  reg    [7:0]   interrupt_mask,
    output  reg    [7:0]   EOI,
    output  reg            freeze,
    output  reg            latch_in_service,
    output  reg    [7:0]   clear_interrupt_request,
    output  reg    [2:0]   priority_rotate
);


    // Registers
    reg   [10:0]  interrupt_vector_address;
    reg           ADI;
    reg           SNGL;
    reg           IC4;
    reg   [7:0]   cascade_device_config;
    reg           AEOI_config;
    reg           auto_rotate_mode;
    reg   [7:0]   ack_interrupt;
    
    reg           cascade_slave;
    reg           cascade_slave_enable;
    reg           cascade_out_ack2;
    
    function [7:0] num2bit (input [2:0] source);
        casez (source)
            3'b000:  num2bit = 8'b00000001;
            3'b001:  num2bit = 8'b00000010;
            3'b010:  num2bit = 8'b00000100;
            3'b011:  num2bit = 8'b00001000;
            3'b100:  num2bit = 8'b00010000;
            3'b101:  num2bit = 8'b00100000;
            3'b110:  num2bit = 8'b01000000;
            3'b111:  num2bit = 8'b10000000;
            default: num2bit = 8'b00000000;
        endcase
    endfunction
    
    function [2:0] bit2num (input [7:0] source);
        if      (source[0] == 1'b1) bit2num = 3'b000;
        else if (source[1] == 1'b1) bit2num = 3'b001;
        else if (source[2] == 1'b1) bit2num = 3'b010;
        else if (source[3] == 1'b1) bit2num = 3'b011;
        else if (source[4] == 1'b1) bit2num = 3'b100;
        else if (source[5] == 1'b1) bit2num = 3'b101;
        else if (source[6] == 1'b1) bit2num = 3'b110;
        else if (source[7] == 1'b1) bit2num = 3'b111;
        else                        bit2num = 3'b111;
    endfunction
