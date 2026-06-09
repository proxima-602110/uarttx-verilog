module uart_rtl(
    input n_rst,
    input clk,
    input tx_en,
    input[7:0] data,
    output tx_out
);

localparam IDLE=2'b00,START=2'b01,DATA=2'b10,STOP=2'b11;  //Transmission states 
reg[1:0] state,n_state;        
reg[2:0] bit_count=3'd0;   
reg tx_line=1'b1; //Initially the tx line is held high before the stop bit arrives
wire baud_en;
reg[7:0] shift_reg=8'd0;    
baudrate_gen BAUD_GENERATOR(.n_rst(n_rst),.clk(clk),.baud_en(baud_en));   


always@(posedge clk or negedge n_rst) begin 
    if(!n_rst) begin
        bit_count<=3'd0;
        tx_line<=1'b1;
        shift_reg<=8'd0;
        state<=IDLE;    //The transmitter is initially in IDLE state, and should reset to this state when reset is enabled
    end else begin
        state<=n_state;
    end
end
         
    //State logic for the transmitter. The baud rate enable signal (baud_en) acts as a synchronizer for handling different processes during the data transmission
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
                n_state=STOP;    //Once the 8-bit data is transmitted completely, the transmission process ends
            end 
         end
         
         STOP: begin
            if(baud_en) begin
                n_state=IDLE;    //At the next baud signal, the stop bit is received and the tx line is pulled back high
            end 
         end
    endcase
end


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
                tx_line<=shift_reg[0];    //Load the LSB bit into the shift register
                if(baud_en&&bit_count==3'd7) begin
                    shift_reg <= shift_reg >>1;  //Shift the last bit (MSB) out and reset the bit count
                    bit_count<=3'd0;
                end else if(baud_en) begin
                    shift_reg <= shift_reg >>1; //Shift the data until all the 8 bits are passed
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

assign tx_out=tx_line;    //Data arrives at tx_out
endmodule
