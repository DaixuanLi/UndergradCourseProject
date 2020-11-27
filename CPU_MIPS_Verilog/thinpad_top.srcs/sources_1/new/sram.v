module sram(
    input wire[31:0] dip_sw,

    //BaseRam
    inout wire[31:0] base_ram_data,
    output wire[19:0] base_ram_addr,
    output wire base_ram_ce_n,
    output wire base_ram_oe_n,
    output wire base_ram_we_n,

    //Uart
    output wire uart_rdn,
    output wire uart_wrn,
    input wire uart_dataready,
    input wire uart_tbre,
    input wire uart_tsre,

    //led
    output wire[15:0] leds,

    //clk
    input wire clk,

    //reset
    input wire reset
);

// 不使用内存、串口时，禁用其使能信号
// assign base_ram_ce_n = 1'b0;
// assign base_ram_oe_n = 1'b1;
// assign base_ram_we_n = 1'b1;

// assign uart_rdn = 1'b1;
// assign uart_wrn = 1'b1;

//UART
integer state, all_state; //state控制串口读写的状态，all_state控制总状态
reg reg_r; //实现两个周期读数据的变量
reg[31:0] input_addr; //存放初始地址的寄存器
wire [7:0] uart_data; //从串口输出连出的线
wire [7:0] ram_data; //从内存总线连出的线
reg[7:0] reg_data; // 保存base_ram_data读出或写入的数据，包括从串口读出的数据，从内存读出的数据
reg reg_uart_rdn; //以下每个控制信号都用一个寄存器存
reg reg_uart_wdn;
reg reg_ram_oe_n;
reg reg_ram_we_n;
reg reg_ram_ce_n;

assign uart_data = base_ram_data;
assign leds[7:0] = reg_data; //led 低8位显示reg_data
assign leds[15:8] = input_addr[7:0];
assign ram_data = base_ram_data;  //总线的输出
assign base_ram_data = (reg_ram_we_n && reg_uart_wdn) ? 32'bz : reg_data; //总线的输入，需要读串口或读内存的时候设为高阻，否则与接入需要写的数据
assign base_ram_addr = input_addr;
assign uart_rdn = reg_uart_rdn; //以下将控制信号与对应的串口绑定
assign uart_wrn = reg_uart_wdn; 
assign base_ram_oe_n = reg_ram_oe_n;
assign base_ram_we_n = reg_ram_we_n;
assign base_ram_ce_n = reg_ram_ce_n;

