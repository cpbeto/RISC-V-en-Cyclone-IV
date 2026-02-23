// https://www.chipverify.com/verilog/verilog-timescale
`timescale 1ns / 1ps

module soc (
    input wire clk,
    input wire resetn,
`ifdef DEBUG_SET_SIMULATION
    output wire [31:0] debug_pc,
    output wire [31:0] debug_regfile [0:31],
    output wire        debug_mem_write,
    output wire [31:0] debug_mem_write_addr,
    output wire [31:0] debug_mem_write_data,
    output wire [3:0]  debug_mem_write_mask
`endif
);

    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;

    // Unused ports from picorv32
    wire trap;
    wire mem_la_read;
    wire mem_la_write;
    wire [31:0] mem_la_addr;
    wire [31:0] mem_la_wdata;
    wire [3:0]  mem_la_wstrb;

    wire pcpi_valid;
    wire [31:0] pcpi_insn;
    wire [31:0] pcpi_rs1;
    wire [31:0] pcpi_rs2;
    wire pcpi_wr;
    wire [31:0] pcpi_rd;
    wire pcpi_wait;
    wire pcpi_ready;

    wire [31:0] irq = 32'b0;
    wire [31:0] eoi;

    wire trace_valid;
    wire [35:0] trace_data;

    picorv32 #(
        .PROGADDR_RESET(32'h00000000),
        .ENABLE_MUL(0),
        .ENABLE_DIV(0),
        .ENABLE_PCPI(0),
        .ENABLE_IRQ(0),
        .ENABLE_TRACE(0),
        .ENABLE_REGS_DUALPORT(1),
        .ENABLE_REGS_16_31(1),
        .ENABLE_COUNTERS(0),
        .ENABLE_COUNTERS64(0)
    ) cpu (
        .clk    (clk),
        .resetn (resetn),
`ifdef DEBUG_SET_SIMULATION
        .debug_pc               (debug_pc),
        .debug_regfile          (debug_regfile),
        .debug_mem_write        (debug_mem_write),
        .debug_mem_write_addr   (debug_mem_write_addr),
        .debug_mem_write_data   (debug_mem_write_data),
        .debug_mem_write_mask   (debug_mem_write_mask),
`endif
        .mem_valid  (mem_valid),
        .mem_instr  (mem_instr),
        .mem_ready  (mem_ready),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata),

        // Unused ports from picorv32
        .trap       (trap),

        .mem_la_read  (mem_la_read),
        .mem_la_write (mem_la_write),
        .mem_la_addr  (mem_la_addr),
        .mem_la_wdata (mem_la_wdata),
        .mem_la_wstrb (mem_la_wstrb),

        .pcpi_valid (pcpi_valid),
        .pcpi_insn  (pcpi_insn),
        .pcpi_rs1   (pcpi_rs1),
        .pcpi_rs2   (pcpi_rs2),
        .pcpi_wr    (pcpi_wr),
        .pcpi_rd    (pcpi_rd),
        .pcpi_wait  (pcpi_wait),
        .pcpi_ready (1'b0), // Not implementing PCPI, so always ready

        .irq        (irq),
        .eoi        (eoi),

        .trace_valid (trace_valid),
        .trace_data  (trace_data)
    );

    verilog_ram ram (
        .clk        (clk),
        .mem_valid  (mem_valid),
        .mem_instr  (mem_instr),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata),
        .mem_ready  (mem_ready)
    );

endmodule
