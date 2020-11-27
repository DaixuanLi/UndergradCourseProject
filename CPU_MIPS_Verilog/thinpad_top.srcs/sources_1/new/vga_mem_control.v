module vga_mem_control(
    input wire clk,
    input wire rst,
    input wire add_addr,
    input wire dec_addr,
    input wire hold_addr,

    //flash
    output reg [22:0]flash_a,//address
    input wire [7:0]flash_d,//data
    // output reg flash_rp_n,//复位信号
    // output reg flash_vpen,//写保护 低无法改写
    //output reg flash_ce_n,//片选信号 低有效（不改？
    // output reg flash_oe_n,//读使能
    // output reg flash_we_n,//写使能
    //output reg flash_byte_n

    //ip core
    output reg vga_mem_wea, 
    output reg [18:0]vga_mem_addra,//输入地址
    output reg [7:0]vga_mem_in
    // output reg led,
    // output reg led2
    //output reg [18:0]vga_mem_addrb//输出地址
);
integer addr_state, next_state, last_state;//0~3?
reg[22:0] base_flash_addr;
integer state;
reg [22:0] curr_addr;
reg flag1, flag2;
// reg finish_flag;
reg disable_clk;// 地址跳转时停止一个clk
//reg [7:0] curr_data;
always @(addr_state) begin
    case (addr_state)
        0: begin
            next_state <= 1;
            last_state <= 3;
        end
        1: begin
            next_state <= 2;
            last_state <= 0;
        end
        2: begin
            next_state <= 3;
            last_state <= 1;
        end
        3: begin
            next_state <= 0;
            last_state <= 2;
        end
        default: begin
            next_state <= next_state;
            last_state <= last_state;
        end
    endcase
end

integer count;
always @(posedge clk) begin
    if (rst == 1'b1) begin 
        // led2 <= 1;
        // finish_flag <= 0;
        disable_clk <= 0;
        flag1 <= 0;
        flag2 <= 0;
        count <= 0;
        addr_state <= 0;
        base_flash_addr <= 23'b0;

        state <= 0;
        curr_addr <= 23'b0;
        flash_a <= 23'b0;
        vga_mem_addra <= 19'b0;
        vga_mem_in <= 8'b0;
        vga_mem_wea <= 1;
    end
    else if (add_addr) begin
        // led2 <= 1;
        if (flag1 == 0) begin
            // finish_flag <= 1;
            //disable_clk <= 1;
            flag1 <= 1;
            count <= 0;
            addr_state <= next_state;
            if (next_state == 0) begin
                base_flash_addr <= 23'b0;
                curr_addr <= 23'b0;
                state <= 1;
            end else begin
                base_flash_addr <= base_flash_addr + 480000;
                curr_addr <= base_flash_addr + 480000;
                state <= 1;
            end
        end
    end else if (!add_addr) begin
        flag1 <= 0;
    end
    if (dec_addr) begin
        if (flag2 == 0) begin
            // finish_flag <= 1;
            //disable_clk <= 1;
            flag2 <= 1;
            count <= 0;
            addr_state <= last_state;
            if (addr_state == 0) begin
                base_flash_addr <= (480000 << 1) + 480000;
                curr_addr <= (480000 << 1) + 480000;
            end else begin
                base_flash_addr <= base_flash_addr - 480000;
                curr_addr <= base_flash_addr - 480000;
            end
        end
    end else if (!dec_addr) begin
        flag2 <= 0;
    end
    if (!add_addr && !dec_addr)
        disable_clk <= 0;
    if ((add_addr || dec_addr) && disable_clk == 0)
        disable_clk <= 1;
    else begin
        if (count == 51000000) begin
            count <= 0;
            addr_state <= next_state;
            if (next_state == 0) begin
                base_flash_addr <= 23'b0;
                curr_addr <= 23'b0;
                state <= 1;
            end else begin
                base_flash_addr <= base_flash_addr + 480000;
                curr_addr <= base_flash_addr + 480000;
                state <= 1;
            end
        end else if (hold_addr == 0 && !add_addr && !dec_addr)
            count <= count + 1;
        if (state == 0) begin//改地址
            state <= 1;
            vga_mem_wea <= 0;
            if (curr_addr == base_flash_addr + 479999)
                curr_addr <= base_flash_addr;
            else 
                curr_addr <= curr_addr + 1;
                
        end
        else if (state == 1) begin//读取flash
            state <= 2;
            // flash_oe_n <= 0;
            // flash_we_n <= 1;
            flash_a <= curr_addr;
            vga_mem_addra <= curr_addr - base_flash_addr;
        end
        else if (state == 2) begin//修改ip core
            state <= 0;
            vga_mem_wea <= 1;
            
            vga_mem_in <= flash_d;
        end
    end
end
endmodule
            


