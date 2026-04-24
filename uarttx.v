module uart_tx (
    input  wire       clk,
    input  wire       rst,
    input  wire       baud_en,
    input  wire [7:0] data_in,
    input  wire       tx_start,
    output reg        tx,
    output reg        tx_busy,
    output reg        tx_done
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [7:0] tx_shift;
reg [2:0] bit_idx;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state    <= IDLE;
        tx       <= 1'b1;
        tx_busy  <= 1'b0;
        tx_done  <= 1'b0;
        bit_idx  <= 0;
        tx_shift <= 0;
    end else begin
        tx_done <= 1'b0;  // default: clear every clock

        case (state)
            IDLE: begin
                tx      <= 1'b1;
                tx_busy <= 1'b0;
                if (tx_start) begin
                    tx_shift <= data_in;
                    bit_idx  <= 0;
                    tx_busy  <= 1'b1;
                    state    <= START;
                end
            end

            START: begin
                tx <= 1'b0;
                if (baud_en) begin
                    state <= DATA;
                end
            end

            DATA: begin
                tx <= tx_shift[bit_idx];
                if (baud_en) begin
                    if (bit_idx == 3'd7) begin
                        bit_idx <= 0;
                        state   <= STOP;
                    end else begin
                        bit_idx <= bit_idx + 1;
                    end
                end
            end

            STOP: begin
                tx <= 1'b1;
                if (baud_en) begin
                    tx_done <= 1'b1;
                    tx_busy <= 1'b0;
                    state   <= IDLE;
                end
            end

        endcase
    end
end

endmodule

   
