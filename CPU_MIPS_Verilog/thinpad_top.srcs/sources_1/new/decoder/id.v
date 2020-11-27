`include "defines.vh"

module id(
    input wire rst,

    input wire[`InstAddrBus] pc_i, //跳转指令的时候用
    input wire[`InstDataBus] inst_i,

    input wire[`RegDataBus] reg1_data_i,
    input wire[`RegDataBus] reg2_data_i,

    input wire ex_w_reg_i,
    input wire[`RegDataBus] ex_w_data_i,
    input wire[`RegAddrBus] ex_w_addr_i,

    input wire mem_w_reg_i,
    input wire[`RegDataBus] mem_w_data_i,
    input wire[`RegAddrBus] mem_w_addr_i,

    input wire in_delay_i, //异常处理的时候用�??

    input wire[`AluOpBus] ex_alu_op_i,

    output wire[31:0] excepttype_o,
    output wire[`RegDataBus] current_inst_addr_o,

    output reg reg1_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg reg2_o,
    output reg[`RegAddrBus] reg2_addr_o,

    //这里的Type 对应书上的sel，sel不知道什么意思，�??以写成Type. Upd:sel means selection.
    output reg[`AluTypeBus] alu_type_o,

    output wire[`RegDataBus] inst_o,
    
    output reg[`AluOpBus] alu_op_o,
    output reg[`RegDataBus] reg1_data_o,
    output reg[`RegDataBus] reg2_data_o,

    output reg w_reg_o,
    output reg[`RegAddrBus] w_addr_o,

    output wire stall_from_id_o,

    output reg next_in_delay_o,
    output reg b_flag_o,
    output reg[`RegDataBus] b_target_addr_o,
    output reg[`RegDataBus] link_addr_o,
    output reg in_delay_o

);

assign inst_o = inst_i;

reg reg1_load_relate;
reg reg2_load_relate;
wire pre_is_load;

assign pre_is_load = ((ex_alu_op_i == `EXE_LB_OP) || 
                      (ex_alu_op_i == `EXE_LW_OP)) ? 1'b1 : 1'b0;

assign stall_from_id_o = reg1_load_relate | reg2_load_relate;

wire[5:0] op = inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];
wire[10:0] op_shift = inst_i[31:21];

wire[`RegDataBus] next_1_pc = pc_i + `PcStep;
wire[`RegDataBus] next_2_pc = pc_i + `PcStep + `PcStep;

wire[`RegDataBus] offset = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};

