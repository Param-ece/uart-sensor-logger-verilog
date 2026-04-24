module top (
    input  wire clk,
    input  wire rst,
    output wire tx,        // goes to PC/receiver
    input  wire rx         // loopback or external rx
);

wire        baud_en;
wire [7:0]  temp_data, hum_data;
wire        data_ready;
wire        tx_busy, tx_done;
wire [7:0]  rx_data;
wire        rx_valid, rx_busy;

reg [1:0] state;
reg [7:0] tx_data;
reg       tx_start;


clk_div #(.DIV(5208)) u_clk_div (
    .clk     (clk),
    .rst     (rst),
    .clk_out (baud_en)
);

sensor_sim u_sensor (
    .clk        (clk),
    .rst        (rst),
    .temp_data  (temp_data),
    .hum_data   (hum_data),
    .data_ready (data_ready)
);


uart_tx u_tx (
    .clk      (clk),
    .rst      (rst),
    .baud_en  (baud_en),
    .data_in  (tx_data),
    .tx_start (tx_start),
    .tx       (tx),
    .tx_busy  (tx_busy),
    .tx_done  (tx_done)
);


uart_rx u_rx (
    .clk      (clk),
    .rst      (rst),
    .baud_en  (baud_en),
    .rx       (tx),        // loopback: rx reads what tx sends
    .data_out (rx_data),
    .rx_valid (rx_valid),
    .rx_busy  (rx_busy)
);


localparam IDLE     = 2'b00;
localparam SEND_TEMP = 2'b01;
localparam SEND_HUM  = 2'b10;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        state    <= IDLE;
        tx_data  <= 0;
        tx_start <= 0;
    end else begin
        tx_start <= 1'b0;   // default: no trigger

        case (state)
            IDLE: begin
                if (data_ready) begin
                    tx_data  <= temp_data;  // load temperature
                    tx_start <= 1'b1;       // fire TX
                    state    <= SEND_TEMP;
                end
            end

            SEND_TEMP: begin
                if (tx_done) begin          // temp byte finished
                    tx_data  <= hum_data;   // load humidity
                    tx_start <= 1'b1;       // fire TX again
                    state    <= SEND_HUM;
                end
            end

            SEND_HUM: begin
                if (tx_done) begin          // humidity byte finished
                    state <= IDLE;          // all done, wait for next reading
                end
            end

        endcase
    end
end

endmodule
