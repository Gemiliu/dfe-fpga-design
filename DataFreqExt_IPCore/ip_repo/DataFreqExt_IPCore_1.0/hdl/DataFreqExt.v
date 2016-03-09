//////////////////////////////////////////////////////////////////////////////////
module DataFreqExt(
	input clk_200,
	input clk,
	input rst,
	
	input [9:0] NumBlock,
	output reg [31:0] timer,
	
	input DFEenable,
	output reg DFEcomplete,
	
	output reg [31:0] br_NormHash_addr,
    output br_NormHash_clk,
    output reg [31:0] br_NormHash_din,
    input [31:0] br_NormHash_dout,
    output br_NormHash_en,
    output br_NormHash_rst,
    output reg [3:0] br_NormHash_we,
    
	output reg [31:0] br_NormOccurr_addr,
    output br_NormOccurr_clk,
    output reg [31:0] br_NormOccurr_din,
    input [31:0] br_NormOccurr_dout,
    output br_NormOccurr_en,
    output br_NormOccurr_rst,
    output reg [3:0] br_NormOccurr_we,
    
    output reg [31:0] br_NormCollision_addr,
    output br_NormCollision_clk,
    output reg [31:0] br_NormCollision_din,
    input [31:0] br_NormCollision_dout,
    output br_NormCollision_en,
    output br_NormCollision_rst,
    output reg [3:0] br_NormCollision_we,
    
	output reg [31:0] br_ClamHash_addr,
    output br_ClamHash_clk,
    output reg [31:0] br_ClamHash_din,
    input [31:0] br_ClamHash_dout,
    output br_ClamHash_en,
    output br_ClamHash_rst,
    output reg [3:0] br_ClamHash_we,
    
    output reg [31:0] br_ClamOccurr_addr,
    output br_ClamOccurr_clk,
    output reg [31:0] br_ClamOccurr_din,
    input [31:0] br_ClamOccurr_dout,
    output br_ClamOccurr_en,
    output br_ClamOccurr_rst,
    output reg [3:0] br_ClamOccurr_we,
    
    output reg [31:0] br_ClamCollision_addr,
    output br_ClamCollision_clk,
    output reg [31:0] br_ClamCollision_din,
    input [31:0] br_ClamCollision_dout,
    output br_ClamCollision_en,
    output br_ClamCollision_rst,
    output reg [3:0] br_ClamCollision_we
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


////////////////////////////////////////////////
//Declear reg/wire
genvar i;
wire cont[0:NUM_PROCESSOR-1];

wire Normen[0:NUM_PROCESSOR-1];
wire Normcont[0:NUM_PROCESSOR-1];
wire Norminterrupt[0:NUM_PROCESSOR-1];
wire NormWaiting[0:NUM_PROCESSOR-1];
wire Normtransfered[0:NUM_PROCESSOR-1];
wire Normcomplete[0:NUM_PROCESSOR-1];

wire DataRequest[0:NUM_PROCESSOR];
wire CacheEnough[0:NUM_PROCESSOR];

wire [NUM_STATE_WIDTH_BIT-1:0] Normstate[0:NUM_PROCESSOR-1];
wire [LENGTH_ARRAY_WIDTH_BIT-1:0] Normindex[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] NormDataStream[0:NUM_PROCESSOR-1];

wire [NUM_STATE_WIDTH_BIT-1:0] Normprevious_state[0:NUM_PROCESSOR-1];
wire [LENGTH_ARRAY_WIDTH_BIT-1:0] Normprevious_index[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] Normprevious_collision[0:NUM_PROCESSOR-1];

wire [NUM_STATE_WIDTH_BIT-1:0] Normostate[0:NUM_PROCESSOR-1];
wire [LENGTH_ARRAY_WIDTH_BIT-1:0] Normoindex[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] Normocollision[0:NUM_PROCESSOR-1];

wire [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] NormHashOccurrAddr[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] NormHashValue[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] NormOccurrValue[0:NUM_PROCESSOR-1];

wire NormWrEn[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] NormNewHashValue[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] NormNewOccurrValue[0:NUM_PROCESSOR-1];

wire NormWrStreamDataNext[0:NUM_PROCESSOR-1];
wire [LENGTH_ARRAY_WIDTH_BIT-1:0] NormAddrStreamDataNext[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] NormStreamDataNext[0:NUM_PROCESSOR-1];
	
wire NormWrHashNext[0:NUM_PROCESSOR-1];
wire [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] NormAddrHashOccurrNext[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH*2-1:0] NormHashOccurrNext[0:NUM_PROCESSOR-1];

wire Clamen[0:NUM_PROCESSOR-1];
wire Clamcont[0:NUM_PROCESSOR-1];
wire Claminterrupt[0:NUM_PROCESSOR-1];
wire ClamWaiting[0:NUM_PROCESSOR-1];
wire Clamtransfered[0:NUM_PROCESSOR-1];
wire Clamcomplete[0:NUM_PROCESSOR-1];

wire [NUM_STATE_WIDTH_BIT-1:0] Clamstate[0:NUM_PROCESSOR-1];
wire [LENGTH_ARRAY_WIDTH_BIT-1:0] Clamindex[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] ClamDataStream[0:NUM_PROCESSOR-1];

wire [NUM_STATE_WIDTH_BIT-1:0] Clamprevious_state[0:NUM_PROCESSOR-1];
wire [LENGTH_ARRAY_WIDTH_BIT-1:0] Clamprevious_index[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] Clamprevious_collision[0:NUM_PROCESSOR-1];

wire [NUM_STATE_WIDTH_BIT-1:0] Clamostate[0:NUM_PROCESSOR-1];
wire [LENGTH_ARRAY_WIDTH_BIT-1:0] Clamoindex[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] Clamocollision[0:NUM_PROCESSOR-1];

wire [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] ClamHashOccurrAddr[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] ClamHashValue[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] ClamOccurrValue[0:NUM_PROCESSOR-1];

wire ClamWrEn[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] ClamNewHashValue[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] ClamNewOccurrValue[0:NUM_PROCESSOR-1];

wire ClamWrStreamDataNext[0:NUM_PROCESSOR-1];
wire [LENGTH_ARRAY_WIDTH_BIT-1:0] ClamAddrStreamDataNext[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH-1:0] ClamStreamDataNext[0:NUM_PROCESSOR-1];
	
wire ClamWrHashNext[0:NUM_PROCESSOR-1];
wire [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] ClamAddrHashOccurrNext[0:NUM_PROCESSOR-1];
wire [DATA_INDEX_WIDTH*2-1:0] ClamHashOccurrNext[0:NUM_PROCESSOR-1];

wire WrInitStreamData;
wire [LENGTH_ARRAY_WIDTH_BIT-1:0] AddrInitStreamData;
wire [DATA_INDEX_WIDTH-1:0] InitStreamData;
	
wire WrInitHash;
wire [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] AddrInitHashOccurr;
wire [DATA_INDEX_WIDTH*2-1:0] InitHashOccurr;

////////////////////////////////////////////////
//Hash Core instance
for(i=0;i<NUM_PROCESSOR;i=i+1)
begin
	if (i == 0)
		begin
			assign Normprevious_state[i] = 0;
			assign Normprevious_index[i] = 0;
			assign Normprevious_collision[i] = 0;
		end
	else
		begin
			assign Normprevious_state[i] = Normostate[i-1];
			assign Normprevious_index[i] = Normoindex[i-1];
			assign Normprevious_collision[i] = Normocollision[i-1];
		end
end

for(i=0;i<NUM_PROCESSOR;i=i+1)
begin
	if (i == 0)
		begin
			assign Clamprevious_state[i] = 0;
			assign Clamprevious_index[i] = 0;
			assign Clamprevious_collision[i] = 0;
		end
	else
		begin
			assign Clamprevious_state[i] = Clamostate[i-1];
			assign Clamprevious_index[i] = Clamoindex[i-1];
			assign Clamprevious_collision[i] = Clamocollision[i-1];
		end
end

for(i=0;i<NUM_PROCESSOR;i=i+1)
begin
	assign Normcont[i] = cont[i];
	assign Clamcont[i] = cont[i];
end

for(i=0;i<NUM_PROCESSOR;i=i+1)
begin
	if (i == 0)
		NormalHash 
		#(
			.LENGTH_ARRAY(LENGTH_ARRAY),
			.NUM_PROCESSOR(NUM_PROCESSOR),
			.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
			.BIT_ON_TAILS(BIT_ON_TAILS)
		) 
		NormHash_inst(
			.clk_200(clk_200),
			.clk(clk),
			.rst(rst),

			.en(Normen[i]),
			.cont(Normcont[i]),
			.interrupt(Norminterrupt[i]),
			.transfered(Normtransfered[i]),
			.Waiting(NormWaiting[i]),
			.complete(Normcomplete[i]),

			.DataRequest(DataRequest[i]),	
			.CacheEnough(CacheEnough[i]),

			.state(Normstate[i]),
			.index(Normindex[i]),
			.DataStream(NormDataStream[i]),

			.previous_state(Normprevious_state[i]),
			.previous_index(Normprevious_index[i]),
			.previous_collision(Normprevious_collision[i]),

			.ostate(Normostate[i]),
			.oindex(Normoindex[i]),
			.ocollision(Normocollision[i]),

			.HashOccurrAddr(NormHashOccurrAddr[i]),
			.HashValue(NormHashValue[i]),
			.OccurrValue(NormOccurrValue[i]),

			.WrEn(NormWrEn[i]),
			.NewHashValue(NormNewHashValue[i]),
			.NewOccurrValue(NormNewOccurrValue[i])
		);
	else
		NormalHash 
		#(
			.LENGTH_ARRAY(LENGTH_ARRAY),
			.NUM_PROCESSOR(NUM_PROCESSOR),
			.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
			.BIT_ON_TAILS(BIT_ON_TAILS)
		) 
		NormHash_inst(
			.clk_200(clk_200),
			.clk(clk),
			.rst(rst),

			.en(Normen[i]),
			.cont(Normcont[i]),
			.interrupt(Norminterrupt[i]),
			.transfered(Normtransfered[i]),
			.Waiting(NormWaiting[i]),
			.complete(Normcomplete[i]),

			.DataRequest(DataRequest[i]),	
			.CacheEnough(CacheEnough[i]),

			.state(Normstate[i]),
			.index(Normindex[i]),
			.DataStream(NormDataStream[i]),

			.previous_state(Normprevious_state[i]),
			.previous_index(Normprevious_index[i]),
			.previous_collision(Normprevious_collision[i]),

			.ostate(Normostate[i]),
			.oindex(Normoindex[i]),
			.ocollision(Normocollision[i]),

			.HashOccurrAddr(NormHashOccurrAddr[i]),
			.HashValue(NormHashValue[i]),
			.OccurrValue(NormOccurrValue[i]),

			.WrEn(NormWrEn[i]),
			.NewHashValue(NormNewHashValue[i]),
			.NewOccurrValue(NormNewOccurrValue[i])
		);		
