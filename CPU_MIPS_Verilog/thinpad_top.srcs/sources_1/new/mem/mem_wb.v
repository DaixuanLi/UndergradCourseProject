`include "defines.vh"

module mem_wb(
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] mem_w_addr,
    input wire mem_w_reg,
    input wire[`RegDataBus] mem_w_data,

    input wire[5:0] stall,

    input wire mem_cp0_reg_we,
    input wire[`RegAddrBus] mem_cp0_reg_write_addr,
    input wire[`RegDataBus] mem_cp0_reg_data,

    input wire flush,

    output reg wb_cp0_reg_we,
    output reg[`RegAddrBus] wb_cp0_reg_write_addr,
    output reg[`RegDataBus] wb_cp0_reg_data,

    output reg[`RegAddrBus] wb_w_addr,
    output reg wb_w_reg,
    output reg[`RegDataBus] wb_w_data
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        wb_w_data <= `ZERO32;
        wb_w_reg <= `WriteDisable;
        wb_w_addr <= `NOPRegAddr;
        wb_cp0_reg_we <= `WriteDisable;
        wb_cp0_reg_write_addr <= 5'b00000;
        wb_cp0_reg_data <= `ZERO32;
    end
    else if(flush == 1'b1) begin
        wb_w_data <= `ZERO32;
        wb_w_reg <= `WriteDisable;
        wb_w_addr <= `NOPRegAddr;
        wb_cp0_reg_we <= `WriteDisable;
        wb_cp0_reg_write_addr <= 5'b00000;
        wb_cp0_reg_data <= `ZERO32;
    end
    else if ((stall[4] == `Stop) && (stall[5] == `NoStop)) begin
        wb_w_data <= `ZERO32;
        wb_w_addr <= `NOPRegAddr;
        wb_w_reg <= `WriteDisable;
        wb_cp0_reg_we <= `WriteDisable;
        wb_cp0_reg_write_addr <= 5'b00000;
        wb_cp0_reg_data <= `ZERO32;
    end
    else if (stall[4] == `NoStop) begin
        wb_w_data <= mem_w_data;
        wb_w_addr <= mem_w_addr;
        wb_w_reg <= mem_w_reg;
        wb_cp0_reg_we <= mem_cp0_reg_we;
        wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
        wb_cp0_reg_data <= mem_cp0_reg_data;
    end
end

endmodule