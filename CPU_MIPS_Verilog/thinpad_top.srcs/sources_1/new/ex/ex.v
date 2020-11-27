`include "defines.vh"

module ex(
    input wire rst,

    input wire[`RegDataBus] inst_i,
    input wire[`AluOpBus] alu_op_i,
    input wire[`AluTypeBus] alu_type_i,
    input wire[`RegDataBus] reg1_data_i,
    input wire[`RegDataBus] reg2_data_i,
    input wire[`RegAddrBus] w_addr_i,
    input wire w_reg_i,
    
    input wire[`RegDataBus] link_addr_i,

    input wire in_delay_i, //实现异常的时候会用到

    // write cp0 signals from mem section
    input wire mem_cp0_reg_we,
    input wire[`RegAddrBus] mem_cp0_reg_write_addr,
    input wire[`RegDataBus] mem_cp0_reg_data,

    // write cp0 signals from wb section
    input wire wb_cp0_reg_we,
    input wire[`RegAddrBus] wb_cp0_reg_write_addr,
    input wire[`RegDataBus] wb_cp0_reg_data,

    // cp0 direct datas
    input wire[`RegDataBus] cp0_reg_data_i,

    input wire[31:0] excepttype_i,
    input wire[`RegDataBus] current_inst_address_i,

    output wire[31:0] excepttype_o,
    output wire is_in_delay_slot_o,
    output wire[`RegDataBus] current_inst_address_o,

    // cp0 direct datas
    output reg[`RegAddrBus] cp0_reg_read_addr_o,

    // cp0 to next section
    output reg cp0_reg_we_o,
    output reg[`RegAddrBus] cp0_reg_write_addr_o,
    output reg[`RegDataBus] cp0_reg_data_o,

    output reg[`RegAddrBus] w_addr_o,
    output reg w_reg_o,
    output reg[`RegDataBus] w_data_o,

    output reg stall_from_ex_o,

    output wire[`AluOpBus] alu_op_o,
    output wire[`RegDataBus] mem_addr_o,
    output wire[`RegDataBus] reg2_data_o
);

reg[`RegDataBus] logicout;
reg[`RegDataBus] shiftout;
reg[`RegDataBus] arithout;
reg[`RegDataBus] moveout;

assign alu_op_o = alu_op_i;
assign mem_addr_o = reg1_data_i + {{16{inst_i[15]}}, inst_i[15:0]};
assign reg2_data_o = reg2_data_i;
// no trap in our test bench.
assign excepttype_o = excepttype_i;
assign is_in_delay_slot_o = in_delay_i;
assign current_inst_address_o = current_inst_address_i;

always @(*) begin
    if (rst == `RstEnable) begin
        moveout <= `ZERO32;
    end
    else begin
        moveout <= `ZERO32;
        case (alu_op_i)
            `EXE_MOVN_OP: begin
                moveout <= reg1_data_i;
            end
            `EXE_MFC0_OP: begin
                cp0_reg_read_addr_o <= inst_i[15:11];
                moveout <= cp0_reg_data_i;

                if(mem_cp0_reg_we == `WriteEnable && 
                   mem_cp0_reg_write_addr == inst_i[15:11])
                begin 
                    moveout <= mem_cp0_reg_data;
                end else if( wb_cp0_reg_we == `WriteEnable &&
                            wb_cp0_reg_write_addr == inst_i[15:11])
                begin
                    moveout <= wb_cp0_reg_data;
                end
            end
        endcase
    end
end

