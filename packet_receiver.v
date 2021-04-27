//Author Sushma
module packet_receiver(input clk1,rst,packet_valid_i,
				  input [7:0] pdata,
				  input wfull_port_1,wfull_port_2,wfull_port_3,
                  output reg stop_packet_send, 
                  output reg FIFO_EN_1,FIFO_EN_2,FIFO_EN_3,
				  output winc_port_1,winc_port_2,winc_port_3,waddr_in_port_1,waddr_in_port_2,waddr_in_port_3,
                  output reg [7:0]wdata_port_1,wdata_port_2,wdata_port_3
                  );
				  
 parameter TS1=8'd0,TS2=8'd1,TS3=8'd2;
 parameter  IDLE		=	4'b0001,
			SRC		    =	4'b0010,
			DST		    =	4'b0011,
			SIZE		=	4'b0100,
			DATA		=	4'b0101,
			CRC    	    =	4'b0110,
			sCRC	    =	4'b0111,
			WAIT	    =	4'b1000;
			
reg [3:0] present_state, next_state;
reg [7:0] temp1, temp2;                        // temporary registers for storing input packet data byte 
reg [2:0]x;                                   //variable used for packet size
reg [2:0]k;                                   //variable used for count operation
//-------------------------------------------------------------------------------------------------------------------------------------------
//temp1 logic
always @(*)
	begin
		temp1 <=pdata;
		temp2 <=temp1;
	end
//--------------------------------------------------------------------------------------------------------------------------------------------
// rst logic for states
always@(posedge clk1)
	begin
		if(!rst)
				present_state <=IDLE;  // hard rst
		else
				present_state <=next_state;
	end
