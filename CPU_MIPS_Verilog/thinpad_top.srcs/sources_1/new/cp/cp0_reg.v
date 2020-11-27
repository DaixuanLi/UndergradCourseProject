`include "defines.vh"

module cp0_reg (
    input wire clk,
    input wire rst,

    //寄存器读写信�??
    input wire        we_i, //写寄存器使能
    input wire[`RegAddrBus]   waddr_i, //写寄存器地址
    input wire[`RegAddrBus]   raddr_i, //读寄存器地址
    input wire[`RegDataBus]   data_i, //写入的数�??
    
    //外部硬件中断信号输入
    input wire[5:0]   interr_i,

    input  wire[31:0] excepttype_i,
    input wire[`RegDataBus] current_inst_addr_i,
    input wire is_in_delay_slot_i,
    
    output reg[`RegDataBus]   data_o, //读出的数据地�??

    //寄存器的�??
    //output reg[`RegDataBus]   count_o,
    //output reg[`RegDataBus]   compare_o,
    output reg[`RegDataBus]   status_o,
    output reg[`RegDataBus]   ebase_o,
    output reg[`RegDataBus]   cause_o,
    output reg[`RegDataBus]   epc_o
    //output reg[`RegDataBus]   config_o,
    //output reg[`RegDataBus]   prid_o,

    //output reg                timer_int_o


);

//write operations for registers in cp0
always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        //CU字段�??4'b0001，表示协处理器CP0存在�??
        status_o <= 32'b00010000000000000001000000000000;
        
        //ebase寄存�?? Exception Base 设置�??0,表示异常向量的地�??。CPUNUM(9-0)字段设置�??0表示只有单个处理器�??
        ebase_o <= 32'b10000000000000000001000000000000;

        cause_o <= `ZERO32;

        epc_o <= `ZERO32;

    end else begin
        //store external interrupt declare
        cause_o[15:10] <= interr_i;

        if(we_i == `WriteEnable) begin
            case (waddr_i)
                `CP0_REG_STATUS: begin
                    status_o <= data_i;
                end
                `CP0_REG_EPC: begin
                    epc_o <= data_i;
                end
                `CP0_REG_EBASE: begin
                    // cannot write reserverd fields
                    ebase_o[31:12] <= data_i[31:12];
                    ebase_o[9:0] <= data_i[9:0];
                end
                `CP0_REG_CAUSE: begin
                    //IP[1:0] IV WP can be written
                    cause_o[9:8] <= data_i[9:8];
                    cause_o[23] <= data_i[23];
                    cause_o[22] <= data_i[22];
                end
                default: begin
                end
            endcase
        end

        case(excepttype_i)
            32'h00000001: begin //external intteruption
                if(is_in_delay_slot_i == `InDelay) begin
                    epc_o <= current_inst_addr_i - 4;
                    cause_o[31] <= 1'b1; //BD section of cause
                end else begin
                    epc_o <= current_inst_addr_i;
                    cause_o[31] <= 1'b0;
                end
                status_o[1] <= 1'b1; //EXL section of status
                cause_o[6:2] <= 5'b00000; //ExcCode section of cause
                $display("external inetrruption at %h",current_inst_addr_i);
            end
            32'h00000008: begin
                if(status_o[1] == 1'b0) begin
                    if(is_in_delay_slot_i == `InDelay) begin
                        epc_o <= current_inst_addr_i - 4;
                        cause_o[31] <= 1'b1;
                    end else begin
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                end
                status_o[1] <= 1'b1; //EXL section of status
                cause_o[6:2] <= 5'b01000; //ExcCode section of cause
                $display("syscall at %h",current_inst_addr_i);
            end
            32'h0000000e: begin
                status_o[1] <= 1'b0;
                $display("eret at %h",current_inst_addr_i);
            end
            32'h0000000a: begin
                if(status_o[1] == 1'b0) begin
                    if(is_in_delay_slot_i == `InDelay) begin
                        epc_o <= current_inst_addr_i - 4;
                        cause_o[31] <= 1'b1;
                    end else begin
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                end
                status_o[1] <= 1'b1; //EXL section of status
                cause_o[6:2] <= 5'b01010; //ExcCode section of cause
                $display("invalid instruction at %h",current_inst_addr_i);
            end
            default: begin
            end
        endcase
    end
end

always @ (*) begin
    if(rst == `RstEnable) begin
        data_o <= `ZERO32;
    end else begin
        case(raddr_i)
            `CP0_REG_CAUSE: begin
                data_o <= cause_o;
            end
            `CP0_REG_EBASE: begin
                data_o <= ebase_o;
            end
            `CP0_REG_EPC: begin
                data_o <= epc_o;
            end
            `CP0_REG_STATUS: begin
                data_o <= status_o;
            end
        endcase
    end
end
    
endmodule