`timescale 1ns/1ps
`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module PIC_tb;

    // Parameters
    parameter   CLOCK_PERIOD = 10; // Clock period in time units

    // Signals
    reg         clk;
    reg         reset;
    reg         chip_select_n;
    reg         read_enable_n;
    reg         write_enable_n;
    reg         address;
    reg  [7:0]  data_bus_in;
    wire [7:0]  data_bus_out;
    wire        data_bus_io;
    reg  [2:0]  cascade_in;
    wire [2:0]  cascade_out;
    wire        cascade_io;
    reg        slave_program_or_enable_buffer;
    reg         interrupt_acknowledge_n;
    wire        interrupt_to_cpu;
    reg  [7:0]  interrupt_request;

    // Instantiate the PIC module
    PIC pic (.clk(clk),.reset(reset),.CS_n(chip_select_n),.RD_n(read_enable_n),.WR_n(write_enable_n),.A0(address),.data_in(data_bus_in),.data_out(data_bus_out),.data_io(data_bus_io),.cascade_in(cascade_in),.cascade_out(cascade_out),.cascade_io(cascade_io),.SP_EN_n(slave_program_or_enable_buffer),.INTA_n(interrupt_acknowledge_n),.INT(interrupt_to_cpu),.interrupt_req(interrupt_request));

    // Clock Generation
    initial begin
        clk = 1;
        forever #CLOCK_PERIOD clk = ~clk;
    end

    // Stimulus
    initial begin
       
        
        //Intialization
        #(`TB_CYCLE * 0);
        chip_select_n           = 1'b1;
        read_enable_n           = 1'b1;
        write_enable_n          = 1'b1;
        address                 = 1'b0;
        data_bus_in             = 8'b00000000;
        cascade_in              = 3'b000;
        interrupt_acknowledge_n = 1'b1;
        interrupt_request       = 8'b00000000;
        reset                   = 1'b1;
        #(`TB_CYCLE * 12);
//240        
        //ICW1
        #(`TB_CYCLE * 0);
        reset           = 1'b0;
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 0;
        data_bus_in     = 8'b00011111;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        //data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
 // 280      
        //ICW2
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b10001000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 320        
        //ICW3
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b00000001;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 360
        //ICW4
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b00000001;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
  //      data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 400
        //OCW1
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b00000001;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
      //  data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 440        
        //OCW3
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b0;
        data_bus_in     = 8'b00001010;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 480   
  
        // Single bit Interrupt
        //Interrupt
        #(`TB_CYCLE * 0);
        interrupt_request = 8'b00000100;
        #(`TB_CYCLE * 1);
       // interrupt_request = 8'b00000000;
// 500     

        //Send ACK
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;

        
        //SEND_NON_SPECIFIC_EOI
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b0;
        data_bus_in     = 8'b00100000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
      
        
        //Interrupt
        #(`TB_CYCLE * 0);
        interrupt_request = 8'b00000001;
        #(`TB_CYCLE * 1);
       // interrupt_request = 8'b00000000;
        
           
        // Mask + Higher Prio In Service
        //Interrupt
        #(`TB_CYCLE * 0);
        interrupt_request = 8'b00010101;
        #(`TB_CYCLE * 1);
      //  interrupt_request = 8'b00000000;
        
        //Send ACK
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        
        //SEND_NON_SPECIFIC_EOI
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b0;
        data_bus_in     = 8'b00100000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        
           
        // 2nd Cycle (AEOI + Rotate)   
           
        //Intialization
        #(`TB_CYCLE * 0);
        chip_select_n           = 1'b1;
        read_enable_n           = 1'b1;
        write_enable_n          = 1'b1;
        address                 = 1'b0;
        data_bus_in             = 8'b00000000;
        cascade_in              = 3'b000;
        interrupt_acknowledge_n = 1'b1;
        interrupt_request       = 8'b00000000;
        reset                   = 1'b1;
        #(`TB_CYCLE * 12);
        
          //ICW1
        #(`TB_CYCLE * 0);
        reset           = 1'b0;
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 0;
        data_bus_in     = 8'b00011111;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        //data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
 // 280      
        //ICW2
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b10001000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 320  
        /*      
        //ICW3
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        */
// 360
        //ICW4
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8 'b00000011;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
  //      data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 400
        //OCW1
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b0000000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
      //  data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 440        
        //OCW2
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b0;
        data_bus_in     = 8'b10000000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
      //  data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        
        
        //OCW3
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b0;
        data_bus_in     = 8'b00001010;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        
        
       
        //Interrupt
        #(`TB_CYCLE * 0);
        interrupt_request = 8'b00010101;
        #(`TB_CYCLE * 1);
      //  interrupt_request = 8'b00000000;
        
        //Send ACK
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        
        //Send ACK
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        
        //Send ACK
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
      
       
               // 2nd Cycle (AEOI)   
           
        //Intialization
        #(`TB_CYCLE * 0);
        chip_select_n           = 1'b1;
        read_enable_n           = 1'b1;
        write_enable_n          = 1'b1;
        address                 = 1'b0;
        data_bus_in             = 8'b00000000;
        cascade_in              = 3'b000;
        interrupt_acknowledge_n = 1'b1;
        interrupt_request       = 8'b00000000;
        reset                   = 1'b1;
        #(`TB_CYCLE * 12);
        
          //ICW1
        #(`TB_CYCLE * 0);
        reset           = 1'b0;
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 0;
        data_bus_in     = 8'b00011111;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        //data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
 // 280      
        //ICW2
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b10001000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 320  
        /*      
        //ICW3
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        */
// 360
        //ICW4
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8 'b00000011;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
  //      data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 400
        //OCW1
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b0000000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
      //  data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 440        
        //OCW2
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
      //  data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        
        
        //OCW3
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b0;
        data_bus_in     = 8'b00001010;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        
        
       
        //Interrupt
        #(`TB_CYCLE * 0);
        interrupt_request = 8'b00010101;
        #(`TB_CYCLE * 1);
      //  interrupt_request = 8'b00000000;
        
        //Send ACK
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        
        //Send ACK
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        
        //Send ACK
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
          
       
       
       
     // 4th Cycle (Cascade)  
        
         //Intialization
        #(`TB_CYCLE * 0);
        chip_select_n           = 1'b1;
        read_enable_n           = 1'b1;
        write_enable_n          = 1'b1;
        address                 = 1'b0;
        data_bus_in             = 8'b00000000;
        cascade_in              = 3'b000;
        interrupt_acknowledge_n = 1'b1;
        interrupt_request       = 8'b00000000;
        reset                   = 1'b1;
        #(`TB_CYCLE * 12);
        
          //ICW1
        #(`TB_CYCLE * 0);
        reset           = 1'b0;
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 0;
        data_bus_in     = 8'b00011101;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        //data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
 // 280      
        //ICW2
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b10001000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 320        
        //ICW3
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b10000000;
        slave_program_or_enable_buffer = 1'b1; // master mode
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 360
        //ICW4
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b00000001;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
  //      data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
// 400
        //OCW1
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b1;
        data_bus_in     = 8'b0000000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
      //  data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        
        
        //OCW3
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b0;
        data_bus_in     = 8'b00001010;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        
        
        //Interrupt
        #(`TB_CYCLE * 0);
        interrupt_request = 8'b10000000;
        #(`TB_CYCLE * 1);
      //  interrupt_request = 8'b00000000;
        
        //Send ACK
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        
        //SEND_NON_SPECIFIC_EOI
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = 1'b0;
        data_bus_in     = 8'b00100000;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 1);
        
        
        #10 $stop;
    end

endmodule