end

for(i=0;i<NUM_PROCESSOR;i=i+1)
begin
	if (i == 0)
		ClamHash 
		#(
			.LENGTH_ARRAY(LENGTH_ARRAY),
			.NUM_PROCESSOR(NUM_PROCESSOR),
			.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
			.BIT_ON_TAILS(BIT_ON_TAILS)
		) 
		ClamHash_inst(
			.clk_200(clk_200),
			.clk(clk),
			.rst(rst),

			.en(Clamen[i]),
			.cont(Clamcont[i]),
			.interrupt(Claminterrupt[i]),
			.transfered(Clamtransfered[i]),
			.Waiting(ClamWaiting[i]),
			.complete(Clamcomplete[i]),

			.DataRequest(),	
			.CacheEnough(CacheEnough[i]),

			.state(Clamstate[i]),
			.index(Clamindex[i]),
			.DataStream(ClamDataStream[i]),

			.previous_state(Clamprevious_state[i]),
			.previous_index(Clamprevious_index[i]),
			.previous_collision(Clamprevious_collision[i]),

			.ostate(Clamostate[i]),
			.oindex(Clamoindex[i]),
			.ocollision(Clamocollision[i]),

			.HashOccurrAddr(ClamHashOccurrAddr[i]),
			.HashValue(ClamHashValue[i]),
			.OccurrValue(ClamOccurrValue[i]),

			.WrEn(ClamWrEn[i]),
			.NewHashValue(ClamNewHashValue[i]),
			.NewOccurrValue(ClamNewOccurrValue[i])
		);
	else
		ClamHash 
		#(
			.LENGTH_ARRAY(LENGTH_ARRAY),
			.NUM_PROCESSOR(NUM_PROCESSOR),
			.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
			.BIT_ON_TAILS(BIT_ON_TAILS)
		) 
		ClamHash_inst(
			.clk_200(clk_200),
			.clk(clk),
			.rst(rst),

			.en(Clamen[i]),
			.cont(Clamcont[i]),
			.interrupt(Claminterrupt[i]),
			.transfered(Clamtransfered[i]),
			.Waiting(ClamWaiting[i]),
			.complete(Clamcomplete[i]),

			.DataRequest(),	
			.CacheEnough(CacheEnough[i]),

			.state(Clamstate[i]),
			.index(Clamindex[i]),
			.DataStream(ClamDataStream[i]),

			.previous_state(Clamprevious_state[i]),
			.previous_index(Clamprevious_index[i]),
			.previous_collision(Clamprevious_collision[i]),

			.ostate(Clamostate[i]),
			.oindex(Clamoindex[i]),
			.ocollision(Clamocollision[i]),

			.HashOccurrAddr(ClamHashOccurrAddr[i]),
			.HashValue(ClamHashValue[i]),
			.OccurrValue(ClamOccurrValue[i]),

			.WrEn(ClamWrEn[i]),
			.NewHashValue(ClamNewHashValue[i]),
			.NewOccurrValue(ClamNewOccurrValue[i])
		);		
