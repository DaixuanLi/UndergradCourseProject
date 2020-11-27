`include "defines.vh"

module serial_cpld (
    input wire clk,
    input wire rst,

    // input wire[7:0] serial_data_i,
    input wire[1:0] w_r_i,

    input wire data_ready,
    input wire tbre,
    input wire tsre,


    output reg rdn,
    output reg wrn,
    // output wire[7:0] w_data_o,
    // output wire[7:0] r_data_o,
    output wire[1:0] status_o
);

reg busy;

assign status_o[0] = !busy;
assign status_o[1] = data_ready;
// assign w_data_o = mem_data_i;
// assign r_data_o = serial_data_i;

integer w_state;

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        // w_data_o <= `ZERO8;
        // r_data_o <= `ZERO8;
        rdn <= `Disable_N;
        wrn <= `Disable_N;
        busy <= 1'b0;
        w_state <= 0;
    end
    else begin
        busy <= 1'b0;
        rdn <= `Disable_N;
        wrn <= `Disable_N;
        w_state <= 0;
        if (w_r_i == `SerialRead) begin

        end
        else if (w_r_i == `SerialWrite) begin
            if (w_state == 0) begin
                busy <= 1'b1;
                wrn <= `Enable_N;
                w_state <= 1;
            end
            else if (w_state == 1) begin
                wrn <= `Disable_N;
                w_state <= 2;
            end
            else if (w_state == 2) begin
                if (tbre) begin
                    w_state <= 3;
                end
            end 
            else if (w_state == 3) begin
                if (tsre) begin
                    w_state <= 0;
                    busy <= 1'b0;
                end
            end
        end
    end
end

endmodule