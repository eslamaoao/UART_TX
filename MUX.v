module MUX 
(
input     wire        [1:0] mux_sel,
input     wire               CLK,
input     wire               RST,
input     wire               IN_0,
input     wire               IN_1,
input     wire               IN_2,
input     wire               IN_3,
output    reg                MUX_OUT
);

always@(posedge CLK or negedge RST)
	begin
	  if(!RST)
	    MUX_OUT <= 1'b1;
	  else
		begin
			case(mux_sel)
			2'b00 : begin
						MUX_OUT <= IN_0;//1'b0
					end
			2'b01 : begin
						MUX_OUT <= IN_1; //1'b1
					end
			2'b10 : begin
						MUX_OUT <=IN_2;  //ser_data
					end
			2'b11 : begin
						MUX_OUT <=IN_3; //par_bit
					end
			endcase
		end
	end


endmodule 