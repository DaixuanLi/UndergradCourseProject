`include "defines.vh"
`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信号
    output wire uart_rdn,         //读串口信号，低有效
    output wire uart_wrn,         //写串口信号，低有效
    input wire uart_dataready,    //串口数据准备好
    input wire uart_tbre,         //发送数据标志
    input wire uart_tsre,         //数据发送完毕标志

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //USB 控制器信号，参考 SL811 芯片手册
    output wire sl811_a0,
    //inout  wire[7:0] sl811_d,     //USB数据线与网络控制器的dm9k_sd[7:0]共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //网络控制器信号，参考 DM9000A 芯片手册
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);

/* =========== Demo code begin =========== */
// assign dpy0 = 0;
// assign dpy1 = 0;
// assign leds = 0;
// PLL分频示例
// 将50M的频率信号分成 10M的和20M的
wire locked, clk_10M, clk_20M, clk_30M, clk_40M;
pll_example clock_gen 
 (
  // Clock out ports
  .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设置
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置
  .clk_out3(clk_30M),
  .clk_out4(clk_40M),
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked), // 锁定输出，"1"表示时钟稳定，可作为后级电路复位
 // Clock in ports
  .clk_in1(clk_50M) // 外部时钟输入
 );

reg reset_of_clk10M;
// 异步复位，同步释放
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end

reg reset_of_clk20M;
// 异步复位，同步释放
always@(posedge clk_20M or negedge locked) begin
    if(~locked) reset_of_clk20M <= 1'b1;
    else        reset_of_clk20M <= 1'b0;
end

reg reset_of_clk30M;
// 异步复位，同步释放
always@(posedge clk_30M or negedge locked) begin
    if(~locked) reset_of_clk30M <= 1'b1;
    else        reset_of_clk30M <= 1'b0;
end

reg reset_of_clk40M;
// 异步复位，同步释放
always@(posedge clk_40M or negedge locked) begin
    if(~locked) reset_of_clk40M <= 1'b1;
    else        reset_of_clk40M <= 1'b0;
end

// always@(posedge clk_10M or posedge reset_of_clk10M) begin
//     if(reset_of_clk10M)begin
//         // Your Code
//     end
//     else begin
//         // Your Code
//     end
// end



// assign ext_ram_ce_n = 1'b1;
// assign ext_ram_oe_n = 1'b1;
// assign ext_ram_we_n = 1'b1;



// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7段数码管译码器演示，将number�?16进制显示在数码管上面
// reg[7:0] number;
// SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
// SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管

// reg[15:0] led_bits;
// assign leds = led_bits;

// 计数器例子
// always@(posedge clock_btn or posedge reset_btn) begin
//     if(reset_btn)begin //复位按下，设置LED和数码管为初始值
//         number<=0;
//         led_bits <= 16'h1;
//     end
//     else begin //每次按下时钟按钮，数码管显示值加1，LED循环左移
//         number <= number+1;
//         led_bits <= {led_bits[14:0],led_bits[15]};
//     end
// end

// SEG7_LUT segL(.oSEG1(dpy0), .iDIG(dip_sw[11:8])); //dpy0是低位数码管
// SEG7_LUT segH(.oSEG1(dpy1), .iDIG(dip_sw[15:12])); //dpy1是高位数码管

//直连串口接收发送演示，从直连串口收到的数据再发送出去
// wire [7:0] ext_uart_rx;
// reg  [7:0] ext_uart_buffer, ext_uart_tx;
// wire ext_uart_ready, ext_uart_busy;
// reg ext_uart_start, ext_uart_avai;

// async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
//     ext_uart_r(
//         .clk(clk_50M),                       //外部时钟信号
//         .RxD(rxd),                           //外部串行信号输入
//         .RxD_data_ready(ext_uart_ready),  //数据接收到标志
//         .RxD_clear(ext_uart_ready),       //清除接收标志
//         .RxD_data(ext_uart_rx)             //接收到的一字节数据
//     );
    
