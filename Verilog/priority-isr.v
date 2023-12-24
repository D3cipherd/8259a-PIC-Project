module ISRAndPriorityResolver (
  input [7:0] IMR, IRR,
  input INTA, AEOI, AutomaticRotation, EOI,
  output reg [7:0] ISR,
  output wire Prioritywire,
  output wire INT,
  output reg clearFlag, PriorityFlagSendTocascading,
  output reg [2:0] clearBit, PrioritySendtoCascading,
  output reg defaultIR7
);
 integer start_index;
  reg [23:0] priorityLevelRegister;
  reg [7:0] AcceptedIntrupt;
  reg [2:0] currenthighestpriorityreg;
  reg [2:0] currenthighestpriorityregLevel;
  reg [2:0] counter;
  reg [2:0] helper;
 integer end_index;
  assign Prioritywire = 1'b0;
  assign INT = (AcceptedIntrupt != 0); 

  always @* begin
    AcceptedIntrupt = IRR & ~IMR;
  
    currenthighestpriorityreg = 3'b111;
    currenthighestpriorityregLevel = 3'b111;

    for (currenthighestpriorityreg = 0; currenthighestpriorityreg < 8; currenthighestpriorityreg = currenthighestpriorityreg + 1) begin
       start_index = currenthighestpriorityreg * 3 + 2;
     end_index = currenthighestpriorityreg * 3;

    // Check if the condition is true
    if (AcceptedIntrupt[currenthighestpriorityreg] && (priorityLevelRegister[start_index:end_index] <= currenthighestpriorityregLevel))  begin
        currenthighestpriorityregLevel = priorityLevelRegister[currenthighestpriorityreg*3+2:currenthighestpriorityreg*3];
      end
    end

    if (INTA && !INT) begin
      if (AutomaticRotation) begin
        helper = 3'b000;
        for (currenthighestpriorityreg = currenthighestpriorityreg*3+3; currenthighestpriorityreg < 24; currenthighestpriorityreg = currenthighestpriorityreg + 3) begin
          priorityLevelRegister[currenthighestpriorityreg+2:currenthighestpriorityreg] = helper;
          helper = helper + 1;
        end
        for (currenthighestpriorityreg = 0; currenthighestpriorityreg < currenthighestpriorityreg*3+1; currenthighestpriorityreg = currenthighestpriorityreg + 3) begin
          priorityLevelRegister[currenthighestpriorityreg+2:currenthighestpriorityreg] = helper;
          helper = helper + 1;
        end
      end else begin
        helper = 3'b000;
        for (currenthighestpriorityreg = 0; currenthighestpriorityreg < 24; currenthighestpriorityreg = currenthighestpriorityreg + 3) begin
          priorityLevelRegister[currenthighestpriorityreg+2:currenthighestpriorityreg] = currenthighestpriorityreg/3;
        end
      end
    end
  end

  always @(negedge INTA) begin
    if (counter == 3'b00) begin
      clearBit = currenthighestpriorityreg;
      PrioritySendtoCascading = clearBit;
      PriorityFlagSendTocascading = clearFlag;

      if (AcceptedIntrupt[currenthighestpriorityreg] == 3'b000) begin
        clearFlag = 1'b0;
        ISR = 8'b00000000;
        clearBit = 3'b000;
        PrioritySendtoCascading = clearBit;
        PriorityFlagSendTocascading = clearFlag;
        defaultIR7 = 1'b1;
      end else begin
        clearFlag = 1'b1;
        ISR[clearBit] = 1'b1;
      end
      counter = 3'b01;
    end else if (counter == 3'b01) begin
      counter = 3'b10;
    end
  end

  always @(posedge INTA) begin
    if (counter == 3'b10) begin
      if (AEOI) begin
        ISR = 8'b00000000;
      end
      
      defaultIR7 = 1'b0;
      clearFlag = 1'b0;
      clearBit = 3'b000;
      PrioritySendtoCascading = clearBit;
      PriorityFlagSendTocascading = clearFlag;
      counter = 3'b00;
    end
  end

  always @(posedge EOI) begin
    
    ISR <= 8'b00000000;
    counter <= 3'b00;
    defaultIR7 <= 1'b0;
    clearFlag <= 1'b0;
    clearBit <= 3'b000;
    PrioritySendtoCascading <= clearBit;
    PriorityFlagSendTocascading <= clearFlag;
  end 

  initial begin
    helper = 3'b000;
    counter = 3'b000;
    defaultIR7 = 3'b000;
  end
endmodule
