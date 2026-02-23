#include "Vsoc.h"
#include "verilated.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vsoc *top = new Vsoc;

    // Reset sequence
    top->resetn = 0;
    for (int i = 0; i < 5; i++) {
        top->clk = 0; top->eval();
        top->clk = 1; top->eval();
    }
    top->resetn = 1;

    uint64_t cycle = 0;
    while (cycle <= 200) {
        top->clk = 0;
        top->eval();

        top->clk = 1;
        top->eval();

        // Detect instruction retirement by checking if the PC changes after the rising edge
        static uint32_t last_pc = 0xffffffff;

        if (top->debug_pc != last_pc) {
            printf("\n");
            printf("RETIRE PC=%08x at cycle %lu\n",
                top->debug_pc,
                cycle
        );
            last_pc = top->debug_pc;
        }

        // Log after rising edge
        printf("%lu ", cycle);
        printf("%08x ", top->debug_pc);

        for (int i = 0; i < 32; i++) {
            printf("%08x ", top->debug_regfile[i]);
        }

        if (top->debug_mem_write) {
            printf("W %08x %08x %x",
                top->debug_mem_write_addr,
                top->debug_mem_write_data,
                top->debug_mem_write_mask
            );
        }

        printf("\n");

        cycle++;
    }

    delete top;
    return 0;
}
