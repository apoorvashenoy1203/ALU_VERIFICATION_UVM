 `include "uvm_pkg.sv"
`include "uvm_macros.svh"
`include "design.sv"
`include "alu_interface.sv"
`include "alu_pkg.sv"

module top;
    bit CLK;
    bit RST;

    import alu_pkg::*;
    import uvm_pkg::*;
always #5 CLK = ~CLK;

    initial begin
        RST = 1;
        #5 RST = 0;
    end

    alu_interface vif(CLK, RST);

    ALU_DESIGN DUV (
        .OPA(vif.OPA),
        .OPB(vif.OPB),
        .CLK(CLK),
        .RST(RST),
        .CE(vif.CE),
        .MODE(vif.MODE),
        .INP_VALID(vif.INP_VALID),
        .CMD(vif.CMD),
        .RES(vif.RES),
        .COUT(vif.COUT),
        .OFLOW(vif.OFLOW),
        .G(vif.G),
        .E(vif.E),
        .L(vif.L),
        .ERR(vif.ERR),
        .CIN(vif.CIN)
    );

    initial begin
        uvm_config_db#(virtual alu_interface)::set(uvm_root::get(), "*", "vif", vif);
    end

    initial begin
        //run_test("alu_test1");
 run_test("alu_regression_test");
    end
endmodule
