module blink (
    input  wire clk,
    output reg [4:0] led
);

    reg [25:0] cnt;

    always @(posedge clk) begin
        cnt <= cnt + 1;
        led <= cnt[25:21];   // 5 slow bits → 5 LEDs
    end

endmodule
