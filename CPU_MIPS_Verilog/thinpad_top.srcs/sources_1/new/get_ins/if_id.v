`include "defines.vh"

module if_id (
    input wire clk,
    input wire rst,
    input wire[5:0] stall,

    input wire[`InstAddrBus] if_pc,
    input wire[`InstDataBus] if_inst,

    input wire flush,

    output reg[`InstAddrBus] id_pc,
    output reg[`InstDataBus] id_inst
);

always@(posedge clk) begin
    if (rst == `RstEnable) begin
        id_pc <= `ZERO32;
        id_inst <= `ZERO32;
    end
    else if (flush == 1'b1) begin
        id_pc <= `ZERO32;
        id_inst <= `ZERO32;
    end
    else if ((stall[1] == `Stop) && (stall[2] == `NoStop)) begin
        // id_pc <= `ZERO32;
        // id_inst <= `ZERO32;
    end
    else if (stall[1] == `NoStop) begin
        id_pc <= if_pc;
        id_inst <= if_inst;
    end

end
endmodule