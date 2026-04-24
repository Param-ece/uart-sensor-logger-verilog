module uart_rx (
    input  wire       clk,
    input  wire       rst,
    input  wire       baud_en,
    input  wire       rx,
    output reg  [7:0] data_out,
    output reg        rx_valid,
    output reg        rx_busy
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

localparam HALF_PERIOD = 2604;

reg [1:0]  state;
reg [12:0] cnt;
reg [2:0]  bit_idx;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state    <= IDLE;
        rx_valid <= 1'b0;
        rx_busy  <= 1'b0;
        bit_idx  <= 0;
        cnt      <= 0;
        data_out <= 0;
    end else begin

        case (state)
            IDLE: begin
                rx_busy  <= 1'b0;
                rx_valid <= 1'b0;
                cnt      <= 0;
                bit_idx  <= 0;
                if (rx == 1'b0) begin
                    rx_busy <= 1'b1;
                    state   <= START;
                end
            end

            START: begin
                if (cnt == HALF_PERIOD - 1) begin
                    cnt <= 0;
                    if (rx == 1'b0) begin
                        state <= DATA;
                    end else begin
                        state <= IDLE;
                    end
                end else begin
                    cnt <= cnt + 1;
                end
            end

            DATA: begin
                if (baud_en) begin
                    data_out[bit_idx] <= rx;
                    if (bit_idx == 3'd7) begin
                        bit_idx  <= 0;
                        rx_valid <= 1'b1;
                        state    <= STOP;
                    end else begin
                        bit_idx <= bit_idx + 1;
                    end
                end
            end

            STOP: begin
                if (baud_en) begin
                    rx_valid <= 1'b0;
                    state    <= IDLE;
                end
            end

        endcase
    end
end

endmodule