//base_ram_data总线由内存、串口共用，又同时支持读和写，因此有四个使能信号控制（外加一个内存的使能信号base_ram_ce_n），实现过程中需小心地控制这五个信号
always @(posedge clk or posedge reset) begin
    if (reset) begin
        //把初始地址存进寄存器
        input_addr <= dip_sw;
        //各种初始化
        state <= 0;
        all_state <= 0;
        reg_data <= 0;
        reg_uart_rdn <= 1;
        reg_uart_wdn <= 1;
        reg_ram_ce_n <= 1;
        reg_ram_oe_n <= 1;
        reg_ram_we_n <= 1;
        reg_r <= 0;
    end
    else if (clk) begin
        if (all_state <= 9) begin
            //all_state 小于等于9时，从串口中读数据并存入内存
            if (state == 0) begin
                //等待串口数据接收完毕
                reg_uart_rdn <= 1;
                state <= 1;
            end
            else if (state == 1) begin
                if (uart_dataready) begin
                    //串口数据接收完毕，将读串口的信号拉低，内存使能打开
                    reg_uart_rdn <= 0;
                    reg_ram_ce_n <= 0;
                    state <= 2;
                end
                else begin
                    state <= 0;
                end 
            end
            else if (state == 2) begin
                //将串口中读出的数据放到reg_data中，串口读使能信号拉高（关掉），内存写使能信号拉低（打开），reg_data数据进入内存
                reg_uart_rdn <= 1;
                reg_ram_we_n <= 0;
                reg_data <= uart_data;
                state <= 3;
            end
            else if (state == 3) begin
                //内存地址加一，等待从串口输入下一个数据，内存使能信号和内存写使能信号关闭
                input_addr <= input_addr + 1;
                reg_ram_we_n <= 1;
                reg_ram_ce_n <= 1;
                state <= 0;
                all_state <= all_state + 1;
            end
        end
        else if (all_state == 10) begin
            //all_state = 10时，初始化一些变量，准备读内存，写串口
            reg_ram_ce_n <= 0;
            reg_ram_oe_n <= 0;
            input_addr <= dip_sw;
            all_state <= 11;
        end
        else if (all_state <= 20) begin
            //11 <= all_state <= 20时，读内存，写串口
            if (state == 0) begin
                //用两个周期读内存，第一个周期（reg_r为0）使数据出现在总线上，第二个周期（reg_r为1）将总线上的数据存入reg_data
                if (all_state <= 19) begin
                    //把内存使能，读使能打开
                    reg_ram_oe_n <= 0;
                    reg_ram_ce_n <= 0;
                    if (reg_r) begin
                        //到第二个周期的时候地址再加一
                        input_addr <= input_addr + 1;
                    end
                end
                else if (all_state == 20) begin
                    //all_state = 20的时候比较特殊，读完第十个数据之后地址不用加一
                    reg_ram_oe_n <= 0;
                    reg_ram_ce_n <= 0;
                end
                if (reg_r) begin
                    //第二个周期，将总线上的内存数据存到reg_data中，并且跳转到写串口的状态
                    reg_data <= ram_data;
                    state <= 1;
                    reg_r <= 0;
                end
                else begin
                    //第一个周期，等数据从内存中读到总线上
                    reg_r <= 1;
                end
            end
            else if (state == 1) begin
                //准备写串口，将内存读使能，内存使能关掉，串口写使能打开
                reg_ram_ce_n <= 1;
                reg_ram_oe_n <= 1;
                reg_uart_wdn <= 0;
                state <= 2;
            end
            else if (state == 2) begin
                //写串口关调，数据开始从串口的缓冲寄存器写进移位寄存器中
                reg_uart_wdn <= 1;
                state <= 3;
            end
            else if (state == 3) begin
                //等待移位寄存器写完，写完后串口发送数据
                if (uart_tbre) begin
                    state <= 4;
                end
            end
            else if (state == 4) begin
                //等待串口发送完数据，发送完数据后，all_state += 1，从内存中读下一个数，再发送
                if (uart_tsre) begin
                    state <= 0;
                    all_state <= all_state + 1;
                end
            end
        end

    end
end

//SRAM
/*
integer state;
reg[31:0] input_data;
wire[31:0] output_data;
reg[31:0] input_addr;
reg[31:0] results_data;
reg oe;
reg we;

assign base_ram_data = we ? 32'bz : input_data;
assign output_data = base_ram_data;
assign base_ram_addr = input_addr;
assign leds[7:0] = results_data[7:0];
assign leds[15:8] = input_addr[7:0];
assign base_ram_we_n = we;
assign base_ram_oe_n = oe;

always @(posedge clock_btn or posedge reset) begin
    if (reset) begin
        state <= 0;
        we <= 1;
        oe <= 1;
        results_data <= 0;
    end
    else if (clock_btn) begin
        if (state == 0) begin
            input_addr <= dip_sw;
        end
        else if (state == 1) begin
            input_data <= dip_sw;
            // results_data <= dip_sw;
            we <= 0;
        end
        else if (state <= 10) begin
            // results_data <= input_data + 1;
            input_addr <= input_addr + 1;
            input_data <= input_data + 1;
        end
        else if (state == 11) begin
            we <= 1;
        end
        else if (state == 12) begin
            oe <= 0;
            input_addr <= input_addr - 9;
            // results_data <= output_data;
        end
        else if (state <= 21) begin
            input_addr <= input_addr + 1;
            // results_data <= output_data;
        end
        state <= state + 1;
    end
end

always @(state or output_data) begin
    if (state == 0) begin
        results_data <= 0;
    end
    else if (state == 1) begin
        results_data <= dip_sw;
    end
    else if (state <= 10) begin
        results_data <= input_data;
    end
    else if (state <= 21) begin
        results_data <= output_data;
    end
end
*/

endmodule