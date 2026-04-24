module sensor_sim (
    input  wire        clk,
    input  wire        rst,
    output reg  [7:0]  temp_data,   // temperature byte
    output reg  [7:0]  hum_data,    // humidity byte
    output reg         data_ready   // pulses HIGH for 1 clk every second
);

localparam ONE_SECOND = 100_000_000;

reg [26:0] cnt;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        cnt        <= 0;
        data_ready <= 0;
        temp_data  <= 8'h18;   // start at 24°C
        hum_data   <= 8'h3C;   // start at 60%
    end else begin
        data_ready <= 1'b0;    // default: not ready

        if (cnt == ONE_SECOND - 1) begin
            cnt        <= 0;
            data_ready <= 1'b1;        // pulse ready signal
            temp_data  <= temp_data + 1;  // increment temp each second
            hum_data   <= hum_data  + 1;  // increment humidity each second
        end else begin
            cnt <= cnt + 1;
        end
    end
end

endmodule
