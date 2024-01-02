module PR_testbench();
  
  reg [2:0] priority_rotate;
  reg [7:0] interrupt_mask;
  
  // Other Inputs  
  reg [7:0] interrupt_req_reg;
  reg [7:0] in_service_register;
  
  //Outputs
  wire [7:0] interrupt;


  initial begin
     // Fully Nested
     // 1st interrupt
     priority_rotate = 3'b111; interrupt_mask = 8'b00000000; in_service_register = 8'b00000000; interrupt_req_reg = 8'b00000011;
     #10
     // 2nd interrupt
     priority_rotate = 3'b111; interrupt_mask = 8'b00000000; in_service_register = 8'b00000000; interrupt_req_reg = 8'b00100010;
     #10
     // Auto Rotation Mode
     priority_rotate = 3'b010; interrupt_mask = 8'b00000000; in_service_register = 8'b00000000; interrupt_req_reg = 8'b00100000;

  
  end

PriorityResolver PR(priority_rotate,interrupt_mask,interrupt_req_reg,in_service_register,interrupt);

endmodule