always @(*) begin
    if (rst == `RstEnable) begin
        logicout <= `ZERO32;
    end
    else begin
        case (alu_op_i)
            `EXE_OR_OP: begin
                logicout <= reg1_data_i | reg2_data_i;
            end
            `EXE_AND_OP: begin
                logicout <= reg1_data_i & reg2_data_i;
            end
            `EXE_XOR_OP: begin
                logicout <= reg1_data_i ^ reg2_data_i;
            end
            default: begin
                logicout <= `ZERO32;
            end
        endcase
    end
end

always @(*) begin
    if (rst == `RstEnable) begin
        shiftout <= `ZERO32;
    end
    else begin
        case (alu_op_i)
            `EXE_SLL_OP: begin
                shiftout <= reg2_data_i << reg1_data_i[4:0];
            end
            `EXE_SRL_OP: begin
                shiftout <= reg2_data_i >> reg1_data_i[4:0];
            end
            `EXE_SRA_OP: begin
                shiftout <= $signed(reg2_data_i) >>> reg1_data_i[4:0];
            end
            default: begin
                shiftout <= `ZERO32;
            end
        endcase
    end
end

always @(*) begin
    if (rst == `RstEnable) begin
        arithout <= `ZERO32;
    end
    else begin
        case (alu_op_i)
            `EXE_ADD_OP: begin
                arithout <= reg1_data_i + reg2_data_i;
            end
            `EXE_CLO_OP: begin
                arithout <= (
                    (reg1_data_i[31] == 1'b0) ? 0 : 
                    (reg1_data_i[30] == 1'b0) ? 1 : 
                    (reg1_data_i[29] == 1'b0) ? 2 : 
                    (reg1_data_i[28] == 1'b0) ? 3 : 
                    (reg1_data_i[27] == 1'b0) ? 4 : 
                    (reg1_data_i[26] == 1'b0) ? 5 : 
                    (reg1_data_i[25] == 1'b0) ? 6 : 
                    (reg1_data_i[24] == 1'b0) ? 7 : 
                    (reg1_data_i[23] == 1'b0) ? 8 :
                    (reg1_data_i[22] == 1'b0) ? 9 : 
                    (reg1_data_i[21] == 1'b0) ? 10 : 
                    (reg1_data_i[20] == 1'b0) ? 11 : 
                    (reg1_data_i[19] == 1'b0) ? 12 : 
                    (reg1_data_i[18] == 1'b0) ? 13 : 
                    (reg1_data_i[17] == 1'b0) ? 14 : 
                    (reg1_data_i[16] == 1'b0) ? 15 : 
                    (reg1_data_i[15] == 1'b0) ? 16 : 
                    (reg1_data_i[14] == 1'b0) ? 17 : 
                    (reg1_data_i[13] == 1'b0) ? 18 : 
                    (reg1_data_i[12] == 1'b0) ? 19 : 
                    (reg1_data_i[11] == 1'b0) ? 20 : 
                    (reg1_data_i[10] == 1'b0) ? 21 : 
                    (reg1_data_i[9] == 1'b0) ? 22 : 
                    (reg1_data_i[8] == 1'b0) ? 23 : 
                    (reg1_data_i[7] == 1'b0) ? 24 : 
                    (reg1_data_i[6] == 1'b0) ? 25 : 
                    (reg1_data_i[5] == 1'b0) ? 26 : 
                    (reg1_data_i[4] == 1'b0) ? 27 : 
                    (reg1_data_i[3] == 1'b0) ? 28 :
                    (reg1_data_i[2] == 1'b0) ? 29 : 
                    (reg1_data_i[1] == 1'b0) ? 30 : 
                    (reg1_data_i[0] == 1'b0) ? 31 : 32
                );
            end
            default: begin
                arithout <= `ZERO32;
            end
        endcase
    end
end

always @(*) begin
    stall_from_ex_o <= `NoStop;
    w_addr_o <= w_addr_i;
    w_reg_o <= w_reg_i;
    case (alu_type_i)
        `EXE_TYPE_LOGIC: begin
            w_data_o <= logicout;
        end
        `EXE_TYPE_SHIFT: begin
            w_data_o <= shiftout;
        end
        `EXE_TYPE_ARITH: begin
            w_data_o <= arithout;
        end
        `EXE_TYPE_MOVE: begin
            w_data_o <= moveout;
        end
        `EXE_TYPE_J_B: begin
            w_data_o <= link_addr_i;
        end
        default: begin
            w_data_o <= `ZERO32;
        end
    endcase
end

//cp0 results output
always @(*) begin
    if(rst == `RstEnable) begin
        cp0_reg_write_addr_o <= `NOPRegAddr;
        cp0_reg_we_o <= `WriteDisable;
        cp0_reg_data_o <= `ZERO32;
    end else if(alu_op_i == `EXE_MTC0_OP) begin 
        cp0_reg_write_addr_o <= inst_i[15:11];
        cp0_reg_we_o <= `WriteEnable;
        cp0_reg_data_o <= reg1_data_i;
    end else begin
        cp0_reg_write_addr_o <= 5'b00000;
        cp0_reg_we_o <= `WriteDisable;
        cp0_reg_data_o <= `ZERO32;
    end
end
endmodule