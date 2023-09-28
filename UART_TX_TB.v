
`timescale 1ns/1ps


module UART_TX_TB22 ();

/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////

parameter DATA_WD_TB = 8 ;      
parameter CLK_PERIOD = 10 ; 


/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////

reg [DATA_WD_TB-1:0] P_DATA_TB;
reg DATA_VALID_TB;
reg PAR_EN_TB;
reg PAR_TYP_TB;
reg CLK_TB,RST_TB;
wire TX_OUT_TB;
wire busy_TB;
/*
reg                  		CLK_TB;
reg                  		RST_TB;
reg     [DATA_WD_TB-1:0]    P_DATA_TB;
reg                  		Data_Valid_TB;
reg                 		parity_enable_TB;
reg                 		parity_type_TB; 
wire                		TX_OUT_TB;
wire                		busy_TB;
*/


////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////

initial
 begin

 // Initialization
 initialize() ;

 // Reset
 reset() ; 


 ////////////// Test Case 1 (No Parity) //////////////////

 // UART Configuration (Parity Enable = 0)
 UART_CONFG (1'b0,1'b0);

 // Load Data 
 DATA_IN(8'hA3);  

 // Check Output
 chk_tx_out(8'hA3,0,0,0) ;

 #2000
 
 ////////////// Test Case 2 (Even Parity) ////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 0)
 UART_CONFG (1'b1,1'b0);

 // Load Data 
 DATA_IN(8'hB4);  

 // Check Output
 chk_tx_out(8'hB4,1,0,1) ;
 
 #2000
 
 ////////////// Test Case 3 (Odd Parity) ////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 1)
 UART_CONFG (1'b1,1'b1);

 // Load Data 
 DATA_IN(8'hD2);  

 // Check Output
 chk_tx_out(8'hD2,1,1,2) ; 

  #2000

$stop ;

end
 
 

///////////////////// Clock Generator //////////////////

always #(CLK_PERIOD/2) CLK_TB = ~CLK_TB ;

////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////

task initialize ;
  begin
	CLK_TB            = 1'b0   ;
	RST_TB            = 1'b1   ;    // rst is deactivated
	P_DATA_TB         = 8'h00  ;
	PAR_EN_TB  		  = 1'b0   ;
	PAR_TYP_TB     	  = 1'b0   ;
	DATA_VALID_TB     = 1'b0   ;
  end
endtask

///////////////////////// RESET /////////////////////////
task reset ;
  begin
	#(CLK_PERIOD)
	RST_TB  = 'b0;           // rst is activated
	#(CLK_PERIOD)
	RST_TB  = 'b1;
	#(CLK_PERIOD) ;
  end
endtask

///////////////////// Configuration ////////////////////
task UART_CONFG ;
  input                   PAR_EN ;
  input                   PAR_TYP ;

  begin
	PAR_EN_TB     = PAR_EN   ;
	PAR_TYP_TB    = PAR_TYP   ;
  end
endtask

/////////////////////// Data IN /////////////////////////
task DATA_IN ;
 input  [DATA_WD_TB-1:0]  DATA ;

 begin
	P_DATA_TB         = DATA  ;
	DATA_VALID_TB     = 1'b1   ;
	#CLK_PERIOD
	DATA_VALID_TB     = 1'b0   ;
 end
endtask

//////////////////  Check Output  ////////////////////
task chk_tx_out ;
 input  [DATA_WD_TB-1:0]  		DATA    ;
 input                          PAR_EN  ; 
 input                          PAR_TYP ; 
 input  [2:0]                   Test_NUM;
 
 reg    [10:0]  gener_out ,expec_out;     //longest frame = 11 bits (1-start,1-stop,8-data,1-parity)
 reg            parity_bit;
 
 integer   i  ;

 begin
 
	@(posedge busy_TB)
	for(i=0; i<11; i=i+1)
		begin
		@(negedge CLK_TB) gener_out[i] = TX_OUT_TB ;
		end
		
    if(PAR_EN_TB)
		if(PAR_TYP_TB)
			parity_bit = ~^DATA ;
		else
			parity_bit = ^DATA ;
	else
			parity_bit = 1'b1 ;	
	
    if(PAR_EN_TB)
		expec_out = {1'b1,parity_bit,DATA,1'b0} ;
	else
		expec_out = {1'b1,1'b1,DATA,1'b0} ;
			
	if(gener_out == expec_out) 
		begin
			$display("Test Case %d is succeeded",Test_NUM);
		end
	else
		begin
			$display("Test Case %d is failed", Test_NUM);
		end
 end
endtask
///////////////// Design Instaniation //////////////////
UART_TX DUT (
.CLK(CLK_TB),
.RST(RST_TB),
.P_DATA(P_DATA_TB),
.DATA_VALID(DATA_VALID_TB),
.PAR_EN(PAR_EN_TB),
.PAR_TYP(PAR_TYP_TB),
.TX_OUT(TX_OUT_TB), 
.busy(busy_TB)
);

endmodule

/*`timescale 1ns/1ps

