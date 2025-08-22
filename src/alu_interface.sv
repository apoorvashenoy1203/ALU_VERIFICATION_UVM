 `include "defines.sv"

interface alu_interface(input logic CLK, RST);
  logic [`n-1:0] OPA, OPB;
    logic [1:0] INP_VALID;
  logic [`m-1:0] CMD;
    logic CE, CIN, MODE;
    logic ERR, OFLOW, COUT, G, L, E;
  logic [`n:0] RES;

    clocking driver_cb @(posedge CLK);
        default input #0 output #0;
        output OPA, OPB, INP_VALID, CMD, CE, CIN, MODE;
    endclocking

    clocking monitor_cb @(posedge CLK);
        default input #0 output #0;
        input RES, ERR, OFLOW, G, L, E, COUT, OPA, OPB, CIN, CE, MODE, CMD, INP_VALID;
    endclocking

    modport DRV (clocking driver_cb);
    modport MON (clocking monitor_cb);

endinterface
