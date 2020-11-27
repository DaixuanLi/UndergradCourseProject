`include "defines.vh"

module debugger (
    input wire clk,
    input wire clk_btn,

    input wire t0_reg[31:0],
    input wire pc[31:0],

    output reg controled_t0_reg[31:0],
    output reg controled_pc[31:0],
);

always @ (posedge clk) begin
    if(clk_btn == 1'b0) begin
        controled_t0_reg <= t0_reg;
        controled_pc <= pc;
    end
end