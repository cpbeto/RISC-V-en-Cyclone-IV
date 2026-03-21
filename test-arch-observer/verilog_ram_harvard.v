// https://www.chipverify.com/verilog/verilog-timescale
`timescale 1ns / 1ps

module verilog_ram_harvard #(
    parameter IMEM_BYTES = 1024, // e.g. 1 KiB code
    parameter DMEM_BYTES = 1024 // e.g. 1 KiB data
)(
    input  wire        clk,
    input  wire        mem_valid,
    input  wire        mem_instr, // 1 = instruction fetch, 0 = data access
    input  wire [31:0] mem_addr,
    input  wire [31:0] mem_wdata,
    input  wire [3:0]  mem_wstrb,
    output reg  [31:0] mem_rdata,
    output reg         mem_ready
);
    // Byte-addressable memories
    reg [7:0] imem [0:IMEM_BYTES-1];
    reg [7:0] dmem [0:DMEM_BYTES-1];

    localparam IMEM_ADDR_W = $clog2(IMEM_BYTES);
    localparam DMEM_ADDR_W = $clog2(DMEM_BYTES);

    // Compute physical indices from latched address (wrap by implemented size)
    wire [IMEM_ADDR_W-1:0] imem_addr = mem_addr[IMEM_ADDR_W-1:0];
    wire [DMEM_ADDR_W-1:0] dmem_addr = mem_addr[DMEM_ADDR_W-1:0];

    integer i;
    initial begin
        $readmemh("program.hex", imem);
        for (i = 0; i < DMEM_BYTES; i = i + 1)
            dmem[i] = 8'h00;
    end

    assign mem_ready = mem_valid; // Always ready (zero-latency RAM)

    wire [31:0] imem_word = { imem[imem_addr+3], imem[imem_addr+2], imem[imem_addr+1], imem[imem_addr+0] };
    wire [31:0] dmem_word = { dmem[dmem_addr+3], dmem[dmem_addr+2], dmem[dmem_addr+1], dmem[dmem_addr+0] };
    assign mem_rdata = mem_instr ? imem_word : dmem_word;

    always @(posedge clk) begin
        // Write data on rising edge, but only if mem_valid is still high (i.e. the master didn't deassert it after seeing mem_ready)
        if (mem_valid && mem_ready && |mem_wstrb) begin
            // IMEM is read-only
            if (mem_instr && |mem_wstrb) begin
                $display("ERROR: write to IMEM addr=%08x wdata=%08x wstrb=%x", mem_addr, mem_wdata, mem_wstrb);
                $fatal;
            end
            if (mem_wstrb[0]) dmem[dmem_addr+0] <= mem_wdata[7:0];
            if (mem_wstrb[1]) dmem[dmem_addr+1] <= mem_wdata[15:8];
            if (mem_wstrb[2]) dmem[dmem_addr+2] <= mem_wdata[23:16];
            if (mem_wstrb[3]) dmem[dmem_addr+3] <= mem_wdata[31:24];
        end
    end

endmodule
