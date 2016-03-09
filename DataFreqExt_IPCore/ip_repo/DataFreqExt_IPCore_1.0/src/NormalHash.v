`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:37:28 01/04/2016 
// Design Name: 
// Module Name:    NormalHash 
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
module NormalHash(
	input clk,
	input rst,
	
	input en,
	input cont,
	input interrupt,
	input transfered,
	output Waiting,
	output reg complete,
		
	output DataRequest,	
	input CacheEnough,
	
	output reg [NUM_STATE_WIDTH_BIT-1:0] state,
	output reg [LENGTH_ARRAY_WIDTH_BIT-1:0] index,
	input [DATA_INDEX_WIDTH-1:0] DataStream,
	
	input [NUM_STATE_WIDTH_BIT-1:0] previous_state,
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] previous_index,
	input [DATA_INDEX_WIDTH-1:0] previous_collision,
	
	output reg [NUM_STATE_WIDTH_BIT-1:0] ostate,
	output reg [LENGTH_ARRAY_WIDTH_BIT-1:0] oindex,
	output reg [DATA_INDEX_WIDTH-1:0] ocollision,
	
	output [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] HashOccurrAddr,
	input [DATA_INDEX_WIDTH-1:0] HashValue,
	input [DATA_INDEX_WIDTH-1:0] OccurrValue,
	
	output reg WrEn,
	output reg [DATA_INDEX_WIDTH-1:0] NewHashValue,
	output reg [DATA_INDEX_WIDTH-1:0] NewOccurrValue
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

function [31:0] log2;
	input [31:0] value;
	integer l;
	begin
		log2 = 0;
		for (l = 0; (1<<l) < value; l = l + 1)
			log2 = l+1;
	end
endfunction

localparam Wait = 0;
localparam WaitForInterrupt = 1;
localparam Fetch = 2;
localparam WaitDataStream = 3;
localparam FirstTempIndex = 4;
localparam WaitTempIndex = 5;
localparam RdHashOccurr = 6;
localparam CollisionCal = 7;
localparam HashBuild = 8;

reg [DATA_INDEX_WIDTH-1:0] collision; 
reg [DATA_INDEX_WIDTH-1:0] TempIndex;

always @(posedge clk)
begin
	if (rst) 
		begin
			state <= Wait;
			
			index <= 0;
            complete <= 0;
            collision <= 0;

            WrEn <= 0;          
            
            oindex <= 0;
            ostate <= 0;
            ocollision <= 0;
		end
	else
		begin
			case(state)
			Wait:
				begin
					complete <= 0;
					collision <= 0;
					WrEn <= 0;
					if (en || cont) 
						begin							
							state <= Fetch;
						end
				end
			WaitForInterrupt:
				begin
					complete <= 0;
					collision <= 0;
					WrEn <= 0;
					if (cont)
						state <= Fetch;
				end
			Fetch: 
				begin
					if (CacheEnough)
						if (transfered)
							begin
								state <= WaitDataStream;
								index <= previous_index;
								collision <= previous_collision;
							end
						else
							begin
								state <= WaitDataStream;
								index <= 0;
								collision <= 0;
							end
				end
			WaitDataStream: 
				begin
					state <= FirstTempIndex;
					WrEn <= 0;
				end
			FirstTempIndex:
				begin
					TempIndex <= DataStream & MASK;
					state <= WaitTempIndex;
				end
			WaitTempIndex:
				begin
					state <= RdHashOccurr;
				end
			RdHashOccurr:
				begin
					state <= CollisionCal;
				end
			CollisionCal:
				begin
					if (OccurrValue != 0 && HashValue != DataStream)
						begin
							collision <= collision + 1;
							if (TempIndex == LENGTH_HASH_ARRAY - 1)
								TempIndex <= 0;
							else
								TempIndex <= TempIndex + 1;
							state <= RdHashOccurr;
						end
					else
						begin
							state <= HashBuild;
						end
				end
			HashBuild:
				begin
					if (interrupt)
						begin
							ostate <= WaitDataStream;
							oindex <= index + 1;
							ocollision <= collision;
							WrEn <= 1;
							NewHashValue <= DataStream;
							NewOccurrValue <= OccurrValue + 1;
							state <= WaitForInterrupt;
						end
					else
						begin	
							WrEn <= 1;
							NewHashValue <= DataStream;
							NewOccurrValue <= OccurrValue + 1;
							if (index == LENGTH_ARRAY - 1)
								begin
									state <= WaitForInterrupt;
									complete <= 1;
									index <= 0;
									ocollision <= collision;
								end
							else
								begin
									index <= index + 1;
									state <= WaitDataStream;
								end
						end
				end
			endcase
	end
end

assign Waiting = (state == WaitForInterrupt);
assign DataRequest = (state == Fetch) && !CacheEnough;
assign HashOccurrAddr = TempIndex;

endmodule
