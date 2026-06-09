`timescale 1ns / 1ps
module baudrate_gen#(
parameter CLK_FREQ=27000000, parameter BAUD_RATE=115200)(
    input n_rst,
    input clk,
    output reg baud_en
);

reg[7:0] count=0;

always@(posedge clk or negedge n_rst) begin
    if(!n_rst) begin
        count<=8'd0;
        baud_en<=1'b0;
    end else if(count==(CLK_FREQ/BAUD_RATE)-1) begin
        count<=8'd0;
        baud_en <= 1'b1;
    end else begin
        count<=count+1;
        baud_en <=1'b0;
        
    end
end
endmodule