end

assign Normen[0] = DFEenable;
assign Clamen[0] = DFEenable;

///////////////////////////////////////////////
//Cache instance 
for(i=0;i<NUM_PROCESSOR;i=i+1)
begin
	if (i == 0)
		Cache 
			#(
				.LENGTH_ARRAY(LENGTH_ARRAY),
				.NUM_PROCESSOR(NUM_PROCESSOR),
				.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
				.BIT_ON_TAILS(BIT_ON_TAILS)
			)
		NormCache_inst(
				.clk(clk),
				.rst(rst),

				.index(Normindex[i]),
				.DataStream(NormDataStream[i]),

				.HashOccurrAddr(NormHashOccurrAddr[i]),
				.HashValue(NormHashValue[i]),
				.OccurrValue(NormOccurrValue[i]),

				.WrEn(NormWrEn[i]),
				.NewHashValue(NormNewHashValue[i]),
				.NewOccurrValue(NormNewOccurrValue[i]),

				//Communicative side with Memory Controller
				.WrInitStreamData(WrInitStreamData),
				.AddrInitStreamData(AddrInitStreamData),
				.InitStreamData(InitStreamData),

				.WrInitHash(WrInitHash),
				.AddrInitHashOccurr(AddrInitHashOccurr),
				.InitHashOccurr(InitHashOccurr),

				//Communicative side with next processor
				.DataRequest(DataRequest[i+1]),
				.CacheEnough(CacheEnough[i+1]),
				
				.WrStreamDataNext(NormWrStreamDataNext[i]),
				.AddrStreamDataNext(NormAddrStreamDataNext[i]),
				.StreamDataNext(NormStreamDataNext[i]),
				
				.WrHashNext(NormWrHashNext[i]),
				.AddrHashOccurrNext(NormAddrHashOccurrNext[i]),
				.HashOccurrNext(NormHashOccurrNext[i])
			 );
	else
		Cache 
			#(
				.LENGTH_ARRAY(LENGTH_ARRAY),
				.NUM_PROCESSOR(NUM_PROCESSOR),
				.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
				.BIT_ON_TAILS(BIT_ON_TAILS)
			)
		NormCache_inst(
				.clk(clk),
				.rst(rst),

				.index(Normindex[i]),
				.DataStream(NormDataStream[i]),

				.HashOccurrAddr(NormHashOccurrAddr[i]),
				.HashValue(NormHashValue[i]),
				.OccurrValue(NormOccurrValue[i]),

				.WrEn(NormWrEn[i]),
				.NewHashValue(NormNewHashValue[i]),
				.NewOccurrValue(NormNewOccurrValue[i]),

				//Communicative side with next processor
				.DataRequest(DataRequest[i+1]),
				.CacheEnough(CacheEnough[i+1]),

				.WrStreamDataNext(NormWrStreamDataNext[i]),
				.AddrStreamDataNext(NormAddrStreamDataNext[i]),
				.StreamDataNext(NormStreamDataNext[i]),

				.WrHashNext(NormWrHashNext[i]),
				.AddrHashOccurrNext(NormAddrHashOccurrNext[i]),
				.HashOccurrNext(NormHashOccurrNext[i]),

				.WrStreamData(NormWrStreamDataNext[i-1]),
				.AddrStreamData(NormAddrStreamDataNext[i-1]),
				.StreamData(NormStreamDataNext[i-1]),

				.WrHash(NormWrHashNext[i-1]),
				.AddrHashOccurr(NormAddrHashOccurrNext[i-1]),
				.HashOccurr(NormHashOccurrNext[i-1])
			 );
