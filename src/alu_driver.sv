 class alu_environment extends uvm_env;
    alu_agent active_agent;
  alu_agent passive_agent;
    alu_scoreboard scoreboard_1;
  alu_coverage alu_cov;

    `uvm_component_utils(alu_environment)

    function new(string name = "alu_environment", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
      active_agent = alu_agent::type_id::create("active_agent", this);
      passive_agent = alu_agent::type_id::create("passive_agent", this);
        scoreboard_1 = alu_scoreboard::type_id::create("scoreboard_1", this);
      alu_cov = alu_coverage::type_id::create("alu_cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      active_agent.monitor_1.item_collected_port.connect(scoreboard_1.item_collected_export_active);
      passive_agent.monitor_1.item_collected_port.connect(scoreboard_1.item_collected_export_passive);
   active_agent.monitor_1.item_collected_port.connect(alu_cov.port_act);
   passive_agent.monitor_1.item_collected_port.connect(alu_cov.port_pass);

  
    endfunction
endclass
