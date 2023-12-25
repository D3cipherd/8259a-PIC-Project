module cascade_mode_8259(
input interrupt,
input [7:0] irq,
input sngl,
input mpm,
input ms,
input Buf,
input [7:0] icw3,
input sp,
inout [2:0] cas,
output addressbyte2flag,
output addressbyte3flag
);
parameter cnt=0;
always @(interrupt) begin
    cnt=cnt+1;
    if(~sngl){
        if(mpm){
            if(~Buf&& sp&& ms){
                case(irq)
                    8'b00000001:
                        if(irq[0]==icw3[0]){
                            cas=3'b001;	
                        }
                        break;	
                    8'b00000010:
                        if(irq[1]==icw3[1]){
                            cas=3'b010;
                        }
                        break;   
                    8'b00000100:
                        if(irq[2]==icw3[2]){
                            cas=3'b011;
                        }
                        break;
                    8'b00001000:
                        if(irq[3]==icw3[3]){
                            cas=3'b100;
                        }
                        break;
                    8'b00010000:
                        if(irq[4]==icw3[4]){
                            cas=3'b101;
                        }
                        break;
                    8'b00100000:
                        if(irq[5]==icw3[5]){
                            cas=3'b110;
                        }	
                        break;
                    8'b01000000:
                        if(irq[5]==icw3[5]){
                            cas=3'b111;
                        }
                        break;   
                    8'b10000000:
                        if(irq[6]==icw3[6]){
                            cas=3'b000;
                        }
                        break;   
                endcase
            } else if(~Buf &&~sp&& ~ms){
                if(icw3[0]==cas[0]&&icw3[1]==cas[1]&&icw3[2]==cas[2]){
                    if(cnt==2){
                        addressbyte2flag=1'b1;
                    }
                }
            }
        } else {
            if(~Buf&& sp&& ms){
                case(irq)
                    8'b00000001:
                        if(irq[0]==icw3[0]){
                            cas=3'b001;	
                        }
                        break;	
                    8'b00000010:
                        if(irq[1]==icw3[1]){
                            cas=3'b010;
                        }
                        break;   
                    8'b00000100:
                        if(irq[2]==icw3[2]){
                            cas=3'b011;
                        }
                        break;
                    8'b00001000:
                        if(irq[3]==icw3[3]){
                            cas=3'b100;
                        }
                        break;
                    8'b00010000:
                        if(irq[4]==icw3[4]){
                            cas=3'b101;
                        }
                        break;
                    8'b00100000:
                        if(irq[5]==icw3[5]){
                            cas=3'b110;
                        }	
                        break;
                    8'b01000000:
                        if(irq[5]==icw3[5]){
                            cas=3'b111;
                        }
                        break;   
                    8'b10000000:
                        if(irq[6]==icw3[6]){
                            cas=3'b000;
                        }
                        break;   
                endcase
            } else if(~Buf &&~sp&& ~ms){
                if(icw3[0]==cas[0]&&icw3[1]==cas[1]&&icw3[2]==cas[2]){
                    if(cnt==2){
                        addressbyte2flag=1'b1;
                    }
                    if(cnt==3){
                        addressbyte3flag=1'b1;
                    }
                }
            }
        }
    end
endmodule