end


for(i=0;i<NUM_PROCESSOR;i=i+1)
begin
	if (i == 0)
		Cache 
			#(
				.LENGTH_ARRAY(LENGTH_ARRAY),
				.NUM_PROCESSOR(NUM_PROCESSOR),
				.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
				.BIT_ON_TAILS(BIT_ON_TAILS)
			)
		ClamCache_inst(
				.clk(clk),
				.rst(rst),

				.index(Clamindex[i]),
				.DataStream(ClamDataStream[i]),

				.HashOccurrAddr(ClamHashOccurrAddr[i]),
				.HashValue(ClamHashValue[i]),
				.OccurrValue(ClamOccurrValue[i]),

				.WrEn(ClamWrEn[i]),
				.NewHashValue(ClamNewHashValue[i]),
				.NewOccurrValue(ClamNewOccurrValue[i]),

				//Communicative side with Memory Controller
				.WrInitStreamData(WrInitStreamData),
				.AddrInitStreamData(AddrInitStreamData),
				.InitStreamData(InitStreamData),

				.WrInitHash(WrInitHash),
				.AddrInitHashOccurr(AddrInitHashOccurr),
				.InitHashOccurr(InitHashOccurr),

				//Communicative side with next processor
				.DataRequest(DataRequest[i+1]),
				.CacheEnough(),
				
				.WrStreamDataNext(ClamWrStreamDataNext[i]),
				.AddrStreamDataNext(ClamAddrStreamDataNext[i]),
				.StreamDataNext(ClamStreamDataNext[i]),
				
				.WrHashNext(ClamWrHashNext[i]),
				.AddrHashOccurrNext(ClamAddrHashOccurrNext[i]),
				.HashOccurrNext(ClamHashOccurrNext[i])
			 );
	else
		Cache 
			#(
				.LENGTH_ARRAY(LENGTH_ARRAY),
				.NUM_PROCESSOR(NUM_PROCESSOR),
				.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
				.BIT_ON_TAILS(BIT_ON_TAILS)
			)
		ClamCache_inst(
				.clk(clk),
				.rst(rst),

				.index(Clamindex[i]),
				.DataStream(ClamDataStream[i]),

				.HashOccurrAddr(ClamHashOccurrAddr[i]),
				.HashValue(ClamHashValue[i]),
				.OccurrValue(ClamOccurrValue[i]),

				.WrEn(ClamWrEn[i]),
				.NewHashValue(ClamNewHashValue[i]),
				.NewOccurrValue(ClamNewOccurrValue[i]),

				//Communicative side with next processor
				.DataRequest(DataRequest[i+1]),
				.CacheEnough(),

				.WrStreamDataNext(ClamWrStreamDataNext[i]),
				.AddrStreamDataNext(ClamAddrStreamDataNext[i]),
				.StreamDataNext(ClamStreamDataNext[i]),

				.WrHashNext(ClamWrHashNext[i]),
				.AddrHashOccurrNext(ClamAddrHashOccurrNext[i]),
				.HashOccurrNext(ClamHashOccurrNext[i]),

				.WrStreamData(ClamWrStreamDataNext[i-1]),
				.AddrStreamData(ClamAddrStreamDataNext[i-1]),
				.StreamData(ClamStreamDataNext[i-1]),

				.WrHash(ClamWrHashNext[i-1]),
				.AddrHashOccurr(ClamAddrHashOccurrNext[i-1]),
				.HashOccurr(ClamHashOccurrNext[i-1])
			 );
