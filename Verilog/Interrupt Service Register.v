module In_Service_register (
    input   wire           clk,
    input   wire           reset,

    // Inputs
    input   wire   [2:0]   priority_rotate,
    input   wire   [7:0]   interrupt,
    input   wire           latch_in_service,
    input   wire   [7:0]   end_of_interrupt,

    // Outputs
    output  reg   [7:0]   in_service_register,
    output  reg   [7:0]   highest_level_in_service
);

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

    //
    // In service register
    //
    wire  [7:0]   next_in_service_register;

    assign next_in_service_register = (in_service_register & ~end_of_interrupt)
                                     | (latch_in_service == 1'b1 ? interrupt : 8'b00000000);

    always@(negedge clk, posedge reset) begin
        if (reset)
            in_service_register <= 8'b00000000;
        else
            in_service_register <= next_in_service_register;
    end

    //
    // Get Highst level in service
    //
    reg   [7:0]   next_highest_level_in_service;

    always@(*) begin
        next_highest_level_in_service = next_in_service_register;
        next_highest_level_in_service = rotate(next_highest_level_in_service, priority_rotate);
        next_highest_level_in_service = priority_resolve(next_highest_level_in_service);
        next_highest_level_in_service = un_rotate(next_highest_level_in_service, priority_rotate);
    end

    always @(negedge clk, posedge reset) begin
        if (reset)
            highest_level_in_service <= 8'b00000000;
        else
            highest_level_in_service <= next_highest_level_in_service;
            end
endmodule
