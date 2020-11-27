`include "defines.vh"

module id_ex(
    input wire clk,
    input wire rst,

    input wire[`RegDataBus] id_inst,

    input wire[5:0] stall,

    input wire[`AluOpBus] id_alu_op,
    input wire[`AluTypeBus] id_alu_type,
    input wire[`RegDataBus] id_reg1_data,
    input wire[`RegDataBus] id_reg2_data,
    input wire[`RegAddrBus] id_w_addr,
    input wire id_w_reg,

    input wire[`RegDataBus] id_link_addr,
    input wire id_in_delay,
    input wire id_next_in_delay,

    input wire flush,
    input wire[`RegDataBus] id_current_inst_address,
    input wire[31:0] id_excepttype,

    output reg[`RegDataBus] ex_current_inst_address,
    output reg[31:0] ex_excepttype,

    output reg[`RegDataBus] ex_inst,
    
    output reg[`AluOpBus] ex_alu_op,
    output reg[`AluTypeBus] ex_alu_type,
    output reg[`RegDataBus] ex_reg1_data,
    output reg[`RegDataBus] ex_reg2_data,
    output reg[`RegAddrBus] ex_w_addr,
    output reg ex_w_reg,

    output reg[`RegDataBus] ex_link_addr,
    output reg ex_in_delay,
    output reg ex_next_in_delay

);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        ex_alu_op <= `EXE_NOP_OP;
        ex_alu_type <= `EXE_TYPE_NOP;
        ex_reg1_data <= `ZERO32;
        ex_reg2_data <= `ZERO32;
        ex_w_addr <= `NOPRegAddr;
        ex_w_reg <= `WriteDisable;

        ex_link_addr <= `ZERO32;
        ex_in_delay <= `NotInDelay;
        ex_next_in_delay <= `NotInDelay;

        ex_excepttype <= `ZERO32;
        ex_current_inst_address <= `ZERO32;

        ex_inst <= `ZERO32;
    end else if(flush == 1'b1) begin
        ex_alu_op <= `EXE_NOP_OP;
        ex_alu_type <= `EXE_TYPE_NOP;
        ex_reg1_data <= `ZERO32;
        ex_reg2_data <= `ZERO32;
        ex_w_addr <= `NOPRegAddr;
        ex_w_reg <= `WriteDisable;

        ex_link_addr <= `ZERO32;
        ex_in_delay <= `NotInDelay;
        ex_next_in_delay <= `NotInDelay;

        ex_excepttype <= `ZERO32;
        ex_current_inst_address <= `ZERO32;

        ex_inst <= `ZERO32;
    end
    else if ((stall[2] == `Stop) && (stall[3] == `NoStop)) begin
        ex_alu_op <= `EXE_NOP_OP;
        ex_alu_type <= `EXE_TYPE_NOP;
        ex_reg1_data <= `ZERO32;
        ex_reg2_data <= `ZERO32;
        ex_w_addr <= `NOPRegAddr;
        ex_w_reg <= `WriteDisable;

        ex_link_addr <= `ZERO32;
        ex_in_delay <= `NotInDelay;
        //ex_next_in_delay should not change because it returns to id section.

        ex_excepttype <= `ZERO32;
        ex_current_inst_address <= `ZERO32;

        ex_inst <= `ZERO32;
    end
    else if (stall[2] == `NoStop) begin
        ex_alu_op <= id_alu_op;
        ex_alu_type <= id_alu_type;
        ex_reg1_data <= id_reg1_data;
        ex_reg2_data <= id_reg2_data;
        ex_w_addr <= id_w_addr;
        ex_w_reg <= id_w_reg;

        ex_link_addr <= id_link_addr;
        ex_in_delay <= id_in_delay;
        ex_next_in_delay <= id_next_in_delay;

        ex_excepttype <= id_excepttype;
        ex_current_inst_address <= id_current_inst_address;

        ex_inst <= id_inst;
    end
end
endmodule