end
//////////////////////////////////////////////
//Memory Controller	 
MemoryController
#(
	.LENGTH_ARRAY(LENGTH_ARRAY),
	.NUM_PROCESSOR(NUM_PROCESSOR),
	.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
	.BIT_ON_TAILS(BIT_ON_TAILS)
)
MemoryController_inst(
	.clk(clk),
	.rst(rst),

	.DataRequest(DataRequest[0]),
	.CacheEnough(CacheEnough[0]),
	
	.WrInitStreamData(WrInitStreamData),
	.AddrInitStreamData(AddrInitStreamData),
	.InitStreamData(InitStreamData),

	.WrInitHash(WrInitHash),
	.AddrInitHashOccurr(AddrInitHashOccurr),
	.InitHashOccurr(InitHashOccurr)
    );

//////////////////////////////////////////////
//Cross Bar Switch	 
CrossBarSwitch
#(
	.LENGTH_ARRAY(LENGTH_ARRAY),
	.NUM_PROCESSOR(NUM_PROCESSOR),
	.DATA_INDEX_WIDTH(DATA_INDEX_WIDTH),
	.BIT_ON_TAILS(BIT_ON_TAILS)
)
CrossBarSwitch_inst(
	.clk(clk),
	.rst(rst),

	.Normstate0(Normstate[0]),
	.Normindex0(Normindex[0]),

	.Normstate1(Normstate[1]),
	.Normindex1(Normindex[1]),
	
	.Norminterrupt0(Norminterrupt[0]),
	.Norminterrupt1(Norminterrupt[1]),
	.Norminterrupt2(Norminterrupt[2]),
	
	.NormWaiting0(NormWaiting[0]),
	.NormWaiting1(NormWaiting[1]),
	.NormWaiting2(NormWaiting[2]),
	
	.cont0(cont[0]),
	.cont1(cont[1]),
	.cont2(cont[2]),
	
	.Normtransfered0(Normtransfered[0]),
	.Normtransfered1(Normtransfered[1]),
	.Normtransfered2(Normtransfered[2]),
	
	.Clamstate0(Clamstate[0]),
	.Clamindex0(Clamindex[0]),

	.Clamstate1(Clamstate[1]),
	.Clamindex1(Clamindex[1]),
	
	.Claminterrupt0(Claminterrupt[0]),
	.Claminterrupt1(Claminterrupt[1]),
	.Claminterrupt2(Claminterrupt[2]),
	
	.ClamWaiting0(ClamWaiting[0]),
	.ClamWaiting1(ClamWaiting[1]),
	.ClamWaiting2(ClamWaiting[2]),
	
	.Clamtransfered0(Clamtransfered[0]),
	.Clamtransfered1(Clamtransfered[1]),
	.Clamtransfered2(Clamtransfered[2])
    );
