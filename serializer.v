module serializer 
(
input wire   [7:0] P_DATA,
input wire  ser_en,

input wire  CLK,RST,

output wire ser_done,
output reg  ser_data
);
 
reg [7:0] shift_reg;
reg [7:0 ] count;
wire count_max;


/*always@(*)
 begin
	if(ser_en && exi )
		begin
			shift_reg <= P_DATA;
		end
	else
		begin
			shift_reg <= shift_reg;
		end
 end
 */
 
always@(posedge CLK or negedge RST)
 begin	
 if(!RST)
	begin
		shift_reg <= 8'b0;
		ser_data  <= 1'b0;
	end
 else
	begin
		if (ser_en &&(count== 1'b0)  )
			shift_reg <= P_DATA;
		
		else if(!(count_max))
			begin
				ser_data     <= shift_reg[0];
				shift_reg[0] <= shift_reg[1];
				shift_reg[1] <= shift_reg[2];
				shift_reg[2] <= shift_reg[3];
				shift_reg[3] <= shift_reg[4];
				shift_reg[4] <= shift_reg[5];
				shift_reg[5] <= shift_reg[6];
				shift_reg[6] <= shift_reg[7];
			end
    end


	
end

always@(posedge CLK or negedge RST)
 begin
	if(!RST)	
		begin
			count 	  <= 4'b0;
		end
	else if (ser_en && (!(count_max)))
		count <= count + 1'b1;
	else if	(count_max)
		begin
			count <= 1'b0;
		end	
	
 end
 
 assign ser_done =  ( count == 4'b1001 ); 
 assign count_max = ( count == 4'b1001); 
endmodule
