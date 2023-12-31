module Data_Bus (
    input   wire           clk,
    input   wire           reset,

    input   wire           CS_n,
    input   wire           RD_n,
    input   wire           WR_n,
    input   wire           A0,
    input   wire   [7:0]   data_in,

    // Internal Bus
    output  reg    [7:0]   internal_bus,
    output  wire           ICW_1,
    output  wire           ICW_2_4,
    output  wire           OCW_1,
    output  wire           OCW_2,
    output  wire           OCW_3,
    output  wire           read
);

    //
    // Internal Signals
    //
    
    reg   stable_A0;
    reg prev_WR_n;
    wire write_flag;
    
    //
    // Write Control
    //
    always@(negedge clk, posedge reset) begin
        if (reset)
            internal_bus <= 8'b00000000;
        else if (~WR_n & ~CS_n)
            internal_bus <= data_in;
        else
            internal_bus <= internal_bus;
    end

    always@(negedge clk, posedge reset) begin
        if (reset)
            prev_WR_n <= 1'b1;
        else if (CS_n)
            prev_WR_n <= 1'b1;
        else
            prev_WR_n <= WR_n;
    end
    
    assign write_flag = ~prev_WR_n & WR_n;


    always@(negedge clk, posedge reset) begin
        if (reset)
            stable_A0 <= 1'b0;
        else
            stable_A0 <= A0;
    end

    // Generate write request flags
    assign ICW_1   = write_flag & ~stable_A0 & internal_bus[4];
    assign ICW_2_4 = write_flag & stable_A0;
    assign OCW_1   = write_flag & stable_A0;
    assign OCW_2   = write_flag & ~stable_A0 & ~internal_bus[4] & ~internal_bus[3];
    assign OCW_3   = write_flag & ~stable_A0 & ~internal_bus[4] & internal_bus[3];

    //
    // Read Control
    //
    assign read = ~RD_n  & ~CS_n;

endmodule



