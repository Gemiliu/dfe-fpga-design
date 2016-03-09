`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:42:24 11/15/2015 
// Design Name: 
// Module Name:    MemoryController 
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
module MemoryController(
	input clk,
	input rst,

	input DataRequest,
	output CacheEnough,
	
    output [31:0] br_memory_addr,
    output br_memory_clk,
    output [31:0] br_memory_din,
    input [31:0] br_memory_dout,
    output br_memory_en,
    output br_memory_rst,
    output [3:0] br_memory_we,
	
	output reg WrInitStreamData,
	output reg [LENGTH_ARRAY_WIDTH_BIT-1:0] AddrInitStreamData,
	output [DATA_INDEX_WIDTH-1:0] InitStreamData,
	
	output reg WrInitHash,
	output reg [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] AddrInitHashOccurr
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

reg [31:0] addr;

always @(posedge clk)
begin
	if (rst)
		begin
			WrInitStreamData <= 0;
			AddrInitStreamData <= 0;
			addr <= 0;
		end
	else
		begin
			if (DataRequest)
				begin
					if (AddrInitStreamData < LENGTH_ARRAY)
						begin
							WrInitStreamData <= 1;
							AddrInitStreamData <= AddrInitStreamData + 1;
							addr <= addr + 1;
						end
					else
						begin
							WrInitStreamData <= 0;
						end
				end
			else
				begin
				    AddrInitStreamData <= 0;
					WrInitStreamData <= 0;
				end
		end
end



always @(posedge clk)
begin
	if (rst)
		begin
			WrInitHash <= 0;
			
			AddrInitHashOccurr <= 0;
		end
	else
		begin
			if (DataRequest)
				begin
					if (AddrInitHashOccurr < LENGTH_HASH_ARRAY)
						begin
							WrInitHash <= 1;
							AddrInitHashOccurr <= AddrInitHashOccurr + 1;
						end
					else
						begin
							WrInitHash <= 0;
						end
				end
			else
				begin
					WrInitHash <= 0;
					AddrInitHashOccurr <= 0;
				end


		end
end

assign CacheEnough = (AddrInitHashOccurr == LENGTH_HASH_ARRAY);

//Block RAM Controller//
assign br_memory_addr = addr << 2;
assign br_memory_clk = clk;
assign br_memory_din = 0;
assign br_memory_en = 1;
assign br_memory_rst = 0;
assign br_memory_we = 0;
assign InitStreamData = br_memory_dout;

endmodule
