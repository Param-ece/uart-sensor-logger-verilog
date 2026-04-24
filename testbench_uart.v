`timescale 1ns/1ps
module top_tb;

// Testbench signals
reg  clk;
reg  rst;
wire tx;
wire rx;

// Instantiate top module
top u_top (
    .clk (clk),
    .rst (rst),
    .tx  (tx),
    .rx  (rx)
);

initial clk = 0;
always #5 clk = ~clk;   // toggles every 5ns = 100MHz

// Stimulus
initial begin
    // apply reset
    rst = 1;
    #100;
    rst = 0;

    // wait long enough for sensor to fire (1 second = 100M cycles)
    // at 100MHz, 1 cycle = 10ns, so 1 second = 1_000_000_000 ns
    #1_100_000_000;

    $finish;
end

// Monitor ? prints whenever RX receives a valid byte
initial begin
    $monitor("Time=%0t | rx_valid=%b | rx_data=0x%h",
              $time, u_top.rx_valid, u_top.rx_data);
end

// Waveform dump ? open in Vivado or GTKWave
initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);
end

endmodule
