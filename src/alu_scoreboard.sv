 `include"defines.sv"
`uvm_analysis_imp_decl(_act_mon)
`uvm_analysis_imp_decl(_pass_mon)
class alu_scoreboard extends uvm_scoreboard;

alu_sequence_item packet_queue1[$];
  alu_sequence_item packet_queue2[$];
alu_sequence_item exp_pkt;
int shift_value;
  localparam int required_bits = $clog2(`n);

  `uvm_component_utils(alu_scoreboard)

  uvm_analysis_imp_act_mon #(alu_sequence_item, alu_scoreboard) item_collected_export_active;
  uvm_analysis_imp_pass_mon #(alu_sequence_item, alu_scoreboard) item_collected_export_passive;

  function new (string name, uvm_component parent);
    super.new(name, parent);
    exp_pkt=new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_export_active = new("item_collected_export_active", this);
    item_collected_export_passive=new("item_collected_export_passive", this);
  endfunction

  virtual function void write_act_mon(alu_sequence_item packet_1);
    $display("Scoreboard is received:: Packet at time =%t",$time);
    packet_queue1.push_back(packet_1);
    `uvm_info(get_type_name(),$sformatf("[FROM ACTIVE  MONITOR]OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d RES=%d",packet_1.OPA,packet_1.OPB,packet_1.CIN,packet_1.CMD,packet_1.INP_VALID,packet_1.MODE,packet_1.RES),UVM_LOW);
  endfunction

  virtual function void write_pass_mon(alu_sequence_item packet_2);
    $display("Scoreboard is received:: Packet at time =%t",$time);
    packet_queue2.push_back(packet_2);//actual data passive monitor
    `uvm_info(get_type_name(),$sformatf("[FROM PASSIVE MONITOR]OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d RES=%d",packet_2.OPA,packet_2.OPB,packet_2.CIN,packet_2.CMD,packet_2.INP_VALID,packet_2.MODE,packet_2.RES),UVM_LOW);
  endfunction

      function void compare(alu_sequence_item pkt, alu_sequence_item packet);
        if((pkt.RES==packet.RES)||
           (pkt.ERR==packet.ERR)||
           (pkt.OFLOW==packet.OFLOW)||
           (pkt.COUT==packet.COUT)||
           (pkt.G==packet.G)||
           (pkt.L==packet.L)||
           (pkt.E==packet.E))
                  begin//5
                    `uvm_info(get_type_name(),"Inside compare() function",UVM_LOW);
                    `uvm_info(get_type_name(),"-------MATCH SUCCESSFULL--------",UVM_LOW);
                    `uvm_info(get_type_name(),$sformatf("OPA=%d OPB=%d CIN =%d CMD=%d INP_VALID=%d MODE=%d",packet.OPA,packet.OPB,packet.CIN,packet.CMD,packet.INP_VALID,packet.MODE),UVM_LOW);

                    `uvm_info(get_type_name(),$sformatf(" EXPECTED : RES=%d | ERR=%d | OFLOW=%d | COUT=%d | G=%d | L=%d | E= %d",pkt.RES,pkt.ERR,pkt.OFLOW,pkt.COUT,pkt.G,pkt.L,pkt.E),UVM_LOW);
                    `uvm_info(get_type_name(),$sformatf(" ACTUAL : RES=%d | ERR=%d | OFLOW=%d | COUT=%d | G=%d | L=%d | E= %d",packet.RES,packet.ERR,packet.OFLOW,packet.COUT,packet.G,packet.L,packet.E),UVM_LOW);

                    `uvm_info(get_type_name(),$sformatf("---------------------------------------------------- "),UVM_LOW);
                   end//5
                  else
                    begin
                      `uvm_info(get_type_name(),"Inside compare() function",UVM_LOW);
                      `uvm_info(get_type_name(),"---------MATCH FAILED---------",UVM_LOW);
                        `uvm_info(get_type_name(),$sformatf("OPA=%d OPB=%d CIN =%d CMD=%d INP_VALID=%d MODE=%d",packet.OPA,packet.OPB,packet.CIN,packet.CMD,packet.INP_VALID,packet.MODE),UVM_LOW);
                      `uvm_info(get_type_name(),$sformatf(" EXPECTED : RES=%d | ERR=%d | OFLOW=%d | COUT=%d | G=%d | L=%d | E= %d",pkt.RES,pkt.ERR,pkt.OFLOW,pkt.COUT,pkt.G,pkt.L,pkt.E),UVM_LOW);
                    `uvm_info(get_type_name(),$sformatf(" ACTUAL : RES=%d | ERR=%d | OFLOW=%d | COUT=%d | G=%d | L=%d | E= %d",packet.RES,packet.ERR,packet.OFLOW,packet.COUT,packet.G,packet.L,packet.E),UVM_LOW);

                    `uvm_info(get_type_name(),$sformatf("---------------------------------------------------- "),UVM_LOW);

                    end

        endfunction

  virtual task run_phase(uvm_phase phase);
    alu_sequence_item actu_packet,inp_packet;//actal data and expected data
    forever begin//1
      wait(packet_queue1.size()>0&& packet_queue2.size()>0);

      inp_packet = packet_queue1.pop_front();// active monitor data for expected calculation usefor inputs
      actu_packet = packet_queue2.pop_front();//actual, passive
      `uvm_info(get_type_name(),$sformatf("[active monitor packet for expected calc(POPPED)]OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%dactu_packet MODE=%d",inp_packet.OPA,inp_packet.OPB,inp_packet.CIN,inp_packet.CMD,inp_packet.INP_VALID,inp_packet.MODE),UVM_LOW);
      `uvm_info(get_type_name(),$sformatf("[actual packet from passive monitor (POPPED)]OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d",actu_packet.OPA,actu_packet.OPB,actu_packet.CIN,actu_packet.CMD,actu_packet.INP_VALID,actu_packet.MODE),UVM_LOW);



      if(inp_packet.CE==1)
      begin//1_1
        `uvm_info(get_type_name(),"ENTERED HERE for CE=1",UVM_LOW);
        if(inp_packet.MODE)
          begin//2_2
            //arithmatic
            if(inp_packet.INP_VALID==2'd3)
            begin//2
              `uvm_info(get_type_name(),"ENTERED HERE for INP=3",UVM_LOW);

              case(inp_packet.CMD)
                `ADD:begin//4
                  exp_pkt.RES=inp_packet.OPA+inp_packet.OPB;
                  compare(exp_pkt,actu_packet);
                end//4


                `SUB:begin//6
                  exp_pkt.RES=inp_packet.OPA-inp_packet.OPB;
                  compare(exp_pkt,actu_packet);
                end

                `ADD_CIN:begin//8
                 exp_pkt.RES=inp_packet.OPA+inp_packet.OPB+inp_packet.CIN;
                  compare(exp_pkt,actu_packet);
                end//8

                `SUB_CIN:begin//10
                  exp_pkt.RES=inp_packet.OPA-inp_packet.OPB-inp_packet.CIN;
                  compare(exp_pkt,actu_packet);
                end
                `INC_A:begin
                   exp_pkt.RES=inp_packet.OPA+1;
                  compare(exp_pkt,actu_packet);
                    end
                 `DEC_A:begin
                    exp_pkt.RES=inp_packet.OPA-1;
                   compare(exp_pkt,actu_packet);
                      end
                 `INC_B:begin
                      exp_pkt.RES=inp_packet.OPB+1;
                   compare(exp_pkt,actu_packet);
                      end
                 `DEC_B:begin
                      exp_pkt.RES=inp_packet.OPB-1;
                   compare(exp_pkt,actu_packet);
                      end
                 `CMP:begin
                   exp_pkt.E=(inp_packet.OPA==inp_packet.OPB)? 1'b1:1'bz;
                   exp_pkt.G=(inp_packet.OPA>inp_packet.OPB)? 1'b1:1'bz;
                   exp_pkt.L=(inp_packet.OPA<inp_packet.OPB)? 1'b1:1'bz;
                   compare(exp_pkt,actu_packet);
                       end
                 `INC_MUL:begin
                   exp_pkt.RES=(inp_packet.OPA+1)*(inp_packet.OPB+1);
                      compare(exp_pkt,actu_packet);
                      end
                 `SHIFT_MUL:begin
                   exp_pkt.RES=(inp_packet.OPA<<1)*(inp_packet.OPB);
                   compare(exp_pkt,actu_packet);
                       end

                default:begin//12
                    exp_pkt.RES=9'bz;
                    exp_pkt.OFLOW=1'bz;
                    exp_pkt.COUT=1'bz;
                    exp_pkt.ERR=1'bz;
                    exp_pkt.G=1'bz;
                    exp_pkt.L=1'bz;
                    exp_pkt.E=1'bz;
                  compare(exp_pkt,actu_packet);
               end//12
              endcase

        end//2
            else if(inp_packet.INP_VALID==2'b01)
         begin//4_4_01
           `uvm_info(get_type_name(),"ENTERED HERE for INP=1 mode=1",UVM_LOW);
           case(inp_packet.CMD)
                `INC_A:begin
                  `uvm_info(get_type_name(),"inc opera",UVM_LOW);
                        exp_pkt.RES=inp_packet.OPA+1;
                  compare(exp_pkt,actu_packet);
                    end
                `DEC_A:begin
                        exp_pkt.RES=inp_packet.OPA-1;
                  compare(exp_pkt,actu_packet);
                    end
                 default:begin
                        exp_pkt.RES=9'bz;
                        exp_pkt.OFLOW=1'bz;
                        exp_pkt.COUT=1'bz;
                        exp_pkt.G=1'bz;
                        exp_pkt.L=1'bz;
                        exp_pkt.E=1'bz;
                        exp_pkt.ERR=1'bz;
                   compare(exp_pkt,actu_packet);
                      end
               endcase

         end//4_4_01
            else if(inp_packet.INP_VALID==2'b10)
              begin
                `uvm_info(get_type_name(),"ENTERED HERE for INP=2 mode=1",UVM_LOW);
                case(inp_packet.CMD)
                `INC_B:begin
                        exp_pkt.RES=inp_packet.OPB+1;
                  compare(exp_pkt,actu_packet);
                    end
                `DEC_B:begin
                        exp_pkt.RES=inp_packet.OPB-1;
                  compare(exp_pkt,actu_packet);
                    end
                 default:begin
                        exp_pkt.RES=9'bz;
                        exp_pkt.OFLOW=1'bz;
                        exp_pkt.COUT=1'bz;
                        exp_pkt.G=1'bz;
                        exp_pkt.L=1'bz;
                        exp_pkt.E=1'bz;
                        exp_pkt.ERR=1'bz;
                   compare(exp_pkt,actu_packet);
                      end
               endcase
              end

              else//00
                begin
                  `uvm_info(get_type_name(),"ENTERED HERE for INP=00 mode=1",UVM_LOW);
                        exp_pkt.RES=9'bz;
                        exp_pkt.OFLOW=1'bz;
                        exp_pkt.COUT=1'bz;
                        exp_pkt.G=1'bz;
                        exp_pkt.L=1'bz;
                        exp_pkt.E=1'bz;
                        exp_pkt.ERR=1'b1;
                  compare(exp_pkt,actu_packet);
                end

          end//2_2MODE1
        else
          begin//3_3
            //logical 11,01,10,00
            if(inp_packet.INP_VALID==2'd3)
            begin//2
              `uvm_info(get_type_name(),"ENTERED HERE inp=3 mode=0",UVM_LOW);

              case(inp_packet.CMD)
                       `AND:begin
                         exp_pkt.RES={1'b0,(inp_packet.OPA & inp_packet.OPB)};
                         compare(exp_pkt,actu_packet);
                            end
                        `NAND:begin
                               exp_pkt.RES={1'b0,~(inp_packet.OPA & inp_packet.OPB)};
                          compare(exp_pkt,actu_packet);
                            end
                        `OR:begin
                               exp_pkt.RES={1'b0,(inp_packet.OPA | inp_packet.OPB)};
                          compare(exp_pkt,actu_packet);
                            end
                        `NOR:begin
                          exp_pkt.RES={1'b0,~(inp_packet.OPA | inp_packet.OPB)};
                          compare(exp_pkt,actu_packet);
                            end
                        `XOR:begin;
                               exp_pkt.RES={1'b0,(inp_packet.OPA ^ inp_packet.OPB)};
                          compare(exp_pkt,actu_packet);
                            end
                        `XNOR:begin
                               exp_pkt.RES={1'b0,~(inp_packet.OPA ^ inp_packet.OPB)};
                          compare(exp_pkt,actu_packet);
                            end

                        `NOT_A:begin
                          exp_pkt.RES={1'b0,~(inp_packet.OPA)};
                          compare(exp_pkt,actu_packet);
                                end
                         `NOT_B:begin
                           exp_pkt.RES={1'b0,~(inp_packet.OPB)};
                           compare(exp_pkt,actu_packet);
                                end
                         `SHR1_A:begin
                                 exp_pkt.RES={1'b0,(inp_packet.OPA>>1)};
                           compare(exp_pkt,actu_packet);
                                 end
                        `SHL1_A:begin
                                exp_pkt.RES={1'b0,(inp_packet.OPA<<1)};
                          compare(exp_pkt,actu_packet);
                                end
                        `SHR1_B:begin
                                 exp_pkt.RES={1'b0,(inp_packet.OPB>>1)};
                          compare(exp_pkt,actu_packet);
                                end
                        `SHL1_B:begin
                          exp_pkt.RES={1'b0,(inp_packet.OPB<<1)};
                          compare(exp_pkt,actu_packet);
                                end
                `ROL:begin//pending
                                 shift_value=inp_packet.OPB[required_bits-1:0];
                                 exp_pkt.RES={1'b0,((inp_packet.OPA<<shift_value)|(inp_packet.OPA>>`n-shift_value))};
                  if(inp_packet.OPB>`n-1)
                                  exp_pkt.ERR=1;
                                 else
                                  exp_pkt.ERR=1'bz;
                  compare(exp_pkt,actu_packet);
                                end
                        `ROR:begin
                                 shift_value=inp_packet.OPB[required_bits-1:0];
                          exp_pkt.RES={1'b0,((inp_packet.OPA>>shift_value)|(inp_packet.OPA<<`n-shift_value))};
                          if(inp_packet.OPB>`n-1)
                                  exp_pkt.ERR=1;
                                 else
                                  exp_pkt.ERR=1'bz;
                          compare(exp_pkt,actu_packet);
                                end


                default:begin
                    exp_pkt.RES=9'bz;
                    exp_pkt.OFLOW=1'bz;
                    exp_pkt.COUT=1'bz;
                    exp_pkt.ERR=1'bz;
                    exp_pkt.G=1'bz;
                    exp_pkt.L=1'bz;
                    exp_pkt.E=1'bz;
                  compare(exp_pkt,actu_packet);
               end
              endcase

        end
            else if(inp_packet.INP_VALID==2'd1)
         begin
           `uvm_info(get_type_name(),"ENTERED HERE for INP=1 mode=0",UVM_LOW);
           case(inp_packet.CMD)
                `NOT_A:begin
                  exp_pkt.RES={1'b0,~(inp_packet.OPA)};
                  compare(exp_pkt,actu_packet);
                    end
                `SHR1_A:begin
                  exp_pkt.RES={1'b0,(inp_packet.OPA>>1)};
                  compare(exp_pkt,actu_packet);
                    end
                `SHL1_A:begin
                  exp_pkt.RES={1'b0,(inp_packet.OPA<<1)};
                  compare(exp_pkt,actu_packet);
                    end
                 default:begin
                        exp_pkt.RES=9'bz;
                        exp_pkt.OFLOW=1'bz;
                        exp_pkt.COUT=1'bz;
                        exp_pkt.G=1'bz;
                        exp_pkt.L=1'bz;
                        exp_pkt.E=1'bz;
                        exp_pkt.ERR=1'bz;
                   compare(exp_pkt,actu_packet);
                      end
               endcase

         end
            else if(inp_packet.INP_VALID==2'd2)
              begin
                `uvm_info(get_type_name(),"ENTERED HERE for INP=2 mode=0",UVM_LOW);
              case(inp_packet.CMD)
                `NOT_B:begin
                  exp_pkt.RES={1'b0,~(inp_packet.OPB)};
                  compare(exp_pkt,actu_packet);
                      end
                `SHR1_B:begin
                  exp_pkt.RES={1'b0,(inp_packet.OPB>>1)};
                  compare(exp_pkt,actu_packet);
                        end
                `SHL1_B:begin
                  exp_pkt.RES={1'b0,(inp_packet.OPB<<1)};
                  compare(exp_pkt,actu_packet);
                        end
                 default:begin
                        exp_pkt.RES=9'bz;
                        exp_pkt.OFLOW=1'bz;
                        exp_pkt.COUT=1'bz;
                        exp_pkt.G=1'bz;
                        exp_pkt.L=1'bz;
                        exp_pkt.E=1'bz;
                        exp_pkt.ERR=1'bz;
                   compare(exp_pkt,actu_packet);
                      end
               endcase
              end

              else
                begin
                  `uvm_info(get_type_name(),$sformatf("came for inp=00 "),UVM_LOW);
                        exp_pkt.RES=9'bz;
                        exp_pkt.OFLOW=1'bz;
                        exp_pkt.COUT=1'bz;
                        exp_pkt.G=1'bz;
                        exp_pkt.L=1'bz;
                        exp_pkt.E=1'bz;
                        exp_pkt.ERR=1'b1;
                  compare(exp_pkt,actu_packet);
                end

          end
      end
      else
        begin
          `uvm_info(get_type_name(),"ce=0",UVM_LOW);
       inp_packet.RES=inp_packet.RES;
       inp_packet.OFLOW=inp_packet.OFLOW;
       inp_packet.COUT=inp_packet.COUT;
       inp_packet.G=inp_packet.G;
       inp_packet.L=inp_packet.L;
       inp_packet.E=inp_packet.E;
       inp_packet.ERR=inp_packet.ERR;
          `uvm_info(get_type_name(),$sformatf("(PACKET DATA CE=0)RES=%d OFLOW=%d COUT=%d G=%d L=%d E =%d ERR=%d",inp_packet.RES,inp_packet.OFLOW,inp_packet.COUT,inp_packet.G,inp_packet.L,inp_packet.E,inp_packet.ERR),UVM_LOW);
        end


    end//1
  endtask
endclass

