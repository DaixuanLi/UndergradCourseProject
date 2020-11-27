`include "defines.vh"

module ex_mem(
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] ex_w_addr,
    input wire ex_w_reg,
    input wire[`RegDataBus] ex_w_data,

    input wire[5:0] stall,

    input wire[`AluOpBus] ex_alu_op,
    input wire[`RegDataBus] ex_mem_addr,
    input wire[`RegDataBus] ex_reg2_data,

    // cp0
    input wire ex_cp0_reg_we,
    input wire[`RegAddrBus] ex_cp0_reg_write_addr,
    input wire[`RegDataBus] ex_cp0_reg_data,

    output reg mem_cp0_reg_we,
    output reg[`RegAddrBus] mem_cp0_reg_write_addr,
    output reg[`RegDataBus] mem_cp0_reg_data,

    input wire flush,
    input wire[31:0] ex_excepttype,
    input wire ex_is_in_delayslot,
    input wire[`RegDataBus] ex_current_inst_address,


    output reg[31:0] mem_excepttype,
    output reg mem_is_in_delayslot,
    output reg[`RegDataBus] mem_current_inst_address,

    output reg[`RegAddrBus] mem_w_addr,
    output reg mem_w_reg,
    output reg[`RegDataBus] mem_w_data,

    output reg[`AluOpBus] mem_alu_op,
    output reg[`RegDataBus] mem_mem_addr,
    output reg[`RegDataBus] mem_reg2_data
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        mem_w_addr <= `NOPRegAddr;
        mem_w_reg <= `WriteDisable;
        mem_w_data <= `ZERO32;

        mem_alu_op <= `EXE_NOP_OP;
        mem_mem_addr <= `ZERO32;
        mem_reg2_data <= `ZERO32;

        mem_excepttype <= `ZERO32;
        mem_is_in_delayslot <= `NotInDelay;
        mem_current_inst_address <= `ZERO32;

        mem_cp0_reg_we <= `WriteDisable;
        mem_cp0_reg_write_addr <= `NOPRegAddr;
        mem_cp0_reg_data <= `ZERO32;
    end
    else if (flush == 1'b1) begin
        mem_w_addr <= `NOPRegAddr;
        mem_w_reg <= `WriteDisable;
        mem_w_data <= `ZERO32;

        mem_alu_op <= `EXE_NOP_OP;
        mem_mem_addr <= `ZERO32;
        mem_reg2_data <= `ZERO32;

        mem_excepttype <= `ZERO32;
        mem_is_in_delayslot <= `NotInDelay;
        mem_current_inst_address <= `ZERO32;

        mem_cp0_reg_we <= `WriteDisable;
        mem_cp0_reg_write_addr <= `NOPRegAddr;
        mem_cp0_reg_data <= `ZERO32;
    end
    else if ((stall[3] == `Stop) && (stall[4] == `NoStop)) begin
        mem_w_addr <= `NOPRegAddr;
        mem_w_reg <= `WriteDisable;
        mem_w_data <= `ZERO32;

        mem_alu_op <= `EXE_NOP_OP;
        mem_mem_addr <= `ZERO32;
        mem_reg2_data <= `ZERO32;

        mem_excepttype <= `ZERO32;
        mem_is_in_delayslot <= `NotInDelay;
        mem_current_inst_address <= `ZERO32;

        mem_cp0_reg_we <= `WriteDisable;
        mem_cp0_reg_write_addr <= `NOPRegAddr;
        mem_cp0_reg_data <= `ZERO32;
    end
    else if (stall[3] == `NoStop) begin
        mem_w_addr <= ex_w_addr;
        mem_w_reg <= ex_w_reg;
        mem_w_data <= ex_w_data;

        mem_cp0_reg_we <= ex_cp0_reg_we;
        mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
        mem_cp0_reg_data <= ex_cp0_reg_data;

        mem_alu_op <= ex_alu_op;
        mem_mem_addr <= ex_mem_addr;
        mem_reg2_data <= ex_reg2_data;

        mem_excepttype <= ex_excepttype;
        mem_is_in_delayslot <= ex_is_in_delayslot;
        mem_current_inst_address <= ex_current_inst_address;
        
    end
end

endmodule