//--------------------------------------------------------------------------------------------------------------------------------------------
// stop packet send enable and disable block
always@(posedge clk1)
    begin 
        if((wfull_port_1==1'b1)|(wfull_port_2==1'b1)|(wfull_port_3==1'b1))
            stop_packet_send <=1'b1;
        else stop_packet_send <=1'b0;
    end
//-------------------------------------------------------------------------------------------------------------------------------------------	
always@(*)
	begin
		case(present_state)
		IDLE:   // decode address state 
		begin
			if(packet_valid_i==1'b1 && stop_packet_send==1'b0)
                    // ******************pdata should be stored
					next_state<=SRC;   //load source id to test for trusted source
			else 
				next_state<=IDLE;	   // same state
		end
//------------------------------------------------------------------------------------------------------------------------------------------
		SRC: 			// Loading Source id state
		begin	
            if((pdata==TS1) | (pdata==TS2) | (pdata==TS3))
                begin temp1<=pdata;
                      next_state<=DST; end
            else 
                next_state<=WAIT;
		end
//-----------------------------------------------------------------------------------------------------------------------------------------
		DST:                    // Loading Destination id state
		begin
			if((8'd0<=pdata) && (pdata<=8'd127))
                begin wdata_port_1[waddr_in_port_1]<=temp1;
                      temp1<=pdata;
                      FIFO_EN_1=1'b1;
					  next_state<=SIZE; end
	        else if((8'd128<=pdata) && (pdata<=8'd195)) 
                begin wdata_port_2[waddr_in_port_2] <=temp1;
                      temp1 <=pdata;
                      FIFO_EN_2=1'b1;
					  next_state <=SIZE; end        
            else if((8'd196<=pdata) && (pdata<=8'd255)) 
                begin wdata_port_3[waddr_in_port_3] <=temp1;
                      temp1 <=pdata;
                      FIFO_EN_3=1'b1;
					  next_state <=SIZE; end
				else
					next_state <=DST;                //********** We need a software rst feature in our design
			end
//-----------------------------------------------------------------------------------------------------------------------------------------
		SIZE:                        //Loading Size state
		begin
            if (FIFO_EN_1==1'b1)
             begin wdata_port_1[waddr_in_port_1]<=temp1;  //Dest id byte is transmitted 
                   temp1<=pdata;                         //Size byte is stored in temp1
                   k<=temp1[2:0];                        //K variable is used to know data size and count decrement operation
				   x<=k+4;                             //Size of packet is calculated for future use
                   next_state<=DATA; end    
            else if (FIFO_EN_2==1'b1)
             begin wdata_port_2[waddr_in_port_2]<=temp1;  //Dest id byte is transmitted 
                   temp1<=pdata;                         //Size byte is stored in temp1
                   k<=temp1[2:0];                        //K variable is used to know data size and count decrement operation
				   x<=k+4;                             //Size of packet is calculated for future use			  	   
                   next_state<=DATA; end  
			else if (FIFO_EN_3==1'b1)
             begin wdata_port_3[waddr_in_port_3]<=temp1;  //Dest id byte is transmitted 
                   temp1<=pdata;                         //Size byte is stored in temp1
                   k<=temp1[2:0];                        //K variable is used to know data size and count decrement operation
				   x<=k+4;                             //Size of packet is calculated for future use      
                   next_state<=DATA; end  
		end
//--------------------------------------------------------------------------------------------------------------------------------------------
		DATA:			            //Loading data state
		begin
			if (FIFO_EN_1==1'b1)
             begin wdata_port_1[waddr_in_port_1]<=temp1;  //Size byte is transmitted to memory and later data bytes are transferred
                   temp1<=pdata;                         //Data bytes are stored in temp1 one after the other
                   k<=k-1;                              //K is decremented until all data enters into receiver
                   if(k==0) next_state<=CRC;            //If last data byte enters into receiver go to next state
                   else next_state<=DATA;
             end
			else if(FIFO_EN_2==1'b1)
             begin wdata_port_2[waddr_in_port_2]<=temp1;  ///Size byte is transmitted to memory and later data bytes are transferred
                   temp1<=pdata;                         //Data bytes are stored in temp1 one after the other
                   k<=k-1;                              //K is decremented until all data enters into receiver
                   if(k==0) next_state<=CRC;            //If last data byte enters into receiver go to next state
                   else next_state<=DATA;
             end
            else if (FIFO_EN_3==1'b1)
             begin wdata_port_3[waddr_in_port_3]<=temp1;  //Size byte is transmitted to memory and later data bytes are transferred
                   temp1<=pdata;                         //Data bytes are stored in temp1 one after the other
                   k<=k-1;                              //K is decremented until all data enters into receiver
                   if(k==0) next_state<=CRC;            //If last data byte enters into receiver go to next state
                   else next_state<=DATA;
             end
		end
//-------------------------------------------------------------------------------------------------------------------------------------------
		CRC:         	// Loading CRC byte state
		begin
				if (FIFO_EN_1==1'b1)
                 begin wdata_port_1[waddr_in_port_1]<=temp1;  //Last data byte is transferred to memory 
                       temp1<=pdata;                         //CRC byte is stored in temp1
				       next_state<=sCRC;
			     end
                else if (FIFO_EN_2==1'b1)
                 begin wdata_port_2[waddr_in_port_2]<=temp1;  //Last data byte is transferred to memory 
                       temp1<=pdata;                         //CRC byte is stored in temp1
				       next_state<=sCRC;
			     end
                else if (FIFO_EN_3==1'b1)
                 begin wdata_port_3[waddr_in_port_3]<=temp1;  //Last data byte is transferred to memory 
                       temp1<=pdata;                         //CRC byte is stored in temp1
				       next_state<=sCRC;
			     end
        end
//-------------------------------------------------------------------------------------------------------------------------------------------
		sCRC:                          // transfer CRC state
		begin
                if(packet_valid_i==1'b1)
                begin
                  if(FIFO_EN_1==1'b1) begin
                  wdata_port_1[waddr_in_port_1]<=temp1;
                  temp1<=pdata;
                  next_state<=SRC; end   
                  else if(FIFO_EN_2==1'b1) begin
                  wdata_port_2[waddr_in_port_2]<=temp1;
                  temp1<=pdata;
                  next_state<=SRC; end
                  else if(FIFO_EN_3==1'b1) begin
                  wdata_port_3[waddr_in_port_3]<=temp1;
                  temp1<=pdata;
                  next_state<=SRC; end         //********store crc and go to SRC state to test SRC_id of next packet
                end   
                else 
                   next_state<=IDLE;
		end
//-------------------------------------------------------------------------------------------------------------------------------------------
		WAIT:			// check parity error
		begin
				if (packet_valid_i==1'b0)
					next_state<=IDLE;
				else
					next_state<=WAIT;
		end
//--------------------------------------------------------------------------------------------------------------------------------------------
		default:					//default state
				next_state<=IDLE; 
 		endcase								              	// state machine completed
    end
endmodule
