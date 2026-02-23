// https://www.chipverify.com/verilog/verilog-timescale
`timescale 1ns / 1ps

module verilog_ram #(
    parameter MEM_BYTES = 256 * 1024 // 16 KiB of memory
)(
    input  wire        clk,
    input  wire        mem_valid,
    input  wire        mem_instr,
    input  wire [31:0] mem_addr,
    input  wire [31:0] mem_wdata,
    input  wire [3:0]  mem_wstrb,
    output reg  [31:0] mem_rdata,
    output reg         mem_ready
);
    localparam IMEM_BYTES = 128 * 1024;
    localparam DMEM_BYTES = 256 * 1024;
    localparam DATA_BASE  = 32'h00400000;

    reg [7:0] imem [0:IMEM_BYTES-1];
    reg [7:0] dmem [0:DMEM_BYTES-1];

    localparam IMEM_ADDR_W = $clog2(IMEM_BYTES);
    localparam DMEM_ADDR_W = $clog2(DMEM_BYTES);

    // Initialize memory from a hex file
    initial begin
        $readmemh("program.hex", imem);
    end

    // Simple memory model with one cycle latency (latched signals)
    reg mem_valid_latched;
    reg [31:0] mem_addr_latched;
    reg [31:0] mem_wdata_latched;
    reg [3:0]  mem_wstrb_latched;

    // Calculate the physical address and determine if it's an instruction or data access
    wire [IMEM_ADDR_W-1:0] imem_addr = mem_addr_latched[IMEM_ADDR_W-1:0];

    wire [31:0] dmem_offset = mem_addr_latched - DATA_BASE;
    wire [DMEM_ADDR_W-1:0] dmem_addr = dmem_offset[DMEM_ADDR_W-1:0];

    wire is_dmem = (mem_addr_latched >= DATA_BASE);

    // Access the appropriate memory based on the address
    always @(posedge clk) begin
        mem_ready <= 0; // Default to not ready

        // Latch the memory request signals
        if (mem_valid & !mem_valid_latched) begin
            mem_valid_latched <= 1;
            mem_addr_latched <= mem_addr;
            mem_wdata_latched <= mem_wdata;
            mem_wstrb_latched <= mem_wstrb;
        end

        if (mem_valid_latched) begin
            mem_ready <= 1; // Indicate that the memory is ready to accept the request

            if (is_dmem) begin
                // Data memory access
                if (|mem_wstrb_latched) begin
                    // Write operation
                    if (mem_wstrb_latched[0]) dmem[dmem_addr] <= mem_wdata_latched[7: 0];
                    if (mem_wstrb_latched[1]) dmem[dmem_addr + 1] <= mem_wdata_latched[15: 8];
                    if (mem_wstrb_latched[2]) dmem[dmem_addr + 2] <= mem_wdata_latched[23:16];
                    if (mem_wstrb_latched[3]) dmem[dmem_addr + 3] <= mem_wdata_latched[31:24];
                end else begin
                    // Read operation
                    mem_rdata <= {
                        dmem[dmem_addr + 3],
                        dmem[dmem_addr + 2],
                        dmem[dmem_addr + 1],
                        dmem[dmem_addr]
                    };
                end
            end else begin
                // Instruction memory access (read-only)
                mem_rdata <= {
                    imem[imem_addr + 3],
                    imem[imem_addr + 2],
                    imem[imem_addr + 1],
                    imem[imem_addr]
                };
            end

            // Clear the latched valid signal after processing the request
            mem_valid_latched <= 0;
        end
    end

endmodule
