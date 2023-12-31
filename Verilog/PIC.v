module PIC (
    // Bus
    input   wire           clk,
    input   wire           reset,
    input   wire           CS_n,
    input   wire           RD_n,
    input   wire           WR_n,
    input   wire           A0,
    input   wire   [7:0]   data_in,
    output  reg    [7:0]   data_out,
    output  reg            data_io,

    // I/O
    input   wire   [2:0]   cascade_in,
    output  wire    [2:0]   cascade_out,
    output  wire            cascade_io,

    input   wire            SP_EN_n,

    input   wire           INTA_n,
    output  wire            INT,

    input   wire   [7:0]   interrupt_req
);

    wire  [7:0]    internal_bus;
    wire           ICW_1;
    wire           ICW_2_4;
    wire           OCW_1;
    wire           OCW_2;
    wire           OCW_3;
    wire           read;

    Data_Bus Bus(.clk(clk),.reset(reset),.CS_n(CS_n),.RD_n(RD_n),.WR_n(WR_n),.A0(A0),.data_in(data_in),.internal_bus(internal_bus),.ICW_1(ICW_1),.ICW_2_4(ICW_2_4),.OCW_1(OCW_1),.OCW_2(OCW_2),.OCW_3(OCW_3),.read(read));

    //
    // Interrupt (Service) Control Logic
    //
    wire           control_logic_out_flag;
    wire   [7:0]   control_logic_data_out;
    wire           LTIM;
    wire           EN_RD_REG;
    wire           read_register_isr_or_irr;
    wire   [7:0]   interrupt;
    wire   [7:0]   highest_level_in_service;
    wire   [7:0]   interrupt_mask;
    wire   [7:0]   EOI;
    wire   [2:0]   priority_rotate;
    wire           freeze;
    wire           latch_in_service;
    wire   [7:0]   clear_interrupt_request;

    Control_Logic_3 Control_Logic (.clk(clk),.reset(reset),.cascade_in(cascade_in),.cascade_out(cascade_out),.cascade_io(cascade_io),.SP_EN_n(SP_EN_n),.INTA_n(INTA_n),.INT(INT),.internal_bus(internal_bus),.ICW_1(ICW_1),.ICW_2_4(ICW_2_4),.OCW_1(OCW_1),.OCW_2(OCW_2),.OCW_3(OCW_3),.read(read),.control_logic_out_flag(control_logic_out_flag),.control_logic_data_out(control_logic_data_out),.LTIM(LTIM),.EN_RD_REG(EN_RD_REG),.read_register_isr_or_irr(read_register_isr_or_irr),.interrupt(interrupt),.highest_level_in_service(highest_level_in_service),.interrupt_mask(interrupt_mask),.EOI(EOI),.freeze(freeze),.priority_rotate(priority_rotate),.latch_in_service(latch_in_service),.clear_interrupt_request(clear_interrupt_request));

    //
    // Interrupt Request
    //
    wire   [7:0]   interrupt_request_register;
    wire   [7:0]   in_service_register;
    
    PriorityResolver PR(.priority_rotate(priority_rotate),.interrupt_mask(interrupt_mask),.interrupt_req_reg(interrupt_request_register),.in_service_register(in_service_register),.interrupt(interrupt));
  
    InterruptRequestRegister IRR(.clk(clk),.reset(reset),.level_or_edge_triggered_mode(LTIM),.clear_ir_line(clear_interrupt_request),.freeze(freeze),.ir_req_pin(interrupt_req),.interrupt_req_reg(interrupt_request_register));

    //
    // In Service
    //
    In_Service_register ISR(.clk(clk),.reset(reset),.priority_rotate(priority_rotate),.interrupt(interrupt),.latch_in_service(latch_in_service),.end_of_interrupt(EOI),.in_service_register(in_service_register),.highest_level_in_service(highest_level_in_service));

    //
    // Data Bus Buffer & Read/Write Control Logic (2)
    //
    // Data bus
    always@(*) begin
        if (control_logic_out_flag == 1'b1) begin
            data_io  = 1'b0;
            data_out = control_logic_data_out;
        end
        else if (read == 1'b0) begin
            data_io  = 1'b1;
            data_out = 8'b00000000;
        end
        else if (A0 == 1'b1) begin
            data_io  = 1'b0;
            data_out = interrupt_mask;
        end
        else if ((EN_RD_REG == 1'b1) && (read_register_isr_or_irr == 1'b0)) begin //If 0 read IRR
            data_io  = 1'b0;
            data_out = interrupt_request_register;
        end
        else if ((EN_RD_REG == 1'b1) && (read_register_isr_or_irr == 1'b1)) begin //If 0 read ISR
            data_io  = 1'b0;
            data_out = in_service_register;
        end
        else begin
            data_io  = 1'b1;
            data_out = 8'b00000000;
        end
    end


endmodule