// async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
//     ext_uart_t(
//         .clk(clk_50M),                  //外部时钟信号
//         .TxD(txd),                      //串行信号输出
//         .TxD_busy(ext_uart_busy),       //发送器忙状态指示
//         .TxD_start(ext_uart_start),    //开始发送信号
//         .TxD_data(ext_uart_tx)        //待发送的数据
//     );

// always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
//     if(ext_uart_ready)begin
//         ext_uart_buffer <= ext_uart_rx;
//         ext_uart_avai <= 1;
//     end else if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_avai <= 0;
//     end
// end
// always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发送出去
//     if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_tx <= ext_uart_buffer;
//         ext_uart_start <= 1;
//     end else begin 
//         ext_uart_start <= 0;
//     end
// end



// reg state;
// always @(posedge clock_btn) begin
//     state <= 0;
// end
// always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发送出去
//     if(!ext_uart_busy) begin 
//         ext_uart_tx <= 8'h31;
//         ext_uart_start <= 1;
//     end 
//     else begin 
//         ext_uart_start <= 0;
//     end
// end

assign flash_byte_n = 0;//8 bits
assign flash_rp_n = 1;
assign flash_vpen = 0;
assign flash_ce_n = 0;
assign flash_we_n = 1;
assign flash_oe_n = 0;
wire [11:0] hdata;
wire [10:0] vdata;
wire [22:0] flash_a_vga;
// assign video_red = flash_d[2:0];
// assign video_green = flash_d[5:3];
// assign video_blue = flash_d[7:6];
assign video_red = vga_mem_out[2:0];
assign video_green = vga_mem_out[5:3];
assign video_blue = vga_mem_out[7:6];
assign video_clk = clk_50M;
vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M), 
    .hdata(hdata), //横坐标
    .vdata(),      //纵坐标
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de),
    .vga_mem_addr(vga_mem_addrb)//
);
// wire vga_mem_ena;
wire vga_mem_wea;
wire [18:0]vga_mem_addra;
wire [7:0]vga_mem_in;
// wire vga_mem_enb;
wire [18:0] vga_mem_addrb;
wire [7:0] vga_mem_out;
// assign vga_mem_ena = 0;
// assign vga_mem_enb = 0;
blk_mem_gen_0 vga_mem (
    .clka(clk_11M0592),
    // .ena(vga_mem_ena),
    .wea(vga_mem_wea),
    .addra(vga_mem_addra),
    .dina(vga_mem_in),// input wire
    .clkb(clk_50M),
    // .enb(vga_mem_enb),
    .addrb(vga_mem_addrb),
    .doutb(vga_mem_out)
);
// wire led0;
// wire led1;
vga_mem_control vga_mem_control0(
    .clk(clk_11M0592),
    .rst(reset_btn),
    .add_addr(touch_btn[0]),
    .dec_addr(touch_btn[1]),
    .hold_addr(touch_btn[2]),
    .flash_a(flash_a),
    .flash_d(flash_d[7:0]),
    // .flash_rp_n(flash_rp_n),
    // .flash_vpen(flash_vpen),
    // .flash_oe_n(flash_oe_n),
    // .flash_we_n(flash_we_n),
    .vga_mem_wea(vga_mem_wea),
    .vga_mem_addra(vga_mem_addra),
    .vga_mem_in(vga_mem_in)
    // .led(led0),
    // .led2(led1)
);

/* =========== Demo code end =========== */
//时钟
wire clk = clk_40M;
wire rst = reset_of_clk40M;

//连接IF/ID与ID
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstDataBus] id_inst_i;
wire id_in_delay_i;

