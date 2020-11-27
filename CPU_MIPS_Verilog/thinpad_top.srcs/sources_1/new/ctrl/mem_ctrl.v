`include "defines.vh"

module mem_ctrl(
    input wire clk,
    input wire rst,
    input wire[`InstDataBus] pc_i,
    input wire[`RegDataBus] v_addr_i,
    input wire[`RegDataBus] data_i, //来自mem 模块的数�?
    input wire[`RegDataBus] code_data_i, //来自code ram的数�?
    input wire[`RegDataBus] data_data_i, //data ram的数�?

    input wire serial_data_ready_i,
    input wire serial_tbre,
    input wire serial_tsre,

    input wire[3:0] be_i_n,
    input wire we_i_n,
    input wire oe_i_n,
    input wire ce_i_n,


    output reg[1:0] type_o,

    output reg[3:0] code_be_o_n,
    output reg code_we_o_n,
    output reg code_oe_o_n,
    output reg code_ce_o_n,
    output reg[`RegDataBus] code_r_addr_o,
    output reg[`RegDataBus] code_data_o,

    output reg[3:0] data_be_o_n,
    output reg data_we_o_n,
    output reg data_oe_o_n,
    output reg data_ce_o_n,
    output reg[`RegDataBus] data_r_addr_o,
    output reg[`RegDataBus] data_data_o,

    output reg[`RegDataBus] inst_o,
    output reg[`RegDataBus] data_o, //从ram中读出的数据输出

    output reg serial_rdn,
    output reg serial_wrn,

    output reg stall_from_mem_o,
    output reg stall_from_store_o
);

reg[`RegDataBus] r_addr;
reg is_to_store;

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        is_to_store <= 1'b0;
    end
    else begin
        if (is_to_store == 1'b1) begin
            is_to_store <= 1'b0;
        end
        else begin
            if ((`UserDataLo <= v_addr_i) && (v_addr_i <= `KernelDataHi) && we_i_n == 1'b0) begin
                is_to_store <= 1'b1;
            end
        end
    end
end

always @(*) begin
    if (rst == `RstEnable) begin
        type_o <= `RstRamType;
        r_addr <= `ZERO32;

        code_be_o_n <= 4'b1111;
        code_we_o_n <= `Disable_N;
        code_oe_o_n <= `Disable_N;
        code_ce_o_n <= `Disable_N;
        code_r_addr_o <= `ZERO32;
        code_data_o <= `ZERO32;

        data_be_o_n <= 4'b1111;
        data_we_o_n <= `Disable_N;
        data_oe_o_n <= `Disable_N;
        data_ce_o_n <= `Disable_N;
        data_r_addr_o <= `ZERO32;
        data_data_o <= `ZERO32;

        stall_from_mem_o <= `NoStop;
        stall_from_store_o <= `NoStop;

        serial_wrn <= `Disable_N;
        serial_rdn <= `Disable_N;
        // is_to_store <= 1'b0;

    end
    else begin
        code_be_o_n <= 4'b0000;
        code_ce_o_n <= `Enable_N;
        code_we_o_n <= `Disable_N;
        code_oe_o_n <= `Enable_N;
        code_r_addr_o <= (pc_i - `KernelCodeLo) >> 2;
        //is_to_store <= 1'b0;

        data_be_o_n <= 4'b0000;
        data_ce_o_n <= `Enable_N;
        data_we_o_n <= `Disable_N;
        data_oe_o_n <= `Disable_N;
        data_r_addr_o <= `ZERO32;

        stall_from_mem_o <= `NoStop;
        stall_from_store_o <= `NoStop;

        serial_wrn <= `Disable_N;
        serial_rdn <= `Disable_N;

        if ((`KernelCodeLo <= v_addr_i) && (v_addr_i <= `UserCodeHi)) begin
            type_o <= `CodeRamType;
            r_addr <= (v_addr_i - `KernelCodeLo) >> 2;
            data_be_o_n <= 4'b0000;
            data_ce_o_n <= `Enable_N;
            data_we_o_n <= `Disable_N;
            data_oe_o_n <= `Disable_N;
            
            code_be_o_n <= be_i_n;
            code_we_o_n <= we_i_n;
            code_oe_o_n <= oe_i_n;
            code_ce_o_n <= ce_i_n;
            code_r_addr_o <= r_addr;
            code_data_o <= data_i;

            data_o <= code_data_i;

            stall_from_mem_o <= `Stop;
        end
        else if (v_addr_i == `UartDataLo) begin
            type_o <= `UartType;
            code_we_o_n <= `Disable_N;
            code_oe_o_n <= `Disable_N;
            code_ce_o_n <= `Disable_N;
            stall_from_mem_o <= `Stop;
            if (we_i_n == `Enable_N) begin
                // 写串�?
                serial_wrn <= `Enable_N;
                code_data_o <= data_i;
            end
            else if (oe_i_n == `Enable_N) begin
                // 读串�?
                serial_rdn <= `Enable_N;
                data_o <= code_data_i;
            end
        end
        else if ((v_addr_i == `UartDataHi) && (we_i_n == `Disable_N)) begin
            //串口状�?�位只读
            type_o <= `UartType;
            data_o <= {30'b0, serial_data_ready_i, serial_tsre && serial_tbre};
        end
        else begin
            // 没有对code mem的访存操�?
            inst_o <= code_data_i;
            if ((`UserDataLo <= v_addr_i) && (v_addr_i <= `KernelDataHi) && we_i_n == 1'b0) begin
                type_o <= `DataRamType;
                r_addr <= (v_addr_i - `UserDataLo) >> 2;

                data_be_o_n <= be_i_n;
                data_we_o_n <= clk;
                data_oe_o_n <= oe_i_n;
                data_ce_o_n <= ce_i_n;
                data_r_addr_o <= r_addr;
                data_data_o <= data_i;
                stall_from_store_o <= `Stop;
                if (is_to_store == 1) begin
                    stall_from_store_o <= `NoStop;
                    data_we_o_n <= `Enable_N;
                end
                //is_to_store <= 1'b1;
                data_o <= data_data_i;
            end else if((`UserDataLo <= v_addr_i) && (v_addr_i <= `KernelDataHi)) begin
                type_o <= `DataRamType;
                r_addr <= (v_addr_i - `UserDataLo) >> 2;

                data_be_o_n <= be_i_n;
                data_we_o_n <= we_i_n;
                data_oe_o_n <= oe_i_n;
                data_ce_o_n <= ce_i_n;
                data_r_addr_o <= r_addr;
                data_data_o <= data_i;
                //stall_from_mem_o <= `Stop;
                //is_to_store <= 1'b1;
                data_o <= data_data_i;
            end
            
        end
    end
end
/*
reg is_to_store;
reg[3:0] is_data_be_o_n;
reg is_data_we_o_n;
reg is_data_oe_o_n;
reg is_data_ce_o_n;

always @(posedge clk) begin
    if (is_to_store == 1'b1) begin
        data_be_o_n <= is_data_be_o_n;
        data_we_o_n <= is_data_we_o_n;
        data_oe_o_n <= is_data_oe_o_n;
        data_ce_o_n <= is_data_ce_o_n;
    end else begin
        data_be_o_n <= 4'b0000;
        data_ce_o_n <= `Enable_N;
        data_we_o_n <= `Disable_N;
        data_oe_o_n <= `Disable_N;
    end
end
*/
endmodule