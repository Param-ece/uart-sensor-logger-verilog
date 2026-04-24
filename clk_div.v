module clk_div #(parameter DIV = 5208)(
    input  wire clk,
    input  wire rst,
    output reg  clk_out
);

    integer count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count   <= 0;
            clk_out <= 0;
        end
        else if (count == (DIV/2 - 1)) begin
            clk_out <= ~clk_out;
            count   <= 0;
        end
        else begin
            count <= count + 1;
        end
    end

endmodule