`timescale 1ns / 1ps
module uart_rtl(
    input n_rst,
    input clk,
    input tx_en,
    input[7:0] data,
    output tx_out
);

localparam IDLE=2'b00,START=2'b01,DATA=2'b10,STOP=2'b11;
reg[1:0] state,n_state;
reg[2:0] bit_count=3'd0;    
reg tx_line=1'b1;
wire baud_en;
reg[7:0] shift_reg=8'd0;    
baudrate_gen BAUD_GENERATOR(.n_rst(n_rst),.clk(clk),.baud_en(baud_en));    //115200


always@(posedge clk or negedge n_rst) begin 
    if(!n_rst) begin
        bit_count<=3'd0;
        tx_line<=1'b1;
        shift_reg<=8'd0;
        state<=IDLE;
    end else begin
        state<=n_state;
    end
end
         
//State logic
always@(*) begin
    n_state=state;
    
    case(state)
        IDLE: begin
          if(tx_en) begin
                n_state=START;
          end 
        end
        
        START: begin
            if(baud_en) begin
                n_state=DATA;
            end 
         end
         
         DATA: begin
            if(baud_en&&bit_count==3'd7) begin
                n_state=STOP;
            end 
         end
         
         STOP: begin
            if(baud_en) begin
                n_state=IDLE;
            end 
         end
    endcase
end

//Clocked logic
always@(posedge clk or negedge n_rst) begin 
    if(!n_rst) begin
        bit_count<=3'd0;
        tx_line<=1'b1;
        shift_reg<=8'd0;
    end else begin
        case(state)
            IDLE: begin 
              tx_line<=1'b1;
              if(tx_en) begin
                shift_reg<=data;
                bit_count<=3'd0;
              end
            end
            
            START: begin
                tx_line<=1'b0;
            end
            
            DATA: begin
                tx_line<=shift_reg[0];
                if(baud_en&&bit_count==3'd7) begin
                    shift_reg <= shift_reg >>1;
                    bit_count<=3'd0;
                end else if(baud_en) begin
                    shift_reg <= shift_reg >>1;
                    bit_count <= bit_count + 1;
                end 
             end
             
             STOP: begin
                tx_line<=1'b1;
                bit_count<=3'd0;
             end
        endcase
   end
end

assign tx_out=tx_line;
endmodule