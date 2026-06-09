`timescale 1ns / 1ps
module testbench;
reg n_rst,clk,tx_en;
reg[7:0] data;
wire tx_out;

uart_rtl dut1(.n_rst(n_rst),.clk(clk),.tx_en(tx_en),.data(data),.tx_out(tx_out));

always #18.5185 begin clk=~clk;
end

initial begin
//Reset state
n_rst=1'b0;
clk=1'b0;
tx_en=1'b0;
data=8'd0;
#10;
//Reset disabled
n_rst=1'b1; #18.5185
data=8'b01100101; #80
tx_en=1'b1; #40;
tx_en=1'b0;
#150000;
$stop;
end
endmodule