wire[`InstAddrBus] ram_inst_o;

//连接ID与ID/EX
wire[`AluOpBus] id_alu_op_o;
wire[`AluTypeBus] id_alu_type_o;
wire[`RegDataBus] id_reg1_data_o;
wire[`RegDataBus] id_reg2_data_o;
wire id_w_reg_o;
wire[`RegAddrBus] id_w_addr_o;
wire[`RegDataBus] id_link_addr_o;
wire id_in_delay_o;
wire id_next_in_delay_o;
wire[`RegDataBus] id_inst_o;
wire[31:0] id_excepttype_o;
wire[`RegDataBus] id_current_inst_addr_o;

//连接ID/EX与EX
wire[`AluOpBus] ex_alu_op_i;
wire[`AluTypeBus] ex_alu_type_i;
wire[`RegDataBus] ex_reg1_data_i;
wire[`RegDataBus] ex_reg2_data_i;
wire ex_w_reg_i;
wire[`RegAddrBus] ex_w_addr_i;
wire[`RegDataBus] ex_link_addr_i;
wire ex_in_delay_i;
wire[`RegDataBus] ex_inst_i;
wire[31:0] ex_excepttype_i;
wire[`RegDataBus] ex_current_inst_address_i;

//连接EX与EX/MEM
wire[`RegAddrBus] ex_w_addr_o;
wire[`RegDataBus] ex_w_data_o;
wire ex_w_reg_o;
wire[`AluOpBus] ex_alu_op_o;
wire[`RegDataBus] ex_mem_addr_o;
wire[`RegDataBus] ex_reg2_data_o;

wire[`RegDataBus] ex_cp0_reg_data_o;
wire[`RegAddrBus] ex_cp0_reg_write_addr_o;
wire ex_cp0_reg_we_o;

wire[31:0] ex_excepttype_o;
wire ex_is_in_delayslot_o;
wire[`RegDataBus] ex_current_inst_address_o;

//连接EX/MEM与MEM
wire[`RegAddrBus] mem_w_addr_i;
wire[`RegDataBus] mem_w_data_i;
wire mem_w_reg_i;
wire[`AluOpBus] mem_alu_op_i;
wire[`RegDataBus] mem_mem_addr_i;
wire[`RegDataBus] mem_reg2_data_i;

wire mem_cp0_reg_we_i;
wire[`RegDataBus] mem_cp0_reg_data_i;
wire[`RegAddrBus] mem_cp0_reg_write_addr_i;

wire[31:0] mem_excepttype_i;
wire mem_is_in_delayslot_i;
wire[`RegDataBus] mem_current_inst_address_i;


//连接MEM与MEM/WB
wire[`RegAddrBus] mem_w_addr_o;
wire[`RegDataBus] mem_w_data_o;
wire mem_w_reg_o;
wire[`RegDataBus] mem_mem_addr_o;
wire[3:0] mem_mem_be_o;
wire mem_mem_we_o;
wire mem_mem_oe_o;
//(* DONT_TOUCH="TRUE" *) wire mem_mem_ce_o;
wire mem_mem_ce_o;
wire[`RegDataBus] mem_mem_data_o;
wire[`RegDataBus] mem_cp0_reg_data_o;
wire[`RegAddrBus] mem_cp0_reg_write_addr_o;
wire mem_cp0_reg_we_o;

//连接MEM/WB与WB
wire wb_w_reg_i;
wire[`RegAddrBus] wb_w_addr_i;
wire[`RegDataBus] wb_w_data_i;

//连接MEM/WB与CP0
wire[`RegDataBus] cp0_data_i;
wire[`RegAddrBus] cp0_waddr_i;
wire cp0_we_i;

//连接MEM与CP0和CTRL
wire[31:0] mem_excepttype_o;
wire[`RegDataBus] mem_cp0_epc_o;
wire mem_is_in_delayslot_o;
wire[`RegDataBus] mem_current_inst_address_o;


//连接ID与Reg file
wire re1;
wire re2;
wire[`RegDataBus] reg1_data;
wire[`RegDataBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;



//PC相关
wire pc_b_flag;
wire[`RegDataBus] pc_b_target_addr;

//stall 信号
wire stall_id;
wire stall_ex;
wire stall_mem;
wire stall_store;
wire[5:0] stall;

//ram 信号
wire[`RegDataBus] base_ram_w_data;
wire[`RegDataBus] base_ram_r_data;
wire[`RegDataBus] ext_ram_w_data;
wire[`RegDataBus] ext_ram_r_data;


