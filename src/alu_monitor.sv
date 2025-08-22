 class alu_monitor extends uvm_monitor;
    virtual alu_interface vif;
    uvm_analysis_port #(alu_sequence_item) item_collected_port;
    alu_sequence_item seq_item_1;

    `uvm_component_utils(alu_monitor)

    function new(string name , uvm_component parent);
        super.new(name, parent);
        seq_item_1 = new();
        item_collected_port = new("item_collected_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    endfunction

 virtual task run_phase(uvm_phase phase);
   forever
     begin
       repeat(2)@(posedge vif.monitor_cb);
        if (vif.monitor_cb.INP_VALID inside {0,1,2,3} &&
        ((vif.monitor_cb.MODE == 1 && vif.monitor_cb.CMD inside {0,1,2,3,4,5,6,7,8}) ||
         (vif.monitor_cb.MODE == 0 && vif.monitor_cb.CMD inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13})))
          repeat (1) @(vif.monitor_cb);
    else if (vif.monitor_cb.INP_VALID == 3 && (vif.monitor_cb.MODE == 1 && vif.monitor_cb.CMD inside {9,10}))
      repeat (2) @(vif.monitor_cb);


      if((vif.monitor_cb.INP_VALID==2'b01) ||(vif.monitor_cb.INP_VALID==2'b10))
      begin
        if(((vif.monitor_cb.MODE==1)&& (vif.monitor_cb.CMD inside {0,1,2,3,8,9,10})) || ((vif.monitor_cb.MODE==0)&& (vif.monitor_cb.CMD inside {0,1,2,3,4,5,12,13}))) //if two operation cmd and inp=01 or 10
          begin
            for(int j=0;j<16;j++)
              begin
                @(vif.monitor_cb);
                $display("[mon 16 clock logic @%t] opa=%d opb=%d inp=%d Res=%d",$time,vif.monitor_cb.OPA,vif.monitor_cb.OPB,vif.monitor_cb.INP_VALID,vif.monitor_cb.RES);
                 begin
                   if(vif.monitor_cb.INP_VALID==2'b11) 
                    begin
                      if(vif.monitor_cb.MODE==1 && vif.monitor_cb.CMD inside {9,10})// mult
                      begin
                       repeat(2)@(vif.monitor_cb);
                       seq_item_1.RES=vif.monitor_cb.RES;
                       seq_item_1.COUT=vif.monitor_cb.COUT;
                        seq_item_1.OFLOW=vif.monitor_cb.OFLOW;
                        seq_item_1.G=vif.monitor_cb.G;
                        seq_item_1.L=vif.monitor_cb.L;
                        seq_item_1.E=vif.monitor_cb.E;
                        seq_item_1.OPA=vif.monitor_cb.OPA;
                        seq_item_1.OPB=vif.monitor_cb.OPB;
                        seq_item_1.CIN=vif.monitor_cb.CIN;
                        seq_item_1.CMD=vif.monitor_cb.CMD;
                        seq_item_1.MODE=vif.monitor_cb.MODE;
                        seq_item_1.INP_VALID=vif.monitor_cb.INP_VALID;
                        seq_item_1.CE=vif.monitor_cb.CE;

                        `uvm_info(get_type_name(),$sformatf("[MONITOR 11 mul (16 clock logic)]sent at time=%t",$time),UVM_LOW);
       `uvm_info(get_type_name(),$sformatf("OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d RES=%d",seq_item_1.OPA,seq_item_1.OPB,seq_item_1.CIN,seq_item_1.CMD,seq_item_1.INP_VALID,seq_item_1.MODE,seq_item_1.RES),UVM_LOW);
      item_collected_port.write(seq_item_1);
                   end
                    else 
                     begin
                      repeat(1)@(vif.monitor_cb);
                      seq_item_1.RES=vif.monitor_cb.RES;
                      seq_item_1.COUT=vif.monitor_cb.COUT;
                      seq_item_1.OFLOW=vif.monitor_cb.OFLOW;
                      seq_item_1.G=vif.monitor_cb.G;
                      seq_item_1.L=vif.monitor_cb.L;
                      seq_item_1.E=vif.monitor_cb.E;

                      seq_item_1.OPA=vif.monitor_cb.OPA;
                      seq_item_1.OPB=vif.monitor_cb.OPB;
                      seq_item_1.CIN=vif.monitor_cb.CIN;
                      seq_item_1.CMD=vif.monitor_cb.CMD;
                      seq_item_1.MODE=vif.monitor_cb.MODE;
                      seq_item_1.INP_VALID=vif.monitor_cb.INP_VALID;
                      seq_item_1.CE=vif.monitor_cb.CE;

                       `uvm_info(get_type_name(),$sformatf("[MONITOR for other operation (16 clock logic)]sent at time=%t",$time),UVM_LOW);
       `uvm_info(get_type_name(),$sformatf("OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d RES=%d",seq_item_1.OPA,seq_item_1.OPB,seq_item_1.CIN,seq_item_1.CMD,seq_item_1.INP_VALID,seq_item_1.MODE,seq_item_1.RES),UVM_LOW);
      item_collected_port.write(seq_item_1);
                    end
                     break;
                   end
                 else
                    begin
                      continue;
                    end
                 end
              end
          end 
        else if((vif.monitor_cb.MODE==1 && vif.monitor_cb.CMD inside {4,5,6,7})||(vif.monitor_cb.MODE==0 && vif.monitor_cb.CMD inside {6,7,8,9,10,11})) //if inp=01 or 10 and single operand operation
              begin
                           seq_item_1.RES=vif.monitor_cb.RES;
                            seq_item_1.COUT=vif.monitor_cb.COUT;
                            seq_item_1.OFLOW=vif.monitor_cb.OFLOW;
                            seq_item_1.G=vif.monitor_cb.G;
                            seq_item_1.L=vif.monitor_cb.L;
                            seq_item_1.E=vif.monitor_cb.E;

                            seq_item_1.OPA=vif.monitor_cb.OPA;
                            seq_item_1.OPB=vif.monitor_cb.OPB;
                            seq_item_1.CIN=vif.monitor_cb.CIN;
                            seq_item_1.CMD=vif.monitor_cb.CMD;
                            seq_item_1.MODE=vif.monitor_cb.MODE;
                            seq_item_1.INP_VALID=vif.monitor_cb.INP_VALID;
                            seq_item_1.CE=vif.monitor_cb.CE;

                `uvm_info(get_type_name(),$sformatf("[MONITOR 01 or 10]sent at time=%t",$time),UVM_LOW);
       `uvm_info(get_type_name(),$sformatf("OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d RES=%d",seq_item_1.OPA,seq_item_1.OPB,seq_item_1.CIN,seq_item_1.CMD,seq_item_1.INP_VALID,seq_item_1.MODE,seq_item_1.RES),UVM_LOW);
      item_collected_port.write(seq_item_1);

               end
      end 
        else
           begin
             seq_item_1.RES=vif.monitor_cb.RES;
              seq_item_1.COUT=vif.monitor_cb.COUT;
              seq_item_1.OFLOW=vif.monitor_cb.OFLOW;
              seq_item_1.G=vif.monitor_cb.G;
              seq_item_1.L=vif.monitor_cb.L;
              seq_item_1.E=vif.monitor_cb.E;

              seq_item_1.OPA=vif.monitor_cb.OPA;
              seq_item_1.OPB=vif.monitor_cb.OPB;
              seq_item_1.CIN=vif.monitor_cb.CIN;
              seq_item_1.CMD=vif.monitor_cb.CMD;
              seq_item_1.MODE=vif.monitor_cb.MODE;
              seq_item_1.INP_VALID=vif.monitor_cb.INP_VALID;
              seq_item_1.CE=vif.monitor_cb.CE;
             `uvm_info(get_type_name(),$sformatf("[MONITOR for 11 or 00]sent at time =%t",$time),UVM_LOW);
       `uvm_info(get_type_name(),$sformatf("OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d RES=%d",seq_item_1.OPA,seq_item_1.OPB,seq_item_1.CIN,seq_item_1.CMD,seq_item_1.INP_VALID,seq_item_1.MODE,seq_item_1.RES),UVM_LOW);
      item_collected_port.write(seq_item_1);
   end
    end
  endtask
endclass
