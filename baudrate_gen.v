`timescale 1ns / 1ps
module baudrate_gen#(
    parameter CLK_FREQ=27000000, parameter BAUD_RATE=115200)( //I have taken my Gowin FPGA's default clock frequency for this test 
    input n_rst,
    input clk,
    output reg baud_en
);

    reg[7:0] count=0;    //Count goes from CLK_FREQ/BAUD_RATE-1 = 27*10^6/115200 - 1 which is approximately 233

always@(posedge clk or negedge n_rst) begin
    if(!n_rst) begin
        count<=8'd0;
        baud_en<=1'b0;
    end else if(count==(CLK_FREQ/BAUD_RATE)-1) begin
        count<=8'd0;
        baud_en <= 1'b1;    //Enable signal goes high every 233 counts
    end else begin
        count<=count+1;
        baud_en <=1'b0;
        
    end
end
endmodule