//////////////Write Result//////////////
always @(posedge clk)
begin
    if (rst)
        begin
            br_NormCollision_addr <= 32'hfffffffc;
        end
    else
        begin
            if (Normcomplete[0])
                begin
                    br_NormCollision_addr <= br_NormCollision_addr + 4;
                    br_NormCollision_we <= 1;
                    br_NormCollision_din <= Normocollision[2];
                end
            else
                begin
                    br_NormCollision_we <= 0;
                end
        end
end
assign br_NormCollision_clk = clk;
assign br_NormCollision_en = 1;
assign br_NormCollision_rst = 0;

always @(posedge clk)
begin
    if (rst)
        begin
            br_ClamCollision_addr <= 32'hfffffffc;
        end
    else
        begin
            if (Clamcomplete[0])
                begin
                    br_ClamCollision_addr <= br_ClamCollision_addr + 4;
                    br_ClamCollision_we <= 1;
                    br_ClamCollision_din <= Clamocollision[2];
                end
            else
                begin
                    br_ClamCollision_we <= 0;
                end
        end
end
assign br_ClamCollision_clk = clk;
assign br_ClamCollision_en = 1;
assign br_ClamCollision_rst = 0;

//////////////////////////////////
//Control number of array 
reg [31:0] SortedArray;
always @(posedge clk)
begin
	if (rst)
		begin
			SortedArray <= 0;
		
			DFEcomplete <= 0;
		end
	else
		begin
			if (Clamcomplete[0])
				SortedArray <= SortedArray + 1;
			if (SortedArray == 1)
				DFEcomplete <= 1;
		end
end


////////Timer Calculation/////////
reg DFEenable_buf;
reg DFEcomplete_buf;
always @(posedge clk)
begin
	if (rst)
		begin
			timer <= 0;
			DFEenable_buf <= 0;
			DFEcomplete_buf <= 0;
		end
	else
		begin
		    if (DFEenable) 
		       DFEenable_buf <= 1;
		    if (DFEcomplete)
		       DFEcomplete_buf <= 1;
			if (DFEenable_buf && !DFEcomplete_buf)
				timer <= timer + 1;
		end
end
		
endmodule