reg[`RegDataBus] imm;

reg inst_valid;

reg excepttype_is_syscall;
reg excepttype_is_eret;

assign excepttype_o = {19'b0,excepttype_is_eret,2'b0,`InstValid,excepttype_is_syscall,8'b0};
assign current_inst_addr_o = pc_i;

always @(*) begin
    //解码指令，从指令中解码出指令类型，指令所�??寄存器的编号，立即数
    if (rst == `RstEnable) begin
        //默认情况是NOP语句
        alu_op_o <= `EXE_NOP_OP;
        alu_type_o <= `EXE_TYPE_NOP;
        w_addr_o <= `NOPRegAddr;
        w_reg_o <= `WriteDisable;
        inst_valid <= `InstValid;
        reg1_o <= `NoReadReg;
        reg2_o <= `NoReadReg;

        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= `ZERO32;

        link_addr_o <= `ZERO32;
        b_target_addr_o <= `ZERO32;
        b_flag_o <= `NoBranch;
        next_in_delay_o <= `NotInDelay;
    end
    else begin
        //默认情况是NOP语句
        alu_op_o <= `EXE_NOP_OP;
        alu_type_o <= `EXE_TYPE_NOP;
        w_addr_o <= inst_i[15:11];
        w_reg_o <= `WriteDisable;
        inst_valid <= `InstInvalid;
        reg1_o <= `NoReadReg;
        reg2_o <= `NoReadReg;
        reg1_addr_o <= inst_i[25:21]; //先把要用的寄存器编号都读进来，不管是不是�??要两个寄存器的指令，到后面再判断�??
        reg2_addr_o <= inst_i[20:16];
        imm <= `ZERO32;
        
        link_addr_o <= `ZERO32;
        b_target_addr_o <= `ZERO32;
        b_flag_o <= `NoBranch;
        next_in_delay_o <= `NotInDelay;

        excepttype_is_eret <= `False_v;
        excepttype_is_syscall <= `False_v;

        if(inst_i[31:21] == 11'b01000000000 &&
            inst_i[10:0] == 11'b00000000000) 
        begin
            alu_op_o <= `EXE_MFC0_OP;
            alu_type_o <= `EXE_TYPE_MOVE;
            w_addr_o <= inst_i[20:16];
            w_reg_o <= `WriteEnable;
            inst_valid <= `InstValid;
            reg1_o <= `NoReadReg;
            reg2_o <= `NoReadReg;
        end else if(inst_i[31:21] == 11'b01000000100 &&
                    inst_i[10:0] == 11'b00000000000)
        begin
            alu_op_o <= `EXE_MTC0_OP;
            alu_type_o <= `EXE_TYPE_NOP;
            w_reg_o <= `WriteDisable;
            inst_valid <= `InstValid;
            reg1_o <= `HasReadReg;
            reg1_addr_o <= inst_i[20:16];
            reg2_o <= `NoReadReg;
        end
        else if (op == `EXE_SPECIAL) begin
            if (op3 == `EXE_SYSCALL) begin
                w_reg_o <= `WriteDisable;
                alu_op_o <= `EXE_SYSCALL_OP;
                alu_type_o <= `EXE_TYPE_NOP;
                reg1_o <= `NoReadReg;
                reg2_o <= `NoReadReg;
                inst_valid <= `InstValid;
                excepttype_is_syscall <= `True_v;
            end else begin
                case (op2) 
                    `LOGIC_OP2: begin
                        if ((op3 == `EXE_OR) ||
                            (op3 == `EXE_AND) ||
                            (op3 == `EXE_XOR) ||
                            (op3 == `EXE_ADDU)) 
                        begin
                            w_reg_o <= `WriteEnable;
                            reg1_o <= `HasReadReg;
                            reg2_o <= `HasReadReg;
                            inst_valid <= `InstValid;
                            case (op3)
                                `EXE_OR: begin 
                                    alu_op_o <= `EXE_OR_OP;
                                    alu_type_o <= `EXE_TYPE_LOGIC;
                                end
                                `EXE_AND: begin 
                                    alu_op_o <= `EXE_AND_OP;
                                    alu_type_o <= `EXE_TYPE_LOGIC;                            
                                end
                                `EXE_XOR: begin
                                    alu_op_o <= `EXE_XOR_OP;
                                    alu_type_o <= `EXE_TYPE_LOGIC;                            
                                end
                                `EXE_ADDU: begin
                                    alu_op_o <= `EXE_ADD_OP;
                                    alu_type_o <= `EXE_TYPE_ARITH;
                                end
                                default: begin
                                end
                            endcase
                        end
                        else if (op3 == `EXE_MOVN) begin
                            alu_op_o <= `EXE_MOVN_OP;
                            alu_type_o <= `EXE_TYPE_MOVE;
                            reg1_o <= `HasReadReg;
                            reg2_o <= `HasReadReg;
                            inst_valid <= `InstValid;
                            if (reg2_data_o != `ZERO32) begin
                                w_reg_o <= `WriteEnable;
                            end
                            else begin
                                w_reg_o <= `WriteDisable;
                            end
                        end
                        else if (op3 == `EXE_JR) begin
                            w_reg_o <= `WriteDisable;
                            alu_op_o <= `EXE_JR_OP;
                            alu_type_o <= `EXE_TYPE_J_B;
                            reg1_o <= `HasReadReg;
                            reg2_o <= `NoReadReg;
                            link_addr_o <= `ZERO32;
                            b_target_addr_o <= reg1_data_o;
                            b_flag_o <= `Branch;
                            next_in_delay_o <= `InDelay;
                            inst_valid <= `InstValid;
                        end
                    end
                    default: begin
                    end
                endcase
            end
        end
        else if (op == `EXE_SPECIAL2) begin
            if (op3 == `EXE_CLO) begin
                w_reg_o <= `WriteEnable;
                alu_op_o <= `EXE_CLO_OP;
                alu_type_o <= `EXE_TYPE_ARITH;
                reg1_o <= `HasReadReg;
                reg2_o <= `NoReadReg;
                inst_valid <= `InstValid;
            end
        end
        else if ((op == `EXE_ORI) ||
                 (op == `EXE_ANDI) ||
                 (op == `EXE_XORI) ||
                 (op == `EXE_LUI) ||
                 (op == `EXE_ADDIU))
        begin
            w_reg_o <= `WriteEnable;
            reg1_o <= `HasReadReg;
            reg2_o <= `NoReadReg; //ORI指令只需要读�??个寄存器
            w_addr_o <= inst_i[20:16];
            inst_valid <= `InstValid;
            case (op)
                `EXE_ORI: begin
                    alu_op_o <= `EXE_OR_OP;
                    alu_type_o <= `EXE_TYPE_LOGIC;
                    imm <= {`ZERO16, inst_i[15:0]};
                end
                `EXE_ANDI: begin
                    alu_op_o <= `EXE_AND_OP;
                    alu_type_o <= `EXE_TYPE_LOGIC;                    
                    imm <= {`ZERO16, inst_i[15:0]};
                end
                `EXE_XORI: begin
                    alu_op_o <= `EXE_XOR_OP;
                    alu_type_o <= `EXE_TYPE_LOGIC;
                    imm <= {`ZERO16, inst_i[15:0]};
                end
                `EXE_LUI: begin
                    alu_op_o <= `EXE_OR_OP;
                    alu_type_o <= `EXE_TYPE_LOGIC;
                    imm <= {inst_i[15:0], `ZERO16};
                end
                `EXE_ADDIU: begin
                    alu_op_o <= `EXE_ADD_OP;
                    alu_type_o <= `EXE_TYPE_ARITH;
                    imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                end
                default: begin
                end
            endcase
        end
        else if (op == `EXE_J) begin
            w_reg_o <= `WriteDisable;
            alu_op_o <= `EXE_J_OP;
            alu_type_o <= `EXE_TYPE_J_B;
            reg1_o <= `NoReadReg;
            reg2_o <= `NoReadReg;
            link_addr_o <= `ZERO32;
            b_flag_o <= `Branch;
            next_in_delay_o <= `InDelay;
            inst_valid <= `InstValid;
            b_target_addr_o <= {next_1_pc[31:28], inst_i[25:0], 2'b00};
        end
        else if (op == `EXE_JAL) begin
            w_reg_o <= `WriteEnable;
            alu_op_o <= `EXE_JAL_OP;
            alu_type_o <= `EXE_TYPE_J_B;
            reg1_o <= `NoReadReg;
            reg2_o <= `NoReadReg;
            w_addr_o <= 5'b11111; //31号寄存器
            link_addr_o <= next_2_pc;
            b_flag_o <= `Branch;
            next_in_delay_o <= `InDelay;
            inst_valid <= `InstValid;
            b_target_addr_o <= {next_1_pc[31:28], inst_i[25:0], 2'b00};
        end
        else if (op == `EXE_BEQ) begin
            w_reg_o <= `WriteDisable;
            alu_op_o <= `EXE_BEQ_OP;
            alu_type_o <= `EXE_TYPE_J_B;
            reg1_o <= `HasReadReg;
            reg2_o <= `HasReadReg;
            inst_valid <= `InstValid;
            if (reg1_data_o == reg2_data_o) begin
                b_target_addr_o <= next_1_pc + offset;
                b_flag_o <= `Branch;
                next_in_delay_o <= `InDelay;
            end
        end
        else if (op == `EXE_BGTZ) begin
            w_reg_o <= `WriteDisable;
            alu_op_o <= `EXE_BGTZ_OP;
            alu_type_o <= `EXE_TYPE_J_B;
            reg1_o <= `HasReadReg;
            reg2_o <= `NoReadReg;
            inst_valid <= `InstValid;
            if ((reg1_data_o[31] == 1'b0) && (reg1_data_o != `ZERO32)) begin
                b_target_addr_o <= next_1_pc + offset;
                b_flag_o <= `Branch;
                next_in_delay_o <= `InDelay;
            end
        end
        else if (op == `EXE_BNE) begin
            w_reg_o <= `WriteDisable;
            alu_op_o <= `EXE_BNE_OP;
            alu_type_o <= `EXE_TYPE_J_B;
            reg1_o <= `HasReadReg;
            reg2_o <= `HasReadReg;
            inst_valid <= `InstValid;
            if (reg1_data_o != reg2_data_o) begin
                b_target_addr_o <= next_1_pc + offset;
                b_flag_o <= `Branch;
                next_in_delay_o <= `InDelay;
            end
        end
        else if ((op == `EXE_LB) || 
                 (op == `EXE_LW)) 
        begin
            w_reg_o <= `WriteEnable;
            alu_type_o <= `EXE_TYPE_L_S;
            w_addr_o <= inst_i[20:16];
            reg1_o <= `HasReadReg;
            reg2_o <= `NoReadReg;
            inst_valid <= `InstValid;
            case (op)
                `EXE_LB: begin
                    alu_op_o <= `EXE_LB_OP;
                end
                `EXE_LW: begin
                    alu_op_o <= `EXE_LW_OP;
                end
            endcase
        end
        else if ((op == `EXE_SB) || 
                 (op == `EXE_SW))
        begin
            w_reg_o <= `WriteDisable;
            alu_type_o <= `EXE_TYPE_L_S;
            reg1_o <= `HasReadReg;
            reg2_o <= `HasReadReg;
            inst_valid <= `InstValid;
            case (op)
                `EXE_SB: begin
                    alu_op_o <= `EXE_SB_OP;
                end
                `EXE_SW: begin
                    alu_op_o <= `EXE_SW_OP;
                end
            endcase
        end
        else if (inst_i == `EXE_ERET) begin
            w_reg_o <= `WriteEnable;
            alu_op_o <= `EXE_ERET_OP;
            alu_type_o <= `EXE_TYPE_NOP;
            reg1_o <= `NoReadReg;
            reg2_o <= `NoReadReg;
            inst_valid <= `InstValid;
            excepttype_is_eret <= `True_v;
        end
        else begin
            //invalid instructions
        end

        if (op_shift == `SHIFT_OP) begin
            if ((op3 == `EXE_SLL) ||
                (op3 == `EXE_SRL) ||
                (op3 == `EXE_SRA)) 
            begin
                w_reg_o <= `WriteEnable;
                alu_type_o <= `EXE_TYPE_SHIFT;
                reg1_o <= `NoReadReg;
                reg2_o <= `HasReadReg;
                imm[4:0] <= inst_i[10:6];
                w_addr_o <= inst_i[15:11];
                inst_valid <= `InstValid;
                case (op3)
                    `EXE_SLL: alu_op_o <= `EXE_SLL_OP;
                    `EXE_SRL: alu_op_o <= `EXE_SRL_OP;
                    `EXE_SRA: alu_op_o <= `EXE_SRA_OP;
                    default: begin
                    end
                endcase
            end
        end
    end
end

always @(*) begin
    //从寄存器端口1中读出�??
    reg1_load_relate <= `NoStop;
    if (rst == `RstEnable) begin
        reg1_data_o <= `ZERO32;
    end
    else if (reg1_o == `HasReadReg) begin
        //数据前推，如果要读的位置是写的位置，那就直接把数据拿过来
        if ((pre_is_load == 1'b1) && (ex_w_addr_i == reg1_addr_o)) begin
            reg1_load_relate <= `Stop;
        end
        else if ((ex_w_reg_i == `WriteEnable) && (ex_w_addr_i == reg1_addr_o)) begin
            reg1_data_o <= ex_w_data_i;
        end
        else if ((mem_w_reg_i == `WriteEnable) && (mem_w_addr_i == reg1_addr_o)) begin
            reg1_data_o <= mem_w_data_i;
        end
        else begin
            reg1_data_o <= reg1_data_i;
        end
    end
    else if (reg1_o == `NoReadReg) begin
        reg1_data_o <= imm;
    end
    else begin
        reg1_data_o <= `ZERO32;
    end
end

always @(*) begin
    //从寄存器端口2中读出�??
    reg2_load_relate <= `NoStop;
    if (rst == `RstEnable) begin
        reg2_data_o <= `ZERO32;
    end
    else if (reg2_o == `HasReadReg) begin
        if ((pre_is_load == 1'b1) && (ex_w_addr_i == reg2_addr_o)) begin
            reg2_load_relate <= `Stop;
        end
        else if ((ex_w_reg_i == `WriteEnable) && (ex_w_addr_i == reg2_addr_o)) begin
            reg2_data_o <= ex_w_data_i;
        end
        else if ((mem_w_reg_i == `WriteEnable) && (mem_w_addr_i == reg2_addr_o)) begin
            reg2_data_o <= mem_w_data_i;
        end
        else begin
            reg2_data_o <= reg2_data_i;
        end
    end
    else if (reg2_o == `NoReadReg) begin
        reg2_data_o <= imm;
    end
    else begin
        reg2_data_o <= `ZERO32;
    end
end

always @(*) begin
    if (rst == `RstEnable) begin
        in_delay_o <= `NotInDelay;
    end
    else begin
        in_delay_o <= in_delay_i;
    end
end

endmodule