#include "Vtb_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    Vtb_top* top = new Vtb_top;

    VerilatedVcdC* tfp = new VerilatedVcdC;
    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("tb_top.vcd");

    int sim_time = 0;
    int clk = 0;

    // Apply reset
    top->rst = 1;
    for (int i = 0; i < 10; i++) {
        clk = !clk;
        top->clk = clk;
        top->eval();
        tfp->dump(sim_time);
        sim_time += 5;
    }
    top->rst = 0;

    // Run simulation
    for (int i = 0; i < 200; i++) {
        clk = !clk;
        top->clk = clk;
        top->eval();
        tfp->dump(sim_time);
        sim_time += 5;
    }

    tfp->close();
    delete top;
    return 0;
}