//ram 设置
wire[`RegDataBus] ram_r_data;
assign base_ram_data = (base_ram_we_n && uart_wrn) ? 32'bz : base_ram_w_data;
assign base_ram_r_data = base_ram_data;
assign ext_ram_data = ext_ram_we_n ? 32'bz : ext_ram_w_data;
assign ext_ram_r_data = ext_ram_data;

//串口相关信号
// wire[7:0] serial_w_data;
// wire[7:0] serial_r_data;
// wire serial_we;
// wire serial_oe;
wire[1:0] serial_w_r;
wire[1:0] serial_status;

// wire [7:0] ext_uart_rx, ext_uart_tx;
// wire ext_uart_ready, ext_uart_busy;
// wire ext_uart_start, ext_uart_avai;

//uart 串口使能信号
// assign uart_rdn = 1'b1;
// assign uart_wrn = 1'b1;

// cp0 related signals
wire[`RegAddrBus] ex_cp0_reg_read_addr;
wire[`RegDataBus] ex_cp0_reg_data;
wire[`RegDataBus] cp0_status_o;
wire[`RegDataBus] cp0_ebase_o;
wire[`RegDataBus] cp0_cause_o;
wire[`RegDataBus] cp0_epc_o;

//ctrl signals
wire ctrl_flush;
wire[`RegDataBus] ctrl_new_pc;

ctrl ctrl(
    //input
    .rst(rst),
    .stall_from_id_i(stall_id),
    .stall_from_ex_i(stall_ex),
    .stall_from_mem_i(stall_mem),
    .stall_from_store_i(stall_store),
    .cp0_epc_i(mem_cp0_epc_o),
    .excepttype_i(mem_excepttype_o),
    //output
    .flush(ctrl_flush),
    .new_pc(ctrl_new_pc),
    .stall(stall)
);

//pc_reg
pc_reg pc_reg0(
    //input
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .b_target_addr_i(pc_b_target_addr),
    .b_flag_i(pc_b_flag),
    .flush(ctrl_flush),
    .new_pc(ctrl_new_pc),
    //output
    .pc(pc)
);

if_id if_id0(
    //input
    .clk(clk),
    .rst(rst),
    .if_pc(pc),
    .stall(stall),
    .flush(ctrl_flush),
    //TODO: if_inst 从内存中读数据
    .if_inst(ram_inst_o),
    //output
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

id id0(
    //input
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),

    //从reg file 中读到的数据
    .reg1_data_i(reg1_data),
    .reg2_data_i(reg2_data),
 
    //数据前推，来自exe 阶段的数据
    .ex_w_reg_i(ex_w_reg_o),
    .ex_w_addr_i(ex_w_addr_o),
    .ex_w_data_i(ex_w_data_o),

    //数据前推，来自mem 阶段的数据
    .mem_w_reg_i(mem_w_reg_o),
    .mem_w_addr_i(mem_w_addr_o),
    .mem_w_data_i(mem_w_data_o),

    .in_delay_i(id_in_delay_i),

    .ex_alu_op_i(ex_alu_op_o),

    //output
    //输出到reg file
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),

    //由指令决定是否要读reg file
    .reg1_o(re1),
    .reg2_o(re2),

    //输出到后面的id_ex
    //把从reg file中读到的数据（或从指令中获得的立即数）输出
    .reg1_data_o(id_reg1_data_o),
    .reg2_data_o(id_reg2_data_o),


    .alu_op_o(id_alu_op_o),
    .alu_type_o(id_alu_type_o),

    .inst_o(id_inst_o),

    .w_reg_o(id_w_reg_o),
    .w_addr_o(id_w_addr_o),

    .stall_from_id_o(stall_id),

    .excepttype_o(id_excepttype_o),
    .current_inst_addr_o(id_current_inst_addr_o),

    .b_target_addr_o(pc_b_target_addr),
    .b_flag_o(pc_b_flag),
    .link_addr_o(id_link_addr_o),
    .in_delay_o(id_in_delay_o),
    .next_in_delay_o(id_next_in_delay_o)
);

