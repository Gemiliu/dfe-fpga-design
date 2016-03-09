`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:29:30 01/05/2016 
// Design Name: 
// Module Name:    Hash 
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
module HashCore(
	input clk_200,
	input clk,
	input rst,
	
	input en,
	input cont,
	input interrupt,
	input transfered,
	output Waiting,
	output complete,
		
	output DataRequest,	
	input CacheEnough,
	
	output [NUM_STATE_WIDTH_BIT-1:0] state,
	output [LENGTH_ARRAY_WIDTH_BIT-1:0] index,
	input [DATA_INDEX_WIDTH-1:0] DataStream,
	
	input [NUM_STATE_WIDTH_BIT-1:0] previous_state,
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] previous_index,
	input [DATA_INDEX_WIDTH-1:0] previous_collision,
	
	output [NUM_STATE_WIDTH_BIT-1:0] ostate,
	output [LENGTH_ARRAY_WIDTH_BIT-1:0] oindex,
	output [DATA_INDEX_WIDTH-1:0] ocollision,
	
	output [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] HashOccurrAddr,
	input [DATA_INDEX_WIDTH-1:0] HashValue,
	input [DATA_INDEX_WIDTH-1:0] OccurrValue,
	
	output WrEn,
	output [DATA_INDEX_WIDTH-1:0] NewHashValue,
	output [DATA_INDEX_WIDTH-1:0] NewOccurrValue
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
localparam integer NUM_STATE = 6;

function [31:0] log2;
	input [31:0] value;
	integer l;
	begin
		log2 = 0;
		for (l = 0; (1<<l) < value; l = l + 1)
			log2 = l+1;
	end
endfunction

NormalHash
#(
	.LENGTH_ARRAY(LENGTH_ARRAY),
	.NUM_PROCESSOR(NUM_PROCESSOR),
	.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
	.BIT_ON_TAILS(BIT_ON_TAILS)
)
NormalHash_inst
(
	.clk_200(clk_200),
	.clk(clk),
	.rst(rst),
	
	.en(en),
	.cont(cont),
	.interrupt(interrupt),
	.transfered(transfered),
	.Waiting(Waiting),
	.complete(complete),
		
	.DataRequest(DataRequest),	
	.CacheEnough(CacheEnough),
	
	.state(state),
	.index(index),
	.DataStream(DataStream),
	
	.previous_state(previous_state),
	.previous_index(previous_index),
	.previous_collision(previous_collision),
	
	.ostate(ostate),
	.oindex(oindex),
	.ocollision(ocollision),
	
	.HashOccurrAddr(HashOccurrAddr),
	.HashValue(HashValue),
	.OccurrValue(OccurrValue),
	
	.WrEn(WrEn),
	.NewHashValue(NewHashValue),
	.NewOccurrValue(NewOccurrValue)
   );
	
//ClamHash
//#(
//	.LENGTH_ARRAY(LENGTH_ARRAY),
//	.NUM_PROCESSOR(NUM_PROCESSOR),
//	.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
//	.BIT_ON_TAILS(BIT_ON_TAILS)
//)
//ClamHash_inst
//(
//	.clk_200(clk_200),
//	.clk(clk),
//	.rst(rst),
//	
//	.en(en),
//	.cont(cont),
//	.interrupt(interrupt),
//	.transfered(transfered),
//	.Waiting(Waiting),
//	.complete(complete),
//		
//	.DataRequest(DataRequest),	
//	.CacheEnough(CacheEnough),
//	
//	.state(state),
//	.index(index),
//	.DataStream(DataStream),
//	
//	.previous_state(previous_state),
//	.previous_index(previous_index),
//	.previous_collision(previous_collision),
//	
//	.ostate(ostate),
//	.oindex(oindex),
//	.ocollision(ocollision),
//	
//	.HashOccurrAddr(HashOccurrAddr),
//	.HashValue(HashValue),
//	.OccurrValue(OccurrValue),
//	
//	.WrEn(WrEn),
//	.NewHashValue(NewHashValue),
//	.NewOccurrValue(NewOccurrValue)
//   );


endmodule
