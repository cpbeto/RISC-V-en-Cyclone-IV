module soc (
    input wire clk,
    input wire resetn
);

    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;
    wire        trace_valid;
    wire [35:0] trace_data;


    picorv32 #(
        .PROGADDR_RESET(32'h00000000),
        .ENABLE_MUL(0),
        .ENABLE_DIV(0),
        .ENABLE_IRQ(0),
        .ENABLE_TRACE(1)
    ) cpu (
        .clk         (clk),
        .resetn      (resetn),
        .mem_valid   (mem_valid),
        .mem_instr   (mem_instr),
        .mem_ready   (mem_ready),
        .mem_addr    (mem_addr),
        .mem_wdata   (mem_wdata),
        .mem_wstrb   (mem_wstrb),
        .mem_rdata   (mem_rdata),
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

    integer cycle = 0;
    always @(posedge clk) cycle <= cycle + 1;

    always @(posedge clk) begin
        if (trace_valid)
            $display("[C%0d] RETIRE PC=%08x", cycle, trace_data[31:0]);

        if (mem_valid && mem_ready && !mem_wstrb)
            $display("[C%0d] FETCH addr=%08x data=%08x", cycle, mem_addr, mem_rdata);
    end

endmodule
