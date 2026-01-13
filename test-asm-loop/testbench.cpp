#include "Vsoc.h"
#include "verilated.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vsoc *top = new Vsoc;

    top->soc__02Eresetn = 0;
    for (int i = 0; i < 5; i++) {
        top->soc__02Eclk = 0; top->eval();
        top->soc__02Eclk = 1; top->eval();
    }
    top->soc__02Eresetn = 1;

    for (int i = 0; i < 1000; i++) {
        top->soc__02Eclk = 0; top->eval();
        top->soc__02Eclk = 1; top->eval();
    }

    delete top;
    return 0;
}
