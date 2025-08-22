 class alu_driver extends uvm_driver #(alu_sequence_item);
    virtual alu_interface vif;
    `uvm_component_utils(alu_driver)


    function new(string name , uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual alu_interface)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", {"virtual interface must be set for :", get_full_name(), ".vif"});
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive();
            seq_item_port.item_done();
        end
    endtask

     virtual task drive();
    @(posedge vif.driver_cb)
    //repeat(1)@(posedge vif.DRV.CLK);
    `uvm_info(get_type_name(),$sformatf("Drive started "),UVM_LOW);
    if (req.INP_VALID == 2'b01 || req.INP_VALID == 2'b10) //checking for 2 operand and inp=01 or10
        begin//2
          if (((req.MODE == 1) && (req.CMD inside {0,1,2,3,8,9,10})) || ((req.MODE == 0) && (req.CMD inside {0,1,2,3,4,5,12,13})))
          begin//3
          $display("[DRIVER 1 : @%t] two operand operation 01-10 ",$time);
          vif.driver_cb.OPA <= req.OPA;
          vif.driver_cb.OPB <= req.OPB;
          vif.driver_cb.CIN <= req.CIN;
          vif.driver_cb.CE <= req.CE;
          vif.driver_cb.CMD <= req.CMD;
          vif.driver_cb.MODE <= req.MODE;
          vif.driver_cb.INP_VALID <= req.INP_VALID;
            req.print();
            $display("[DRIVER]initial sent at time=%t later check for inp to be 11",$time);
            `uvm_info(get_type_name(),$sformatf("OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d",req.OPA,req.OPB,req.CIN,req.CMD,req.INP_VALID,req.MODE),UVM_LOW);


          for (int j = 0; j < 16; j++)
            begin//4
            @(vif.driver_cb);
              if (req.INP_VALID == 2'b11)
              begin//5

              vif.driver_cb.OPA <= req.OPA;
              vif.driver_cb.OPB <= req.OPB;
              vif.driver_cb.CIN <= req.CIN;
              vif.driver_cb.CE <= req.CE;
              vif.driver_cb.CMD <= req.CMD;
              vif.driver_cb.MODE <= req.MODE;
              vif.driver_cb.INP_VALID <= req.INP_VALID;
              req.print();

                `uvm_info(get_type_name(),$sformatf("GOT INP_VALID =11 Sent to dut OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d",req.OPA,req.OPB,req.CIN,req.CMD,req.INP_VALID,req.MODE),UVM_LOW);
              break;
              end //5
              else
                begin//6
              $display("[DRIVER 2 :@%t] else part of 16 logic", $time);
              req.MODE.rand_mode(0);
              req.CMD.rand_mode(0);
              req.CE.rand_mode(0);
                  assert(req.randomize() == 1);
              $display("[DRIVER 2 : @%t ] NOT RECEIVED 11 SO RANDOMIZED...so now values after randomization",$time) ;
                 `uvm_info(get_type_name(),$sformatf("OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d goes for checking",req.OPA,req.OPB,req.CIN,req.CMD,req.INP_VALID,req.MODE),UVM_LOW);
            end//6
          end//4
        end //3
          else //its 01 and 10 but not 2 operand ,single operand operation cmd
            begin//7
          vif.driver_cb.OPA <= req.OPA;
          vif.driver_cb.OPB <= req.OPB;
          vif.driver_cb.CIN <= req.CIN;
          vif.driver_cb.CE <= req.CE;
          vif.driver_cb.CMD <= req.CMD;
          vif.driver_cb.MODE <= req.MODE;
          vif.driver_cb.INP_VALID <= req.INP_VALID;

              $display("[DRIVER :@%t] INP_valid =01 0r 10 single operand Mailbox put happened ", $time);
          req.print();
            $display("[DRIVER]sent at time=%t",$time);
            `uvm_info(get_type_name(),$sformatf("OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d",req.OPA,req.OPB,req.CIN,req.CMD,req.INP_VALID,req.MODE),UVM_LOW);

        end//7
      end //2
        else //inp=11 or 00
          begin//8
        vif.driver_cb.OPA <= req.OPA;
        vif.driver_cb.OPB <= req.OPB;
        vif.driver_cb.CIN <= req.CIN;
        vif.driver_cb.CE <= req.CE;
        vif.driver_cb.CMD <= req.CMD;
        vif.driver_cb.MODE <= req.MODE;
        vif.driver_cb.INP_VALID <= req.INP_VALID;
        req.print();
            $display("[DRIVER]sent at time=%t",$time);
            `uvm_info(get_type_name(),$sformatf("OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d",req.OPA,req.OPB,req.CIN,req.CMD,req.INP_VALID,req.MODE),UVM_LOW);

      end//8

    if (req.INP_VALID inside {0,1,2,3} &&
        ((req.MODE == 1 && req.CMD inside {0,1,2,3,4,5,6,7,8}) ||
         (req.MODE == 0 && req.CMD inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13})))
        repeat (1) @(vif.driver_cb);
    else if (req.INP_VALID == 3 && (req.MODE == 1 && req.CMD inside {9,10}))
        repeat (2) @(vif.driver_cb);


    repeat(2)@(posedge vif.DRV.CLK);
  endtask

endclass
