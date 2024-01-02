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
      // Parameter definitions for command states
    parameter CMD_READY = 2'b00;
    parameter WRITE_ICW2 = 2'b01;
    parameter WRITE_ICW3 = 2'b10;
    parameter WRITE_ICW4 = 2'b11;
    
    // Command state variables
    reg [1:0] cmd_state;
    reg [1:0] next_cmd_state;
// State machine    
    always@(*) begin
        if (ICW_1 == 1'b1)
            next_cmd_state = WRITE_ICW2;
        else if (ICW_2_4 == 1'b1) begin
            casez (cmd_state)
                WRITE_ICW2: begin
                    if (SNGL == 1'b0)
                        next_cmd_state = WRITE_ICW3;
                    else if (IC4 == 1'b1)
                        next_cmd_state = WRITE_ICW4;
                    else
                        next_cmd_state = CMD_READY;
                end
                WRITE_ICW3: begin
                    if (IC4 == 1'b1)
                        next_cmd_state = WRITE_ICW4;
                    else
                        next_cmd_state = CMD_READY;
                end
                WRITE_ICW4: begin
                    next_cmd_state = CMD_READY;
                end
                default: begin
                    next_cmd_state = CMD_READY;
                end
            endcase
        end
        else
            next_cmd_state = cmd_state;
    end

    always@(negedge clk, posedge reset) begin
        if (reset)
            cmd_state <= CMD_READY;
        else
            cmd_state <= next_cmd_state;
    end

    // Writing registers/command signals
    wire    ICW_2 = (cmd_state == WRITE_ICW2) & ICW_2_4;
    wire    ICW_3 = (cmd_state == WRITE_ICW3) & ICW_2_4;
    wire    ICW_4 = (cmd_state == WRITE_ICW4) & ICW_2_4;
    wire    OCW_1_registers = (cmd_state == CMD_READY) & OCW_1;
    wire    OCW_2_registers = (cmd_state == CMD_READY) & OCW_2;
    wire    OCW_3_registers = (cmd_state == CMD_READY) & OCW_3;

    
    // Parameter definitions for control states
    parameter CTL_READY = 3'b000;
    parameter ACK1 = 3'b001;
    parameter ACK2 = 3'b010;
    
    // Control state variables
    reg [2:0] ctrl_state;
    reg [2:0] next_ctrl_state;

    // Detect ACK edge
    reg   prev_INTA_n;

    always@(negedge clk, posedge reset) begin
        if (reset)
            prev_INTA_n <= 1'b1;
        else
            prev_INTA_n <= INTA_n;
    end
    wire    nedge_interrupt_acknowledge =  prev_INTA_n & ~INTA_n;
    wire    pedge_interrupt_acknowledge = ~prev_INTA_n &  INTA_n;

    // Detect read signal edge
    reg   prev_read_signal;

    always@(negedge clk, posedge reset) begin
        if (reset)
            prev_read_signal <= 1'b0;
        else
            prev_read_signal <= read;
    end
    wire    nedge_read_signal = prev_read_signal & ~read;

    // State machine
    always@(*) begin
        casez (ctrl_state)
            CTL_READY: begin
                if (OCW_2_registers == 1'b1)
                    next_ctrl_state = CTL_READY;
                else if (nedge_interrupt_acknowledge == 1'b0)
                    next_ctrl_state = CTL_READY;
                else
                    next_ctrl_state = ACK1;
            end
            ACK1: begin
                if (pedge_interrupt_acknowledge == 1'b0)
                    next_ctrl_state = ACK1;
                else
                    next_ctrl_state = ACK2;
            end
            ACK2: begin
                if (pedge_interrupt_acknowledge == 1'b0)
                    next_ctrl_state = ACK2;
                else
                    next_ctrl_state = CTL_READY;
            end

            default: begin
                next_ctrl_state = CTL_READY;
            end
        endcase
    end

    always@(negedge clk, posedge reset) begin
        if (reset)
            ctrl_state <= CTL_READY;
        else if (ICW_1 == 1'b1)
            ctrl_state <= CTL_READY;
        else
            ctrl_state <= next_ctrl_state;
    end

    // Latch in service register signal
    always@(*) begin
        if (ICW_1 == 1'b1)
            latch_in_service = 1'b0;
        else if (cascade_slave == 1'b0)
            latch_in_service = (ctrl_state == CTL_READY) & (next_ctrl_state != CTL_READY);
        else
            latch_in_service = (ctrl_state == ACK2) & (cascade_slave_enable == 1'b1) & (nedge_interrupt_acknowledge == 1'b1);
    end
    // End of acknowledge sequence
    wire    end_of_ack_sequence =  (ctrl_state != CTL_READY) & (next_ctrl_state == CTL_READY);

    //
    // Initialization command word 1
    //
    // A7-A5
    always@(negedge clk, posedge reset) begin
        if (reset)
            interrupt_vector_address[2:0] <= 3'b000;
        else if (ICW_1 == 1'b1)
            interrupt_vector_address[2:0] <= internal_bus[7:5];
        else
            interrupt_vector_address[2:0] <= interrupt_vector_address[2:0];
    end

    // LTIM
    always@(negedge clk, posedge reset) begin
        if (reset)
            LTIM <= 1'b0;
        else if (ICW_1 == 1'b1)
            LTIM <= internal_bus[3];
        else
            LTIM <= LTIM;
    end

    // ADI
    always@(negedge clk, posedge reset) begin
        if (reset)
            ADI <= 1'b0;
        else if (ICW_1 == 1'b1)
            ADI <= internal_bus[2];
        else
            ADI <= ADI;
    end

    // SNGL
    always@(negedge clk, posedge reset) begin
        if (reset)
            SNGL <= 1'b0;
        else if (ICW_1 == 1'b1)
            SNGL <= internal_bus[1];
        else
            SNGL <= SNGL;
    end

    // IC4
    always@(negedge clk, posedge reset) begin
        if (reset)
            IC4 <= 1'b0;
        else if (ICW_1 == 1'b1)
            IC4 <= internal_bus[0];
        else
            IC4 <= IC4;
    end

    //
    // Initialization command word 2
    //
    // A15-A8 (MCS-80) or T7-T3 (8086, 8088)
    always@(negedge clk, posedge reset) begin
        if (reset)
            interrupt_vector_address[10:3] <= 3'b000;
        else if (ICW_1 == 1'b1)
            interrupt_vector_address[10:3] <= 3'b000;
        else if (ICW_2 == 1'b1)
            interrupt_vector_address[10:3] <= internal_bus;
        else
            interrupt_vector_address[10:3] <= interrupt_vector_address[10:3];
    end

    //
    // Initialization command word 3
    //
    // S7-S0 (MASTER) or ID2-ID0 (SLAVE)
    always@(negedge clk, posedge reset) begin
        if (reset)
            cascade_device_config <= 8'b00000000;
        else if (ICW_1 == 1'b1)
            cascade_device_config <= 8'b00000000;
        else if (ICW_3 == 1'b1)
            cascade_device_config <= internal_bus;
        else
            cascade_device_config <= cascade_device_config;
    end


    // AEOI
    always@(negedge clk, posedge reset) begin
        if (reset)
            AEOI_config <= 1'b0;
        else if (ICW_1 == 1'b1)
            AEOI_config <= 1'b0;
        else if (ICW_4 == 1'b1)
            AEOI_config <= internal_bus[1];
        else
            AEOI_config <= AEOI_config;
    end
     //
    // Operation control words 
    //
    //
    // Operation control word 1
    //
    // IMR
    always@(negedge clk, posedge reset) begin
        if (reset)
            interrupt_mask <= 8'b11111111;
        else if (ICW_1 == 1'b1)
            interrupt_mask <= 8'b11111111;
        else if ((OCW_1_registers == 1'b1)) 
            interrupt_mask <= internal_bus;
        else
            interrupt_mask <= interrupt_mask;
    end

    //
    // Operation control word 2
    //
    // End of interrupt
    always@(*) begin
        if (ICW_1 == 1'b1)
            EOI = 8'b11111111;
        else if ((AEOI_config == 1'b1) && (end_of_ack_sequence == 1'b1))
            EOI = ack_interrupt;
        else if (OCW_2 == 1'b1) begin
            casez (internal_bus[6:5])
                2'b01:   EOI = highest_level_in_service;
                2'b11:   EOI = num2bit(internal_bus[2:0]);
                default: EOI = 8'b00000000;
            endcase
        end
        else
            EOI = 8'b00000000;
    end
// Auto rotate mode
    always@(negedge clk, posedge reset) begin
        if (reset)
            auto_rotate_mode <= 1'b0;
        else if (ICW_1 == 1'b1)
            auto_rotate_mode <= 1'b0;
        else if (OCW_2 == 1'b1) begin
            casez (internal_bus[7:5])
                3'b000:  auto_rotate_mode <= 1'b0;
                3'b100:  auto_rotate_mode <= 1'b1;
                default: auto_rotate_mode <= auto_rotate_mode;
            endcase
        end
        else
            auto_rotate_mode <= auto_rotate_mode;
    end

    // Rotate 
    always@(negedge clk, posedge reset) begin
        if (reset)
            priority_rotate <= 3'b111;
        else if (ICW_1 == 1'b1)
            priority_rotate <= 3'b111;
        else if ((auto_rotate_mode == 1'b1) && (end_of_ack_sequence == 1'b1))
            priority_rotate <= bit2num(ack_interrupt);
        else if (OCW_2 == 1'b1) begin
            casez (internal_bus[7:5])
                3'b101: begin  
                if      (highest_level_in_service[0] == 1'b1) priority_rotate = 3'b000;
                else if (highest_level_in_service[1] == 1'b1) priority_rotate = 3'b001;
                else if (highest_level_in_service[2] == 1'b1) priority_rotate = 3'b010;
                else if (highest_level_in_service[3] == 1'b1) priority_rotate = 3'b011;
                else if (highest_level_in_service[4] == 1'b1) priority_rotate = 3'b100;
                else if (highest_level_in_service[5] == 1'b1) priority_rotate = 3'b101;
                else if (highest_level_in_service[6] == 1'b1) priority_rotate = 3'b110;
                else if (highest_level_in_service[7] == 1'b1) priority_rotate = 3'b111;
                else                                          priority_rotate = 3'b111;
                end
                default: priority_rotate <= priority_rotate;
            endcase
        end
        else
            priority_rotate <= priority_rotate;
    end
    
    //
    // Operation control word 3
    //
    // RR/RIS
    always@(negedge clk, posedge reset) begin
        if (reset) begin
            EN_RD_REG     <= 1'b1;
            read_register_isr_or_irr <= 1'b0;
        end
        else if (ICW_1 == 1'b1) begin
            EN_RD_REG     <= 1'b1;
            read_register_isr_or_irr <= 1'b0;
        end
        else if (OCW_3_registers == 1'b1) begin
            EN_RD_REG     <= internal_bus[1];
            read_register_isr_or_irr <= internal_bus[0];
        end
        else begin
            EN_RD_REG     <= EN_RD_REG;
            read_register_isr_or_irr <= read_register_isr_or_irr;
        end
    end

     // Cascade signals  
    //
    // Select master/slave
    always@(*) begin
        if (SNGL == 1'b1)
            cascade_slave = 1'b0;
        else    
            cascade_slave = ~SP_EN_n;
    end

    // Cascade port I/O
    assign cascade_io = cascade_slave;

    //
    // Cascade signals (slave)
    //
    always@(*) begin
        if (cascade_slave == 1'b0)
            cascade_slave_enable = 1'b0;
        else if (cascade_device_config[2:0] != cascade_in)
            cascade_slave_enable = 1'b0;
        else
            cascade_slave_enable = 1'b1;
    end

    //
    // Cascade signals (master)  
    //
    wire    interrupt_from_slave_device = (ack_interrupt & cascade_device_config) != 8'b00000000;

    // output ACK2
    always@(*) begin
        if (SNGL == 1'b1)
            cascade_out_ack2 = 1'b1;
        else if (cascade_slave_enable == 1'b1)
            cascade_out_ack2 = 1'b1;
        else if ((cascade_slave == 1'b0) && (interrupt_from_slave_device == 1'b0))
            cascade_out_ack2 = 1'b1;
        else
            cascade_out_ack2 = 1'b0;
    end

// Output slave id
    always@(*) begin
        if (cascade_slave == 1'b1)
            cascade_out <= 3'b000;
        else if ((ctrl_state != ACK1) && (ctrl_state != ACK2))
            cascade_out <= 3'b000;
        else if (interrupt_from_slave_device == 1'b0)
            cascade_out <= 3'b000;
        else begin
            if (ack_interrupt[0] == 1'b1)
              control_logic_data_out[2:0] = 3'b000;
            else if (ack_interrupt[1] == 1'b1)
              control_logic_data_out[2:0] = 3'b001;
            else if (ack_interrupt[2] == 1'b1)
              control_logic_data_out[2:0] = 3'b010;
            else if (ack_interrupt[3] == 1'b1)
              control_logic_data_out[2:0] = 3'b011;
            else if (ack_interrupt[4] == 1'b1)
              control_logic_data_out[2:0] = 3'b100;
            else if (ack_interrupt[5] == 1'b1)
              control_logic_data_out[2:0] = 3'b101;
            else if (ack_interrupt[6] == 1'b1)
              control_logic_data_out[2:0] = 3'b110;
            else if (ack_interrupt[7] == 1'b1)
              control_logic_data_out[2:0] = 3'b111;
            else
              control_logic_data_out[2:0] = 3'b111;
        end
    end

    //
    // Interrupt control signals
    //
    // INT
    always@(negedge clk, posedge reset) begin
        if (reset)
            INT <= 1'b0;
        else if (ICW_1 == 1'b1)
            INT <= 1'b0;
        else if (interrupt != 8'b00000000)
            INT <= 1'b1;
        else if (end_of_ack_sequence == 1'b1)
            INT <= 1'b0;
        else
            INT <= INT;
    end

    // freeze
    always@(negedge clk, posedge reset) begin
        if (reset)
            freeze <= 1'b1;
        else if (next_ctrl_state == CTL_READY)
            freeze <= 1'b0;
        else
            freeze <= 1'b1;
    end

    // clear_interrupt_request
    always@(*) begin
        if (ICW_1 == 1'b1)
            clear_interrupt_request = 8'b11111111;
        else if (latch_in_service == 1'b0)
            clear_interrupt_request = 8'b00000000;
        else
            clear_interrupt_request = interrupt;
    end

    // interrupt buffer
    always@(negedge clk, posedge reset) begin
        if (reset)
            ack_interrupt <= 8'b00000000;
        else if (ICW_1 == 1'b1)
            ack_interrupt <= 8'b00000000;
        else if (end_of_ack_sequence)
            ack_interrupt <= 8'b00000000;
        else if (latch_in_service == 1'b1)
            ack_interrupt <= interrupt;
        else
            ack_interrupt <= ack_interrupt;
    end

    // interrupt buffer
    reg   [7:0]   interrupt_when_ack1;

    always@(negedge clk, posedge reset) begin
        if (reset)
            interrupt_when_ack1 <= 8'b00000000;
        else if (ICW_1 == 1'b1)
            interrupt_when_ack1 <= 8'b00000000;
        else if (ctrl_state == ACK1)
            interrupt_when_ack1 <= interrupt;
        else
            interrupt_when_ack1 <= interrupt_when_ack1;
    end
    // control_logic_data_out  
    always@(*) begin
        if (INTA_n == 1'b0) begin
            // Acknowledge
            casez (ctrl_state)
                CTL_READY: begin
                    if (cascade_slave == 1'b0) begin
                            control_logic_out_flag = 1'b0;
                            control_logic_data_out     = 8'b00000000;
                    end
                end
                ACK1: begin
                    if (cascade_slave == 1'b0) begin
                        control_logic_out_flag = 1'b0;
                        control_logic_data_out     = 8'b00000000;
                    end
                end
                ACK2: begin
                    if (cascade_out_ack2 == 1'b1) begin
                        control_logic_out_flag = 1'b1;
                            
                        if (cascade_slave == 1'b1) begin
                          if (interrupt_when_ack1[0] == 1'b1)
                            control_logic_data_out[2:0] = 3'b000;
                          else if (interrupt_when_ack1[1] == 1'b1)
                            control_logic_data_out[2:0] = 3'b001;
                          else if (interrupt_when_ack1[2] == 1'b1)
                            control_logic_data_out[2:0] = 3'b010;
                          else if (interrupt_when_ack1[3] == 1'b1)
                            control_logic_data_out[2:0] = 3'b011;
                          else if (interrupt_when_ack1[4] == 1'b1)
                            control_logic_data_out[2:0] = 3'b100;
                          else if (interrupt_when_ack1[5] == 1'b1)
                            control_logic_data_out[2:0] = 3'b101;
                          else if (interrupt_when_ack1[6] == 1'b1)
                            control_logic_data_out[2:0] = 3'b110;
                          else if (interrupt_when_ack1[7] == 1'b1)
                            control_logic_data_out[2:0] = 3'b111;
                          else
                            control_logic_data_out[2:0] = 3'b111;
                          end 
                          else begin
                          if (ack_interrupt[0] == 1'b1)
                              control_logic_data_out[2:0] = 3'b000;
                          else if (ack_interrupt[1] == 1'b1)
                              control_logic_data_out[2:0] = 3'b001;
                          else if (ack_interrupt[2] == 1'b1)
                              control_logic_data_out[2:0] = 3'b010;
                          else if (ack_interrupt[3] == 1'b1)
                              control_logic_data_out[2:0] = 3'b011;
                          else if (ack_interrupt[4] == 1'b1)
                              control_logic_data_out[2:0] = 3'b100;
                          else if (ack_interrupt[5] == 1'b1)
                              control_logic_data_out[2:0] = 3'b101;
                          else if (ack_interrupt[6] == 1'b1)
                              control_logic_data_out[2:0] = 3'b110;
                          else if (ack_interrupt[7] == 1'b1)
                              control_logic_data_out[2:0] = 3'b111;
                          else
                              control_logic_data_out[2:0] = 3'b111;
                          end 

                          control_logic_data_out = {interrupt_vector_address[10:6], control_logic_data_out[2:0]};
                    end
                    else begin
                        control_logic_out_flag = 1'b0;
                        control_logic_data_out     = 8'b00000000;
                    end
                end

                default: begin
                    control_logic_out_flag = 1'b0;
                    control_logic_data_out     = 8'b00000000;
                end
            endcase
        end
        end
endmodule