module UART_TX_TB ();





parameter CLOCK_PERIOD = 10; //// 200 MHz clock frequency 


///////////////////////////////////////
/////////////// DUT Signals////////////
///////////////////////////////////////
reg [7:0] P_DATA_TB;
reg DATA_VALID_TB;
reg PAR_EN_TB;
reg PAR_TYP_TB;
reg CLK_TB,RST_TB;
wire TX_OUT_TB;
wire busy_TB;
////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////

initial 
 begin
 
/////////////////////////////////////
	initialize ();
	reset ();
/////////////////////////////////////


//////////////////////////////////////////////////////////////
////////////test with parity enable even parity //////////////
	P_DATA_TB 	  = 8'b01010001 ;
	#10
	DATA_VALID_TB = 1'b1 ;
	//chk_trans_out(11'b11010100010);
	#10
	DATA_VALID_TB = 1'b0 ;
	PAR_EN_TB     = 1'b0;
	PAR_TYP_TB    = 1'b0 ;
	//chk_trans_out(11'b11010100010);
//////////////////////////////////////////////////////////////
//////////////test sending two packet continuos the second one with no parity
	#90
	PAR_EN_TB     = 1'b1 ;
	DATA_VALID_TB = 1'b1 ;
	#10
	DATA_VALID_TB = 1'b0 ;
	#100
	DATA_VALID_TB = 1'b1 ;
	#10
	DATA_VALID_TB = 1'b0 ;
/////////////////////////////////
// all cases are valid but i don't have time to present them professionally :)))))
/////////////



#1000;
$stop;
end




/////////////////////////////////////////////
////////////////initialize//////////////////
///////////////////////////////////////////

task initialize;
 begin
	DATA_VALID_TB = 1'b0 ;
	PAR_EN_TB     = 1'b0 ;
	PAR_TYP_TB    = 1'b0 ;
	P_DATA_TB 	  = 8'b0 ;
	RST_TB   	  = 1'b1 ; 
	CLK_TB   	  = 1'b0 ;
 end
endtask



/////////////////////////////////////////////
/////////////// reset //////////////////////
////////////////////////////////////////////

task reset; 
 begin
	#CLOCK_PERIOD ;
	RST_TB = 1'b0 ;
	#CLOCK_PERIOD ;
	RST_TB = 1'b1 ;
	#(CLOCK_PERIOD/2) ;
 end
endtask




/////////////////////////////////////////////
/////////////// CLK Generator ///////////////
/////////////////////////////////////////////

always #(CLOCK_PERIOD/2) CLK_TB = ~ CLK_TB;




task chk_trans_out ;
 input           [10:0]     TRANS_BITS ; 

 reg    [10:0]  gener_out ;

 integer   i  ;

 begin
 
	wait ( DATA_VALID_TB )
		#CLOCK_PERIOD
	for(i=0; i<10; i=i+1)
		begin
		#CLOCK_PERIOD gener_out[i] = TX_OUT_TB ;
		end

	if(gener_out == TRANS_BITS) 
		begin
			$display("Test Case is succeeded");
		end
	else
		begin
			$display("Test Case  is failed");
		end
 end
endtask















/////////////////////////////////////////////////
/////////////// DUT Instantation ///////////////
///////////////////////////////////////////////
UART_TX DUT
(
.P_DATA 	(P_DATA_TB),
.DATA_VALID (DATA_VALID_TB),
.PAR_EN 	(PAR_EN_TB),
.PAR_TYP 	(PAR_TYP_TB),
.CLK  		(CLK_TB),
.RST  		(RST_TB),
.TX_OUT  	(TX_OUT_TB),
.busy   	(busy_TB)
);




endmodule
*/

