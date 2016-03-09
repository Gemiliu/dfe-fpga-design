///////////////////////////////////////////////////////
module Cache(
	input clk,
	input rst,
	
	//Communicative side with Hash Core
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] index,
	output reg [DATA_INDEX_WIDTH-1:0] DataStream,
	
	input [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] HashOccurrAddr,
	output reg [DATA_INDEX_WIDTH-1:0] HashValue,
	output reg [DATA_INDEX_WIDTH-1:0] OccurrValue,
	
	input WrEn,
	input [DATA_INDEX_WIDTH-1:0] NewHashValue,
	input [DATA_INDEX_WIDTH-1:0] NewOccurrValue,
	
	//Communicative side with Memory Controller
	input WrInitStreamData,
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] AddrInitStreamData,
	input [DATA_INDEX_WIDTH-1:0] InitStreamData,
	
	input WrInitHash,
	input [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] AddrInitHashOccurr,
	input [DATA_INDEX_WIDTH*2-1:0] InitHashOccurr,
	
	//Communicative side with next processor
	input DataRequest,
	output CacheEnough,
	
	output reg WrStreamDataNext,
	output reg [LENGTH_ARRAY_WIDTH_BIT-1:0] AddrStreamDataNext,
	output reg [DATA_INDEX_WIDTH-1:0] StreamDataNext,
	
	output reg WrHashNext,
	output reg [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] AddrHashOccurrNext,
	output reg [DATA_INDEX_WIDTH*2-1:0] HashOccurrNext,
	
	input WrStreamData,
	input [LENGTH_ARRAY_WIDTH_BIT-1:0] AddrStreamData,
	input [DATA_INDEX_WIDTH-1:0] StreamData,
	
	input WrHash,
	input [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] AddrHashOccurr,
	input [DATA_INDEX_WIDTH*2-1:0] HashOccurr
    );
//Define parameter//
parameter LENGTH_ARRAY = 100;
parameter NUM_PROCESSOR = 3;
parameter DATA_INDEX_WIDTH = 32;
parameter BIT_ON_TAILS = 7;

localparam integer LENGTH_ARRAY_WIDTH_BIT = log2(LENGTH_ARRAY);
localparam integer LENGTH_HASH_ARRAY = 1 << BIT_ON_TAILS;
localparam integer LENGTH_HASH_ARRAY_WIDTH_BIT = log2((1 << BIT_ON_TAILS + 1));
localparam integer MASK = (1 << BIT_ON_TAILS) - 1;

function [31:0] log2;
	input [31:0] value;
	integer l;
	begin
		log2 = 0;
		for (l = 0; (1<<l) < value; l = l + 1)
			log2 = l+1;
	end
endfunction

//Define reg/wire/signal
reg [DATA_INDEX_WIDTH-1:0] DataStreamMemory[0:LENGTH_ARRAY-1];

reg [DATA_INDEX_WIDTH-1:0] HashMemory[0:LENGTH_HASH_ARRAY-1];
reg [DATA_INDEX_WIDTH-1:0] OccurrMemory[0:LENGTH_HASH_ARRAY-1];

always @(posedge clk)
begin	
	if (WrInitStreamData)
		begin
			DataStreamMemory[AddrInitStreamData-1] <= InitStreamData;
		end
	else
	if (WrStreamData)
		begin
			DataStreamMemory[AddrStreamData-1] <= StreamData;
		end
end

always @(posedge clk)
begin	
	if (WrHash)
		begin
			HashMemory[AddrHashOccurr-1] <= HashOccurr[63:32];
			OccurrMemory[AddrHashOccurr-1] <= HashOccurr[31:0];
		end
	else
	if (WrInitHash)
		begin
			HashMemory[AddrInitHashOccurr-1] <= 0;
			OccurrMemory[AddrInitHashOccurr-1] <= 0;
		end
	else
	if (WrEn)
		begin
			HashMemory[HashOccurrAddr] <= NewHashValue;
			OccurrMemory[HashOccurrAddr] <= NewOccurrValue;
		end
end
		
always @(posedge clk)
begin
	if (rst)
		begin
			AddrStreamDataNext <= 0;
			
			WrStreamDataNext <= 0;
		end
	else
	begin
		if (DataRequest)
			begin
				if (AddrStreamDataNext < LENGTH_ARRAY)
					begin
						StreamDataNext <= DataStreamMemory[AddrStreamDataNext];
						AddrStreamDataNext <= AddrStreamDataNext + 1;
						WrStreamDataNext <= 1;
					end
				else
					begin
						WrStreamDataNext <= 0;
					end
			end
		else
			begin
				WrStreamDataNext <= 0;
				AddrStreamDataNext <= 0;
				
				DataStream <= DataStreamMemory[index];
			end
	end
end	


always @(posedge clk)
begin
	if (rst)
		begin
			AddrHashOccurrNext <= 0;
			
			WrHashNext <= 0;
		end
	else
	begin
		if (DataRequest)
			begin
				if (AddrHashOccurrNext < LENGTH_HASH_ARRAY)
					begin
						HashOccurrNext <= {HashMemory[AddrHashOccurrNext],OccurrMemory[AddrHashOccurrNext]};
						AddrHashOccurrNext <= AddrHashOccurrNext + 1;
						WrHashNext <= 1;
					end
				else
					begin
						WrHashNext <= 0;
					end
			end
		else
			begin					
				WrHashNext <= 0;
				AddrHashOccurrNext <= 0;
				HashValue <= HashMemory[HashOccurrAddr];
				OccurrValue <= OccurrMemory[HashOccurrAddr];
			end
		
	end
end	
	
assign CacheEnough = (AddrHashOccurrNext == LENGTH_HASH_ARRAY);
				 
endmodule
