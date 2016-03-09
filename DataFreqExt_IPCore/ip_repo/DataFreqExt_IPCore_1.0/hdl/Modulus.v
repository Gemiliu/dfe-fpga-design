`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:31:51 01/06/2016 
// Design Name: 
// Module Name:    Modulus 
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
module Modulus(
	input clk,
	input en,
	
	input [31:0] dividend,
	input [31:0] divisor,
	
	output reg [31:0] reminder
    );
	 
wire [31:0] quotient;
wire [31:0] reminder_buf;

DIV DIV_inst (
	.rfd(), 
	.rdy(done), 
	.nd(en), 
	.clk(clk), 
	.dividend(dividend), 
	.quotient(quotient), 
	.divisor(divisor)
);

wire [63:0] p;

MUL MUL_inst (
	.a(quotient), 
	.b(divisor), 
	.p(p)
);

assign reminder_buf = (p > {32'b0,dividend}) ? ({32'b0,dividend}+divisor-p) : {32'b0,dividend} - p;

always @(posedge clk)
begin
	if (done)
		reminder <= reminder_buf;
end



endmodule

module DIV (
  output rfd,
  output rdy,
  input nd,
  input clk,
  input [31 : 0] dividend,
  output [31 : 0] quotient,
  input [31 : 0] divisor
)/* synthesis syn_black_box syn_noprune=1 */;
endmodule

module MUL (
    input [31 : 0] a,
    input [31 : 0] b,
    output [63 : 0] p
)/* synthesis syn_black_box syn_noprune=1 */;
endmodule
  
