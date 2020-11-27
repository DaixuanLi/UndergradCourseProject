`include "defines.vh"

module reg_file(
    //2 read and 1 write
    input wire clk,
    input wire rst,

    //write 
    input wire we,
    input wire[`RegAddrBus] w_addr,
    input wire[`RegDataBus] w_data,

    //read1
    input wire re1,
    input wire[`RegAddrBus] r_addr_1,
    output reg[`RegDataBus] r_data_1,

    //read2
    input wire re2,
    input wire[`RegAddrBus] r_addr_2,
    output reg[`RegDataBus] r_data_2
);

reg[`RegDataBus] regs[0:`RegNum - 1];

always@(posedge clk) begin
    if (rst == `RstDisable) begin
        if (we == `WriteEnable) begin
            if (w_addr != `ZeroRegAddr) begin
                // No.0 Reg cannot be written
                regs[w_addr] <= w_data;
            end
        end
    end
    else begin
        regs[0] = `ZERO32; regs[1] = `ZERO32; regs[2] = `ZERO32; regs[3] = `ZERO32;
        regs[4] = `ZERO32; regs[5] = `ZERO32; regs[6] = `ZERO32; regs[7] = `ZERO32;
        regs[8] = `ZERO32; regs[9] = `ZERO32; regs[10] = `ZERO32; regs[11] = `ZERO32;
        regs[12] = `ZERO32; regs[13] = `ZERO32; regs[14] = `ZERO32; regs[15] = `ZERO32;
        regs[16] = `ZERO32; regs[17] = `ZERO32; regs[18] = `ZERO32; regs[19] = `ZERO32;
        regs[20] = `ZERO32; regs[21] = `ZERO32; regs[22] = `ZERO32; regs[23] = `ZERO32;
        regs[24] = `ZERO32; regs[25] = `ZERO32; regs[26] = `ZERO32; regs[27] = `ZERO32;
        regs[28] = `ZERO32; regs[29] = `ZERO32; regs[30] = `ZERO32; regs[31] = `ZERO32;
    end
end

always @(*) begin
    if (rst == `RstEnable) begin
        r_data_1 <= `ZERO32;
    end
    else if (r_addr_1 == `ZeroRegAddr) begin
        r_data_1 <= `ZERO32;
    end
    else if (re1 == `ReadEnable) begin 
        if ((r_addr_1 == w_addr) && (we == `WriteEnable) ) begin
            //如果写操作和读操作的地址一样，则直接把要写的数据拿出来
            //解决相邻两条指令数据相关的问题（因为写过程是在要写的数据ready之后的下一个周期才真正写进reg file）
            r_data_1 <= w_data;
        end
        else begin
            r_data_1 <= regs[r_addr_1];
        end
    end
    else begin
        //写使能关闭
        r_data_1 <= `ZERO32;
    end
end

always @(*) begin
    if (rst == `RstEnable) begin
        r_data_2 <= `ZERO32;
    end
    else if (r_addr_2 == `ZeroRegAddr) begin
        r_data_2 <= `ZERO32;
    end
    else if (re2 == `ReadEnable) begin 
        if ((r_addr_2 == w_addr) && (we == `WriteEnable) ) begin
            r_data_2 <= w_data;
        end
        else begin
            r_data_2 <= regs[r_addr_2];
        end
    end
    else begin
        r_data_2 <= `ZERO32;
    end
end

endmodule