reg_file reg_file0(
    //input
    .clk(clk),
    .rst(rst),

    //写回
    .we(wb_w_reg_i),
    .w_addr(wb_w_addr_i),
    .w_data(wb_w_data_i),
    
    .re1(re1),
    .r_addr_1(reg1_addr),

    .re2(re2),
    .r_addr_2(reg2_addr),

    //output
    .r_data_1(reg1_data),
    .r_data_2(reg2_data)
);

id_ex id_ex0(
    //input
    .clk(clk),
    .rst(rst),

    .id_alu_op(id_alu_op_o),
    .id_alu_type(id_alu_type_o),
    
    .id_reg1_data(id_reg1_data_o),
    .id_reg2_data(id_reg2_data_o),

    .id_w_addr(id_w_addr_o),
    .id_w_reg(id_w_reg_o),

    .id_inst(id_inst_o),

    .stall(stall),

    .id_link_addr(id_link_addr_o),
    .id_in_delay(id_in_delay_o),
    .id_next_in_delay(id_next_in_delay_o),

    .id_excepttype(id_excepttype_o),
    .id_current_inst_address(id_current_inst_addr_o),

    .flush(ctrl_flush),

    //output
    .ex_inst(ex_inst_i),

    .ex_alu_op(ex_alu_op_i),
    .ex_alu_type(ex_alu_type_i),
    
    .ex_reg1_data(ex_reg1_data_i),
    .ex_reg2_data(ex_reg2_data_i),
    
    .ex_w_addr(ex_w_addr_i),
    .ex_w_reg(ex_w_reg_i),

    .ex_in_delay(ex_in_delay_i),
    .ex_link_addr(ex_link_addr_i),

    .ex_next_in_delay(id_in_delay_i),

    .ex_excepttype(ex_excepttype_i),
    .ex_current_inst_address(ex_current_inst_address_i)
);

ex ex0(
    //input
    .rst(rst),

    .inst_i(ex_inst_i),
    .alu_op_i(ex_alu_op_i),
    .alu_type_i(ex_alu_type_i),
    .reg1_data_i(ex_reg1_data_i),
    .reg2_data_i(ex_reg2_data_i),
    .w_addr_i(ex_w_addr_i),
    .w_reg_i(ex_w_reg_i),

    .mem_cp0_reg_data(mem_cp0_reg_data_o),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
    .mem_cp0_reg_we(mem_cp0_reg_we_o),

    .wb_cp0_reg_data(cp0_data_i),
    .wb_cp0_reg_write_addr(cp0_waddr_i),
    .wb_cp0_reg_we(cp0_we_i),

    .cp0_reg_data_i(ex_cp0_reg_data),

    .excepttype_i(ex_excepttype_i),
    .current_inst_address_i(ex_current_inst_address_i),

    //output
    //写回相关的数据无阻碍通过
    .w_addr_o(ex_w_addr_o),
    .w_reg_o(ex_w_reg_o),
    .w_data_o(ex_w_data_o),

    .stall_from_ex_o(stall_ex),

    .link_addr_i(ex_link_addr_i),
    .in_delay_i(ex_in_delay_i),

    .cp0_reg_read_addr_o(ex_cp0_reg_read_addr),

    .cp0_reg_data_o(ex_cp0_reg_data_o),
    .cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
    .cp0_reg_we_o(ex_cp0_reg_we_o),

    .excepttype_o(ex_excepttype_o),
    .is_in_delay_slot_o(ex_is_in_delayslot_o),
    .current_inst_address_o(ex_current_inst_address_o),

    .alu_op_o(ex_alu_op_o),
    .mem_addr_o(ex_mem_addr_o),
    .reg2_data_o(ex_reg2_data_o)
);

