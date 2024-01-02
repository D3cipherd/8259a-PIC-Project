`define TB_CYCLE 10

module Testbench();
  reg clk;
  reg reset;
  reg level_edge;
  reg [7:0] clear;
  reg freeze;
  reg [7:0] pin;
  
  wire [7:0] irr;

  initial begin 
    clk =1;
    forever #(`TB_CYCLE / 2) clk = ~clk;
  end
  
  initial begin
    
    // Initialization
    reset = 1'b1;
    clear = 8'b00000000; 
    freeze = 1'b0;
    level_edge = 1'b0;
    pin = 8'b00000000;
    #(`TB_CYCLE * 5)
    reset = 1'b0;
    #(`TB_CYCLE * 2)
    
    // Edge mode
    // IR0 raise request
    pin = 8'b00000000;
    #(`TB_CYCLE * 1)
    pin = 8'b00000001;
    #(`TB_CYCLE * 1)
    clear = 8'b00000001;
    #(`TB_CYCLE * 1)
    clear = 8'b00000000; 
    #(`TB_CYCLE * 1)
   
    
   // IR8 raise request
    #(`TB_CYCLE * 1)
    pin = 8'b10000000;
    #(`TB_CYCLE * 1)
    clear = 8'b10000000;
    #(`TB_CYCLE * 1)
    clear = 8'b00000000; 
    #(`TB_CYCLE * 1)
    
    // IR0-IR7 raise request
    #(`TB_CYCLE * 1)
    pin = 8'b11111111;
    #(`TB_CYCLE * 1)
    clear = 8'b11111111;
    #(`TB_CYCLE * 1)
    clear = 8'b00000000; 
    #(`TB_CYCLE * 1)
    
    
    /****** Level Mode ******/
    level_edge = 1'b1;
    // IR0 raise request
    pin = 8'b00000000;
    #(`TB_CYCLE * 1)
    pin = 8'b00000001;
    #(`TB_CYCLE * 1)
    clear = 8'b00000001;
    #(`TB_CYCLE * 1)
    clear = 8'b00000000; 
    #(`TB_CYCLE * 1)
    
    // IR8 raise request
    pin = 8'b10000000;
    #(`TB_CYCLE * 1)
    clear = 8'b10000000;
    #(`TB_CYCLE * 1)
    clear = 8'b00000000; 
    #(`TB_CYCLE * 1)

    // IR0-IR7 raise request
    pin = 8'b11111111;
    #(`TB_CYCLE * 1)
    clear = 8'b11111111;
    #(`TB_CYCLE * 1)
    clear = 8'b00000000; 
    #(`TB_CYCLE * 1)
    
    //Freeze
    freeze = 1'b1;
   // IR0-IR7 raise request
    pin = 8'b00000000;
    #(`TB_CYCLE * 1)
    pin = 8'b11111111;
    #(`TB_CYCLE * 1)
    clear = 8'b11111111;
    #(`TB_CYCLE * 1)
    clear = 8'b00000000; 
    #(`TB_CYCLE * 1)
    
    freeze = 1'b0;
    
    #10 $stop;
  end

  InterruptRequestRegister IRR(clk, reset, level_edge, clear, freeze, pin, irr);
  
endmodule




