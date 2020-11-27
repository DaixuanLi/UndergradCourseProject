`include "defines.vh"

module serial(
    input wire clk,
    input wire rst,

    input wire[7:0] mem_data_i,
    input wire[7:0] serial_data_i,
    input wire we_i,
    input wire oe_i,

    input wire busy, //串口可发送数据
    input wire ready, //串口接收到数据

    output reg[7:0] w_data_o,
    output reg[7:0] r_data_o,
    output wire[1:0] status_o,
    output reg start_o
);

assign status_o[0] = !busy;
assign status_o[1] = ready;

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        w_data_o <= `ZERO8;
        r_data_o <= `ZERO8;
        start_o <= 1'b0;
    end
    else begin
        if (oe_i) begin
            if (ready) begin
                r_data_o <= serial_data_i;
            end
        end
        if (we_i) begin
            if (!busy) begin
                w_data_o <= mem_data_i;
                start_o <= 1'b1;
            end
        end
        if (busy) begin
            start_o <= 1'b0;
        end
    end
end

endmodule