ex_mem ex_mem0(
    //input
    .clk(clk),
    .rst(rst),

    .ex_w_addr(ex_w_addr_o),
    .ex_w_reg(ex_w_reg_o),
    .ex_w_data(ex_w_data_o),

    .stall(stall),

    .ex_alu_op(ex_alu_op_o),
    .ex_mem_addr(ex_mem_addr_o),
    .ex_reg2_data(ex_reg2_data_o),

    .ex_cp0_reg_data(ex_cp0_reg_data_o),
    .ex_cp0_reg_write_addr(ex_cp0_reg_write_addr_o),
    .ex_cp0_reg_we(ex_cp0_reg_we_o),

    .ex_excepttype(ex_excepttype_o),
    .ex_is_in_delayslot(ex_is_in_delayslot_o),
    .ex_current_inst_address(ex_current_inst_address_o),

    .flush(ctrl_flush),

    //output
    .mem_w_addr(mem_w_addr_i),
    .mem_w_reg(mem_w_reg_i),
    .mem_w_data(mem_w_data_i),
    
    .mem_alu_op(mem_alu_op_i),
    .mem_mem_addr(mem_mem_addr_i),
    .mem_reg2_data(mem_reg2_data_i),

    .mem_excepttype(mem_excepttype_i),
    .mem_is_in_delayslot(mem_is_in_delayslot_i),
    .mem_current_inst_address(mem_current_inst_address_i),

    .mem_cp0_reg_data(mem_cp0_reg_data_i),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
    .mem_cp0_reg_we(mem_cp0_reg_we_i)
);

mem mem0(
    //input
    .rst(rst),
    .clk(clk),

    .alu_op_i(mem_alu_op_i),
    .mem_addr_i(mem_mem_addr_i),
    .reg2_data_i(mem_reg2_data_i),
    
    .mem_data_i(ram_r_data), // 也许要换成base ram

    .w_addr_i(mem_w_addr_i),
    .w_data_i(mem_w_data_i),
    .w_reg_i(mem_w_reg_i),

    .cp0_reg_data_i(mem_cp0_reg_data_i),
    .cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
    .cp0_reg_we_i(mem_cp0_reg_we_i),

    .excepttype_i(mem_excepttype_i),
    .is_in_delayslot_i(mem_is_in_delayslot_i),
    .current_inst_address_i(mem_current_inst_address_i),

    .wb_cp0_reg_we(cp0_we_i),
    .wb_cp0_reg_write_addr(cp0_waddr_i),
    .wb_cp0_reg_data(cp0_data_i),

    .cp0_status_i(cp0_status_o),
    .cp0_cause_i(cp0_cause_o),
    .cp0_epc_i(cp0_epc_o),

    //output
    .w_addr_o(mem_w_addr_o),
    .w_data_o(mem_w_data_o),
    .w_reg_o(mem_w_reg_o),

    .mem_addr_o(mem_mem_addr_o),
    .mem_be_o_n(mem_mem_be_o),
    .mem_we_o_n(mem_mem_we_o),
    .mem_oe_o_n(mem_mem_oe_o),
    .mem_ce_o_n(mem_mem_ce_o),

    .cp0_reg_data_o(mem_cp0_reg_data_o),
    .cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
    .cp0_reg_we_o(mem_cp0_reg_we_o),

    .excepttype_o(mem_excepttype_o),
    .cp0_epc_o(mem_cp0_epc_o),
    .is_in_delayslot_o(mem_is_in_delayslot_o),
    .current_inst_address_o(mem_current_inst_address_o),

    .mem_data_o(mem_mem_data_o)


);

mem_ctrl mem_ctrl0(
    // input 
    .clk(clk),
    .rst(rst),

    .pc_i(pc),
    .v_addr_i(mem_mem_addr_o),
    .data_i(mem_mem_data_o),
    .code_data_i(base_ram_r_data),
    .data_data_i(ext_ram_r_data),

    .serial_data_ready_i(uart_dataready),
    .serial_tbre(uart_tbre),
    .serial_tsre(uart_tsre),

    .be_i_n(mem_mem_be_o),
    .we_i_n(mem_mem_we_o),
    .oe_i_n(mem_mem_oe_o),
    .ce_i_n(mem_mem_ce_o),
    
    //output
    .code_be_o_n(base_ram_be_n),
    .code_we_o_n(base_ram_we_n),
    .code_oe_o_n(base_ram_oe_n),
    .code_ce_o_n(base_ram_ce_n),
    .code_r_addr_o(base_ram_addr),
    .code_data_o(base_ram_w_data),

    .data_be_o_n(ext_ram_be_n),
    .data_we_o_n(ext_ram_we_n),
    .data_oe_o_n(ext_ram_oe_n),
    .data_ce_o_n(ext_ram_ce_n),
    .data_r_addr_o(ext_ram_addr),
    .data_data_o(ext_ram_w_data),

    .inst_o(ram_inst_o),
    .data_o(ram_r_data),

    .serial_rdn(uart_rdn),
    .serial_wrn(uart_wrn),

    .stall_from_mem_o(stall_mem),
    .stall_from_store_o(stall_store)
);

