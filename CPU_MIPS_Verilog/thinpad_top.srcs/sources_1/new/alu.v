module alu(
    output wire[15:0] leds,       
    input  wire[31:0] dip_sw,
    input wire clock_btn,
    input wire reset_btn   
);

//ALU
/*
    状态机
    0: 初始状态，等待A输入
    1: A输入完成，等待B输入
    2: B输入外成，等待OP输入，同时显示运算结果
    3: 输出进位标志
*/

integer state;
reg[15:0] results;
reg[15:0] A;
reg[15:0] B;
reg[15:0] tmp;
reg[15:0] carry_tmp;
reg carry;
reg past_clock;
wire[3:0] OP;


assign leds = results;
assign OP = dip_sw[3:0];

always @(posedge clock_btn or posedge reset_btn) begin
    if (reset_btn) begin
        state <= 0;
        A <= 0;
        B <= 0;
    end
    else if (clock_btn) begin
        if (state == 0) begin
            A <= dip_sw[15:0];
        end
        else if (state == 1) begin
            B <= dip_sw[15:0];
        end
        state <= state + 1;
    end
end

always @(state or OP) begin
    if (state == 0) begin
        results <= 0;
        tmp <= 0;
    end
    if (state == 2) begin
        case(OP)
            1 : begin
                results <= A + B;
                carry_tmp <= A + B;
            end
            2 : begin
                results <= A - B;
                carry_tmp <= A - B;
            end
            3 : results <= A & B;
            4 : results <= A | B;
            5 : results <= A ^ B;
            6 : results <= ~A;
            7 : results <= A << B;
            8 : results <= A >> B;
            9 : results <= $signed(A) >>> B;
            10 : begin
                results = A << B;
                tmp = A >> (16 - B);
                results = results | tmp;
            end
        endcase
    end
    if (state == 3) begin
        if (OP == 1) begin
            if ((A[15] == 0 && B[15] == 0 && carry_tmp[15] == 1) || (A[15] == 1 && B[15] == 1 && carry_tmp[15] == 0))
                results <= 1;
            else
                results <= 0; 
        end
        else if (OP == 2) begin
            if ((A[15] == 0 && B[15] == 1 && carry_tmp[15] == 1) || (A[15] == 1 && B[15] == 0 && carry_tmp[15] == 0))
                results <= 1;
            else
                results <= 0;
        end
        else begin
            results <= 0;
        end
    end
end



endmodule