`include "defines.vh"

module pc_reg(
    input wire clk,
    input wire rst,

    input wire[5:0] stall,

    input wire b_flag_i,
    input wire[`RegDataBus] b_target_addr_i,

    // exception and intterruptions
    input wire flush,
    input wire[`RegDataBus] new_pc,

    output reg[`InstAddrBus] pc
);

reg ce_n;

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        ce_n <= `ChipDisable;
    end
    else begin
        ce_n <= `ChipEnable;
    end
end

always @(posedge clk) begin
    if (ce_n == `ChipDisable) begin
        pc <= `PcRst;
    end else begin
        if(flush == 1'b1) begin
            pc <= new_pc;
        end
        else if (stall[0] == `NoStop) begin
            if (b_flag_i == `Branch) begin
                pc <= b_target_addr_i; //这里把32位的b_target_addr_i赋给22位的pc，因为base_ram最大只有22位的地址，但是为了和书上保持一致，计算地址的时候统一使用32位的计算
            end
            else begin
                pc <= pc + `PcStep;
            end
        end
    end
end

endmodule