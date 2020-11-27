`include "defines.vh"

module mem(
    input wire rst,
    input wire clk,
    
    input wire[`AluOpBus] alu_op_i,
    input wire[`RegDataBus] mem_addr_i,
    input wire[`RegDataBus] reg2_data_i,
    input wire[`RegDataBus] mem_data_i,


    input wire[`RegAddrBus] w_addr_i,
    input wire[`RegDataBus] w_data_i,
    input wire w_reg_i,

    input wire cp0_reg_we_i,
    input wire[`RegAddrBus] cp0_reg_write_addr_i,
    input wire[`RegDataBus] cp0_reg_data_i,

    output reg cp0_reg_we_o,
    output reg[`RegAddrBus] cp0_reg_write_addr_o,
    output reg[`RegDataBus] cp0_reg_data_o,

    //exception for mem
    input wire[31:0] excepttype_i,
    input wire is_in_delayslot_i,
    input wire[`RegDataBus] current_inst_address_i,

    input wire[`RegDataBus] cp0_status_i,
    input wire[`RegDataBus] cp0_cause_i,
    input wire[`RegDataBus] cp0_epc_i,

    //data relations in exceptions
    input wire wb_cp0_reg_we,
    input wire[4:0] wb_cp0_reg_write_addr,
    input wire[`RegDataBus] wb_cp0_reg_data,

    output reg[31:0] excepttype_o,
    output wire[`RegDataBus] cp0_epc_o,
    output wire is_in_delayslot_o,

    output wire[`RegDataBus] current_inst_address_o,

    output reg[`RegAddrBus] w_addr_o,
    output reg[`RegDataBus] w_data_o,
    output reg w_reg_o,

    output reg[`RegDataBus] mem_addr_o,
    output reg[3:0] mem_be_o_n,
    output wire mem_we_o_n,
    output reg mem_oe_o_n,
    output reg mem_ce_o_n,
    output reg[`RegDataBus] mem_data_o
    
);

wire[`RegDataBus] zero32;
reg[`RegDataBus] cp0_status;
reg[`RegDataBus] cp0_cause;
reg[`RegDataBus] cp0_epc;
reg mem_we;

assign zero32 =  `ZERO32;
// mem is in delay slot
assign is_in_delayslot_o = is_in_delayslot_i;
// mem instruction address
assign current_inst_address_o = current_inst_address_i;

//fetch current data from cp0

always @(*) begin
    if (rst == `RstEnable) begin
        cp0_cause <= `ZERO32;
    end else if((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_CAUSE)) begin
        cp0_cause[9:8] <= wb_cp0_reg_data[9:8];
        cp0_cause[22] <= wb_cp0_reg_data[22];
        cp0_cause[23] <= wb_cp0_reg_data[23];
    end else begin
        cp0_cause <= cp0_cause_i;
    end
end

always @(*) begin
    if (rst == `RstEnable) begin
        cp0_epc <= `ZERO32;
    end else if((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_EPC)) begin
        cp0_epc <= wb_cp0_reg_data;
    end else begin
        cp0_epc <= cp0_epc_i;
    end
end
// output current epc data
assign cp0_epc_o = cp0_epc;

always @(*) begin
    if (rst == `RstEnable) begin
        cp0_status <= `ZERO32;
    end else if((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_STATUS)) begin
        cp0_status <= wb_cp0_reg_data;
    end else begin
        cp0_status <= cp0_status_i;
    end
end

// give final exception type
always @ (*) begin
    if (rst == `RstEnable) begin
        excepttype_o <= `ZERO32;
    end else begin
        excepttype_o <= `ZERO32;
        if(current_inst_address_i != `ZERO32) begin
            if((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00 && 
                (cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin
                excepttype_o <= 32'h00000001; // interrupt
            end else if(excepttype_i[8] == 1'b1) begin
                excepttype_o <= 32'h00000008; //syscall
            end else if(excepttype_i[12] == 1'b1) begin
                excepttype_o <= 32'h0000000e; //eret
            end else if(excepttype_i[9] == 1'b1) begin
                excepttype_o <= 32'h0000000a; //inst invalid
            end
        end
    end
end


assign mem_we_o_n = mem_we & (~(|excepttype_o));

always @(*) begin
    //ori 指令不涉及访存，因此输入数据直接通过
    if (rst == `RstEnable) begin
        w_addr_o <= `NOPRegAddr;
        w_data_o <= `ZERO32;
        w_reg_o <= `WriteDisable;

        cp0_reg_we_o <= `WriteDisable;
        cp0_reg_write_addr_o <= 5'b00000;
        cp0_reg_data_o <= `ZERO32;

        mem_addr_o <= `ZERO32;
        mem_we <= `Disable_N;
        mem_oe_o_n <= `Disable_N;
        mem_data_o <= `ZERO32;

        mem_ce_o_n <= `Disable_N;
        
        mem_be_o_n <= 4'b1111;
    end
    else begin
        w_addr_o <= w_addr_i;
        w_data_o <= w_data_i;
        w_reg_o <= w_reg_i;

        cp0_reg_we_o <= cp0_reg_we_i;
        cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
        cp0_reg_data_o <= cp0_reg_data_i;

        mem_we <= `Disable_N;
        mem_addr_o <= `ZERO32;
        mem_oe_o_n <= `Disable_N;
        mem_ce_o_n <= `Enable_N;
        mem_be_o_n <= 4'b0000;

        case (alu_op_i)
            `EXE_LB_OP : begin
                mem_addr_o <= mem_addr_i;
                mem_we <= `Disable_N;
                mem_oe_o_n <= `Enable_N;
                case (mem_addr_i[1:0]) 
                    2'b00: begin
                        w_data_o <= {{24{mem_data_i[7]}}, mem_data_i[7:0]};
                    end
                    2'b01: begin
                        w_data_o <= {{24{mem_data_i[15]}}, mem_data_i[15:8]};
                    end
                    2'b10: begin
                        w_data_o <= {{24{mem_data_i[23]}}, mem_data_i[23:16]};
                    end
                    2'b11: begin
                        w_data_o <= {{24{mem_data_i[31]}}, mem_data_i[31:24]};
                    end
                    default: begin
                        w_data_o <= `ZERO32;
                    end
                endcase
            end
            `EXE_LW_OP: begin
                mem_addr_o <= mem_addr_i;
                mem_we <= `Disable_N;
                mem_oe_o_n <= `Enable_N;
                w_data_o <= mem_data_i;
            end
            `EXE_SB_OP: begin
                mem_addr_o <= mem_addr_i;
                mem_we <= `Enable_N;
                mem_oe_o_n <= `Disable_N;
                mem_data_o <= {reg2_data_i[7:0], reg2_data_i[7:0], reg2_data_i[7:0], reg2_data_i[7:0]};
                case (mem_addr_i[1:0])
                    2'b00: begin
                        //使用mem_be_o_n信号来控制一个字里面写哪些字�?
                        mem_be_o_n <= 4'b1110;
                    end
                    2'b01: begin
                        mem_be_o_n <= 4'b1101;
                    end
                    2'b10: begin
                        mem_be_o_n <= 4'b1011;
                    end
                    2'b11: begin
                        mem_be_o_n <= 4'b0111;
                    end
                    default: begin
                    end
                endcase
            end
            `EXE_SW_OP: begin
                mem_addr_o <= mem_addr_i;
                mem_we <= `Enable_N;
                mem_oe_o_n <= `Disable_N;
                mem_data_o <= reg2_data_i;
            end
        endcase
    end
end

endmodule