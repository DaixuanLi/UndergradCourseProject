`include "defines.vh"

module ctrl(
    input wire rst,
    input wire stall_from_id_i,
    input wire stall_from_ex_i,
    input wire stall_from_mem_i,
    input wire stall_from_store_i,

    input wire[31:0] excepttype_i,
    input wire[`RegDataBus] cp0_epc_i,

    output reg[`RegDataBus] new_pc,
    output reg flush,

    output reg[5:0] stall
);

always @(*) begin
    if (rst == `RstEnable) begin
        stall <= 6'b000000;
        flush <= 1'b0;
        new_pc <= `ZERO32;
    end
    else if (excepttype_i != `ZERO32) begin
        flush <= 1'b1;
        new_pc <= `ZERO32;
        stall <= 6'b000000;
        case(excepttype_i)
            32'h00000001: begin
                new_pc <= `InterruptAddr;
            end
            32'h00000008: begin
                new_pc <= `InterruptAddr;
            end
            32'h0000000a: begin
                new_pc <= `InterruptAddr;
            end
            32'h0000000e: begin
                new_pc <= cp0_epc_i;
            end
            default: begin
            end
        endcase
    end
    else if (stall_from_store_i == `Stop) begin
        stall <= 6'b011111;
        flush <= 1'b0;
    end
    else if (stall_from_ex_i == `Stop) begin
        stall <= 6'b001111;
        flush <= 1'b0;
    end
    else if (stall_from_id_i == `Stop) begin
        stall <= 6'b000111;
        flush <= 1'b0;
    end
    else if (stall_from_mem_i == `Stop) begin
        stall <= 6'b000011;
        flush <= 1'b0;
    end
    else begin
        stall <= 6'b000000;
        flush <= 1'b0;
        new_pc <= `ZERO32;
    end
end

endmodule