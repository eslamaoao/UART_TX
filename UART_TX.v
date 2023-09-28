module UART_TX 
(
input  wire [7:0] P_DATA,
input  wire DATA_VALID,
input  wire PAR_EN,
input  wire PAR_TYP,
input  wire CLK,RST,
output wire TX_OUT,
output wire busy
);

////////////////////////////////////
wire ser_en_wire;
wire ser_done_wire;
wire ser_data_wire;
wire [1:0] mux_sel_wire;
wire par_bit_wire;



/////////////////////////////////////
serializer U0 
(
.P_DATA 	(P_DATA),
.ser_en 	(ser_en_wire),
.CLK 		(CLK),
.RST 		(RST),
.ser_done	(ser_done_wire),
.ser_data 	(ser_data_wire)
);
///////////////////////////////////



///////////////////////////////////////
FSM_TX U1
(
.Data_Valid (DATA_VALID),
.ser_done	(ser_done_wire),
.PAR_EN 	(PAR_EN),
.CLK 		(CLK),
.RST 		(RST),
.ser_en 	(ser_en_wire),
.mux_sel 	(mux_sel_wire),
.busy 		(busy)
);
///////////////////////////////////////



///////////////////////////////////////////
parity_calc U2
(
.P_DATA 		(P_DATA),
.PAR_TYP 		(PAR_TYP),
.Data_Valid  	(DATA_VALID),
.CLK 			(CLK),
.RST 			(RST),
.par_bit 		(par_bit_wire)
);
///////////////////////////////////////////




////////////////////////////////////////////
MUX U3
(
.mux_sel 	(mux_sel_wire),
.IN_0	    (1'b0),
.IN_1     (1'b1),
.IN_2     (ser_data_wire),
.IN_3 	   (par_bit_wire),
.CLK 		   (CLK),
.RST 		   (RST),
.MUX_OUT 	(TX_OUT)
); 

/////////////////////////////////////////////
endmodule