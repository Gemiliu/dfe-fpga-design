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
	input clk_200,
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
localparam integer NUM_STATE = 7;

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
localparam FirstTempIndex = 3;
localparam RdHashOccurr = 4;
localparam CollisionCal = 5;
localparam HashBuild = 6;

wire [DATA_INDEX_WIDTH-1:0] reminder;
wire [DATA_INDEX_WIDTH-1:0] NxtModulus;

reg [DATA_INDEX_WIDTH-1:0] TempIndex;

IncModulus 
#(
	.LENGTH_ARRAY(LENGTH_ARRAY),
	.NUM_PROCESSOR(NUM_PROCESSOR),
	.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
	.BIT_ON_TAILS(BIT_ON_TAILS)
) 
IncModulus_inst(
	.PreModulus(reminder),
	.NxtModulus(NxtModulus)
);

Modulus Modulus_inst(
	.clk(clk_200),
	.en(1'b1),
	
	.dividend(TempIndex),
	.divisor(1 << BIT_ON_TAILS),
	
	.reminder(reminder)
    );

always @(posedge clk)
begin
	if (rst) 
		begin
			state <= Wait;
		end
	else
		begin
			case(state)
			Wait:
				begin
					complete <= 0;
					ocollision <= 0;
					WrEn <= 0;
					if (en || cont) 
						begin							
							state <= Fetch;
						end
				end
			WaitForInterrupt:
				begin
					complete <= 0;
					ocollision <= 0;
					WrEn <= 0;
					if (cont)
						state <= Fetch;
				end
			Fetch: 
				begin
					if (CacheEnough)
						if (transfered)
							begin
								state <= FirstTempIndex;
								index <= previous_index;
								ocollision <= previous_collision;
							end
						else
							begin
								state <= FirstTempIndex;
								index <= 0;
								ocollision <= 0;
							end
				end
			FirstTempIndex:
				begin
					TempIndex <= DataStream & MASK;
					WrEn <= 0;
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
							ocollision <= ocollision + 1;
							TempIndex <= NxtModulus;
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
							ostate <= FirstTempIndex;
							oindex <= index + 1;
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
								end
							else
								begin
									index <= index + 1;
									state <= FirstTempIndex;
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
