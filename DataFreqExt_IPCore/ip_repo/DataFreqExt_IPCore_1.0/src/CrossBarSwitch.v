`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    06:18:05 11/17/2015 
// Design Name: 
// Module Name:    CrossBarSwitch 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module CrossBarSwitch(
	input clk,
	input rst,
	
	input [NUM_STATE_WIDTH_BIT-1:0] Normstate0,
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] Normindex0,

	input [NUM_STATE_WIDTH_BIT-1:0] Normstate1,
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] Normindex1,
	
	input [NUM_STATE_WIDTH_BIT-1:0] Clamstate0,
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] Clamindex0,

	input [NUM_STATE_WIDTH_BIT-1:0] Clamstate1,
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] Clamindex1,
	
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] swindex0,
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] swindex1,
	
	output reg Norminterrupt0,
	output reg Norminterrupt1,
	output reg Norminterrupt2,
	
	output reg Claminterrupt0,
	output reg Claminterrupt1,
	output reg Claminterrupt2,
	
	input NormWaiting0,
	input NormWaiting1,
	input NormWaiting2,
	
	input ClamWaiting0,
	input ClamWaiting1,
	input ClamWaiting2,
	
	output reg cont0,
	output reg cont1,
	output reg cont2,
	
	output reg Normtransfered0,
	output reg Normtransfered1,
	output reg Normtransfered2,
	
	output reg Clamtransfered0,
	output reg Clamtransfered1,
	output reg Clamtransfered2
    );
	 
//Define parameter//
parameter LENGTH_ARRAY = 100;
parameter NUM_PROCESSOR = 3;
parameter DATA_INDEX_WIDTH = 32;
parameter BIT_ON_TAILS = 7;

localparam integer NUM_STATE_WIDTH_BIT = log2(NUM_STATE);
localparam integer LENGTH_ARRAY_WIDTH_BIT = log2(LENGTH_ARRAY);
localparam integer LENGTH_HASH_ARRAY = 1 << BIT_ON_TAILS;
localparam integer LENGTH_HASH_ARRAY_WIDTH_BIT = log2((1 << BIT_ON_TAILS + 1));
localparam integer MASK = (1 << BIT_ON_TAILS) - 1;
localparam integer NUM_STATE = 9;

localparam Wait = 0;
localparam WaitForInterrupt = 1;
localparam Fetch = 2;
localparam WaitDataStream = 3;
localparam FirstTempIndex = 4;
localparam WaitTempIndex = 5;
localparam RdHashOccurr = 6;
localparam CollisionCal = 7;
localparam HashBuild = 8;

function [31:0] log2;
	input [31:0] value;
	integer l;
	begin
		log2 = 0;
		for (l = 0; (1<<l) < value; l = l + 1)
			log2 = l+1;
	end
endfunction


//Define reg/wire
reg ContProcess;
reg [3:0] cnt;
integer i;

always @(posedge clk)
begin
	if (rst)
		begin
			Norminterrupt0 <= 0;
			Norminterrupt1 <= 0;
			Norminterrupt2 <= 0;
		end
	else
		begin
			if ((Normstate0 == HashBuild) && (Normindex0 == swindex0))
					Norminterrupt0 <= 1;
			else if (NormWaiting0)
				Norminterrupt0 <= 0;	
	
			if ((Normstate1 == HashBuild) && (Normindex1 == swindex1))
					Norminterrupt1 <= 1;
			else if (NormWaiting1)
				Norminterrupt1 <= 0;		
		end
end

always @(posedge clk)
begin
	if (rst)
		begin
			Claminterrupt0 <= 0;
			Claminterrupt1 <= 0;
			Claminterrupt2 <= 0;
		end
	else
		begin
			if ((Clamstate0 == HashBuild) && (Clamindex0 == swindex0))
					Claminterrupt0 <= 1;
			else if (ClamWaiting0)
				Claminterrupt0 <= 0;	
	
			if ((Clamstate1 == HashBuild) && (Clamindex1 == swindex1))
					Claminterrupt1 <= 1;
			else if (ClamWaiting1)
				Claminterrupt1 <= 0;		
		end
end

always @(posedge clk)
begin
	if (rst)
		cnt <= 0;
	else
		if (cnt == 2*6)
			cnt <= cnt;
		else
		if (ContProcess)
			cnt <= cnt + 1;
end

always @(posedge clk)
begin
	if (rst)
		begin
			ContProcess <= 0;
			
			cont0 <= 0;
			cont1 <= 0;
			cont2 <= 0;
		end
	else
		begin
			if ((cnt == 0) && NormWaiting0 && ClamWaiting0)
				begin
					cont0 <= 1;
					cont1 <= 1;
					ContProcess <= 1;
				end
			else 
			if ((cnt == 2) && NormWaiting0 && NormWaiting1 && ClamWaiting0 && ClamWaiting1)
				begin
					cont0 <= 1;
					cont1 <= 1;
					cont2 <= 1;
					ContProcess <= 1;
				end
			else
			if (NormWaiting0 && NormWaiting1 && NormWaiting2 && ClamWaiting0 && ClamWaiting1 && ClamWaiting2)
				begin
					cont0 <= 1;
					cont1 <= 1;
					cont2 <= 1;
					ContProcess <= 1;
				end
			else
				begin
					cont0 <= 0;
					cont1 <= 0;
					cont2 <= 0;
					ContProcess <= 0;
				end
		end
end

always @(posedge clk)
begin
	if (rst)
		begin
			Normtransfered0 <= 0;
			Normtransfered1 <= 0;
			Normtransfered2 <= 0;
		end
	else
		begin
			if (Norminterrupt0) Normtransfered1 <= 1;
			if (Norminterrupt1) Normtransfered2 <= 1;
		end
end

always @(posedge clk)
begin
	if (rst)
		begin
			Clamtransfered0 <= 0;
			Clamtransfered1 <= 0;
			Clamtransfered2 <= 0;
		end
	else
		begin
			if (Claminterrupt0) Clamtransfered1 <= 1;
			if (Claminterrupt1) Clamtransfered2 <= 1;
		end
end
	
endmodule
