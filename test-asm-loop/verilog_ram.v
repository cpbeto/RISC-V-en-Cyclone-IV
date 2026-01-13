module verilog_ram #(
    parameter MEM_WORDS = 1024
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

    reg [7:0] mem [0:MEM_WORDS-1];

    initial begin
        $readmemh("loop.hex", mem);
    end

    always @(posedge clk) begin
        mem_ready <= 0;

        if (mem_valid) begin
            mem_ready <= 1;

            if (|mem_wstrb) begin
                if (mem_wstrb[0]) mem[mem_addr] <= mem_wdata[7: 0];
                if (mem_wstrb[1]) mem[mem_addr + 1] <= mem_wdata[15: 8];
                if (mem_wstrb[2]) mem[mem_addr + 2] <= mem_wdata[23:16];
                if (mem_wstrb[3]) mem[mem_addr + 3] <= mem_wdata[31:24];
            end else begin
                assign mem_rdata = {
                    mem[mem_addr + 3],
                    mem[mem_addr + 2],
                    mem[mem_addr + 1],
                    mem[mem_addr]
                };
            end
        end
    end

endmodule
