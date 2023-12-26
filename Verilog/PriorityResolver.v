module PriorityResolver(
  
  // Inputs from Control Logic
  input wire [2:0] priority_rotate,
  input wire [7:0] interrupt_mask,
  
  
  // Other Inputs  
  input wire [7:0] interrupt_req_reg,
  input wire [7:0] in_service_register,
  
  //Outputs
  output wire [7:0] interrupt
);
  // Functions
  function  [7:0] rotate(input [7:0] register, input [2:0] rotate_no);
      case (rotate_no)
          3'b000:  rotate = { register[0], register[7:1]}; 
          3'b001:  rotate = { register[1:0], register[7:2]};
          3'b010:  rotate = { register[2:0], register[7:3]};
          3'b011:  rotate = { register[3:0], register[7:4]};
          3'b100:  rotate = { register[4:0], register[7:5]};
          3'b101:  rotate = { register[5:0], register[7:6]};
          3'b110:  rotate = { register[6:0], register[7]};
          3'b111:  rotate = register;
          default: rotate = register;
          endcase
  endfunction


  function  [7:0] un_rotate(input [7:0] register, input [2:0] rotate_no);
      case (rotate_no)
          3'b000:  un_rotate = { register[6:0], register[7]}; 
          3'b001:  un_rotate = { register[5:0], register[7:6]};
          3'b010:  un_rotate = { register[4:0], register[7:5]};
          3'b011:  un_rotate = { register[3:0], register[7:4]};
          3'b100:  un_rotate = { register[2:0], register[7:3]};
          3'b101:  un_rotate = { register[1:0], register[7:2]};
          3'b110:  un_rotate = { register[0],   register[7:1]};
          3'b111:  un_rotate = register;
          default: un_rotate = register;
          endcase
  endfunction

function  [7:0] priority_resolve(input [7:0] register);
    if      (register[0] == 1'b1)        priority_resolve = 8'b00000001;
    else if (register[1] == 1'b1)        priority_resolve = 8'b00000010;
    else if (register[2] == 1'b1)        priority_resolve = 8'b00000100;
    else if (register[3] == 1'b1)        priority_resolve = 8'b00001000;
    else if (register[4] == 1'b1)        priority_resolve = 8'b00010000;
    else if (register[5] == 1'b1)        priority_resolve = 8'b00100000;
    else if (register[6] == 1'b1)        priority_resolve = 8'b01000000;
    else if (register[7] == 1'b1)        priority_resolve = 8'b10000000;
    else                                 priority_resolve = 8'b00000000;
endfunction



  
  ///////// Masked Registers
  wire [7:0] masked_interrupt_req_reg;
  wire [7:0] masked_in_service_register;
    
  assign masked_interrupt_req_reg = interrupt_req_reg & ~interrupt_mask;
  assign masked_in_service_register = in_service_register & ~interrupt_mask;

  
  ///////// Rotation Mode / Fully Nested [priority_rotate = 3'b111 - no rotation]
  wire [7:0] rotated_interrupt_request;
  wire [7:0] rotated_interrupt;
  wire [7:0] rotated_in_service;
  reg [7:0] in_service_priority_mask;

  
  assign rotated_interrupt_request = rotate(masked_interrupt_req_reg, priority_rotate);
  assign rotated_in_service = rotate(in_service_register,priority_rotate);

  always@(rotated_in_service) begin
    if      (rotated_in_service[0] == 1'b1) in_service_priority_mask = 8'b00000000;
    else if (rotated_in_service[1] == 1'b1) in_service_priority_mask = 8'b00000001; 
    else if (rotated_in_service[2] == 1'b1) in_service_priority_mask = 8'b00000011; 
    else if (rotated_in_service[3] == 1'b1) in_service_priority_mask = 8'b00000111; 
    else if (rotated_in_service[4] == 1'b1) in_service_priority_mask = 8'b00001111; 
    else if (rotated_in_service[5] == 1'b1) in_service_priority_mask = 8'b00011111; 
    else if (rotated_in_service[6] == 1'b1) in_service_priority_mask = 8'b00111111; 
    else if (rotated_in_service[7] == 1'b1) in_service_priority_mask = 8'b01111111; 
    else                                    in_service_priority_mask = 8'b11111111;
  end


  assign rotated_interrupt = priority_resolve(rotated_interrupt_request) & in_service_priority_mask;

  assign interrupt = un_rotate(rotated_interrupt, priority_rotate);
  
  
endmodule