mem_wb mem_wb0(
    //input
    .clk(clk),
    .rst(rst),

    .mem_w_addr(mem_w_addr_o),
    .mem_w_reg(mem_w_reg_o),
    .mem_w_data(mem_w_data_o),

    .mem_cp0_reg_data(mem_cp0_reg_data_o),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
    .mem_cp0_reg_we(mem_cp0_reg_we_o),

    .stall(stall),

    .flush(ctrl_flush),

    //output
    .wb_cp0_reg_data(cp0_data_i),
    .wb_cp0_reg_write_addr(cp0_waddr_i),
    .wb_cp0_reg_we(cp0_we_i),

    .wb_w_addr(wb_w_addr_i),
    .wb_w_reg(wb_w_reg_i),
    .wb_w_data(wb_w_data_i)
);

// temporary set instruction to zero
wire[5:0] intr_zero = {3'b000,uart_dataready,2'b00}; 

cp0_reg cp0_reg0(
    .clk(clk),
    .rst(rst),
    //input wire
    .raddr_i(ex_cp0_reg_read_addr),
    .data_i(cp0_data_i),
    .waddr_i(cp0_waddr_i),
    .we_i(cp0_we_i),
    .interr_i(intr_zero),

    .excepttype_i(mem_excepttype_o),
    .current_inst_addr_i(mem_current_inst_address_o),
    .is_in_delay_slot_i(mem_is_in_delayslot_o),

    //output wire
    .data_o(ex_cp0_reg_data),

    .status_o(cp0_status_o),
    .ebase_o(cp0_ebase_o),
    .cause_o(cp0_cause_o),
    .epc_o(cp0_epc_o)


);




// //接收模块，9600无检验位
// async_receiver #(.ClkFrequency(11059200),.Baud(9600)) 
//     ext_uart_r(
//         .clk(clk),                       //外部时钟信号
//         .RxD(rxd),                           //外部串行信号输入
//         .RxD_data_ready(ext_uart_ready),  //数据接收到标志
//         .RxD_clear(ext_uart_ready),       //清除接收标志
//         .RxD_data(ext_uart_rx)             //接收到的一字节数据
//     );

// //发送模块，9600无检验位
// async_transmitter #(.ClkFrequency(11059200),.Baud(9600)) 
//     ext_uart_t(
//         .clk(clk),                  //外部时钟信号
//         .TxD(txd),                      //串行信号输出
//         .TxD_busy(ext_uart_busy),       //发送器忙状态指示
//         .TxD_start(ext_uart_start),    //开始发送信号
//         .TxD_data(ext_uart_tx)        //待发送的数据
//     );

// serial_cpld serial_cpld0(
//     // input
//     .clk(clk),
//     .rst(rst),

//     .w_r_i(serial_w_r),
//     .data_ready(uart_dataready),
//     .tbre(uart_tbre),
//     .tsre(uart_tsre),

//     //output
//     .rdn(uart_rdn),
//     .wrn(uart_wrn),

//     .status_o(serial_status)
// );

// serial serial0(
//     // input
//     .clk(clk),
//     .rst(rst),
    
//     .mem_data_i(serial_w_data),
//     .serial_data_i(ext_uart_rx),
//     .we_i(serial_we),
//     .oe_i(serial_oe),

//     .busy(ext_uart_busy),
//     .ready(ext_uart_ready),

//     //output
//     .w_data_o(ext_uart_tx),
//     .r_data_o(serial_r_data),
//     .status_o(serial_status),
//     .start_o(ext_uart_start)
// );

endmodule
