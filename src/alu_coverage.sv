 `include "defines.sv"
`uvm_analysis_imp_decl(_act_cov)
`uvm_analysis_imp_decl(_pass_cov)

class alu_coverage extends uvm_component;
  `uvm_component_utils(alu_coverage)

  uvm_analysis_imp_act_cov #(alu_sequence_item, alu_coverage)port_act;
  uvm_analysis_imp_pass_cov #(alu_sequence_item, alu_coverage)port_pass;

  alu_sequence_item drv_pkt, mon_pkt;
  real mon1_cov, drv1_cov;

  covergroup driver_cb;
  MODE_CP: coverpoint drv_pkt.MODE {
                                        bins mode_0 = {0};
                                        bins mode_1 = {1};
                                                                }
CMD_CP: coverpoint drv_pkt.CMD {
                                        bins cmd_vals[] = {[0:15]};
                                                                }
INP_VALID_CP: coverpoint drv_pkt.INP_VALID {
                                        bins invalid = {2'b00};
                                        bins opa_valid = {2'b01};
                                        bins opb_valid = {2'b10};
                                        bins both_valid = {2'b11};

                                                                         }
CE_CP: coverpoint drv_pkt.CE {
                        bins clock_enable[] = {[0:1]};

                                        }
CIN_CP: coverpoint drv_pkt.CIN {
                        bins cin[] = {[0:1]};

                                        }
CMD_ARTH_CP: coverpoint drv_pkt.CMD iff(drv_pkt.MODE == 1) {

                        bins add        = {4'd0};
                        bins sub        = {4'd1};
                        bins add_cin    = {4'd2};
                        bins sub_cin    = {4'd3};
                        bins inc_a      = {4'd4};
                        bins dec_a      = {4'd5};
                        bins inc_b      = {4'd6};
                        bins dec_b      = {4'd7};
                        bins cmp_ab     = {4'd8};
                        bins mul_inc    = {4'd9};
                        bins mul_shift  = {4'd10};

                                                                                }
CMD_LOGIC_CP:coverpoint drv_pkt.CMD iff (drv_pkt.MODE == 0)
                                          {
                                                bins and_op = {4'd0};
                                                bins nand_op = {4'd1};
                                                bins or_op = {4'd2};
                                                bins nor_op = {4'd3};
                                                bins xor_op = {4'd4};
                                                bins xnor_op = {4'd5};
                                                bins not_a = {4'd6};
                                                bins not_b = {4'd7};
                                                bins shr1_a = {4'd8};
                                                bins shl1_a = {4'd9};
                                                bins shr1_b = {4'd10};
                                                bins shl1_b = {4'd11};
                                                bins rol_a_b = {4'd12};
                                                bins ror_a_b = {4'd13};

                                                                        }
OPA_CP: coverpoint drv_pkt.OPA {
                        bins zero   = {0};
                        bins smaller  = {[1 : (2**(`n/2))-1]};
                        bins largeer  = {[2**(`n/2) : (2**`n)-1]}; }
OPB_CP: coverpoint drv_pkt.OPB {
                        bins zero   = {0};
                        bins smaller  = {[1 : (2**(`n/2))-1]};
                        bins largeer  = {[2**(`n/2) : (2**`n)-1]}; }

endgroup


covergroup monitor_cb;
    RESULT_CP: coverpoint mon_pkt.RES {
      bins result[] = {[0 : (2**`n)-1]};
    }
    COUT_CP: coverpoint mon_pkt.COUT {
      bins cout[] = {0, 1};
    }
    OFLOW_CP: coverpoint mon_pkt.OFLOW {
      bins overflow[] = {0, 1};
    }

    E_CP: coverpoint mon_pkt.E {
      bins equal = {0, 1};
    }

    G_CP: coverpoint mon_pkt.G {
      bins greater = {0, 1};
    }

    L_CP: coverpoint mon_pkt.L {
      bins less= {0, 1};
    }

    ERR_CP: coverpoint mon_pkt.ERR {
      bins error[] = {0, 1};
    }
  endgroup

function new(string name = "", uvm_component parent);
  super.new(name, parent);
  monitor_cb = new();
  driver_cb = new();
  port_act=new("port_act", this);

  port_pass = new("port_pass", this);

endfunction

  function void write_act_cov(alu_sequence_item item);
 drv_pkt = item;
  driver_cb.sample();
    `uvm_info(get_type_name(),$sformatf("[INPUT_COVERAGE] OPA=%d OPB=%d CIN=%d CMD=%d INP_VALID=%d MODE=%d",drv_pkt.OPA,drv_pkt.OPB,drv_pkt.CIN,drv_pkt.CMD,drv_pkt.INP_VALID,drv_pkt.MODE),UVM_LOW);
endfunction


  function void write_pass_cov(alu_sequence_item item);
 mon_pkt = item;
  monitor_cb.sample();
    `uvm_info(get_type_name(),$sformatf("[OUTPUT_COVERAGE] : RES=%d | ERR=%d | OFLOW=%d | COUT=%d | G=%d | L=%d | E= %d",mon_pkt.RES,mon_pkt.ERR,mon_pkt.OFLOW,mon_pkt.COUT,mon_pkt.G,mon_pkt.L,mon_pkt.E),UVM_LOW);
endfunction


function void extract_phase(uvm_phase phase);
  super.extract_phase(phase);
  drv1_cov = driver_cb.get_coverage();
  mon1_cov = monitor_cb.get_coverage();
endfunction

function void report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(get_type_name, $sformatf("[DRIVER] Coverage ------> %0.2f%%,", drv1_cov), UVM_MEDIUM);
  `uvm_info(get_type_name, $sformatf("[MONITOR] Coverage ------> %0.2f%%", mon1_cov), UVM_MEDIUM);
  endfunction

endclass
