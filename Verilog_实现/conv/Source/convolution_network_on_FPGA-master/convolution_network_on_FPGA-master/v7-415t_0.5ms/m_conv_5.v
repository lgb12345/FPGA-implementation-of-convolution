`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:59:02 03/02/2017 
// Design Name: 
// Module Name:    m_conv_5 
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
module m_conv_5(
   clk_in,
	rst_n,
   map_in,
   k_in,
   map_out,
	wr,
	ready
	);
	
parameter num_kernel = 6'd36;	//ÿ���˵Ĳ�����Ŀ
parameter num_out = 7'd120;	//���1*1 map��Ŀ

input clk_in;
input rst_n;
input signed [15:0] map_in;
input signed [15:0] k_in;
output reg signed [15:0] map_out = 0;
output reg wr = 0;	//��ʾ����һ�����
output reg ready = 1;	//��Ϊ��һģ��ĵ͸�λ

reg signed [31:0] conv_tmp = 0;
reg signed [19:0] map_out_tmp = 0;
wire signed [31:0] mult_tmp;

//ͨ���ӳ����ɺ��ʵĿ����߼����˷��������Ҫ�������ڣ������Ҫ�ʵ�����
reg rst_tmp = 1;
reg rst_tmp2 = 1;
reg rst_tmp3 = 1;
reg rst_tmp4 = 1;
reg rst_tmp5 = 1;

reg [6:0] k_cnt = 0;
reg [12:0] out_cnt = 0;

always @ (posedge clk_in)
begin
	if (rst_tmp3 && rst_tmp5)	//�ӳٵ�Ӱ�죬��Ҫ�ʵ��޸�һ�¸�λ�ź� 
	begin
		map_out_tmp <= 0;
		conv_tmp <= 0;
		k_cnt <= 0;
		out_cnt <= out_cnt;	
		wr <= 0;
	end
	else 
	begin
		if (k_cnt == num_kernel)
		begin
			if (conv_tmp[11])	//�����ƴ��������ע����������
				map_out_tmp <= (conv_tmp >> 12) + 1;
			else
				map_out_tmp <= conv_tmp >> 12;
			conv_tmp <= mult_tmp;
			k_cnt <= 1;	
			out_cnt <= out_cnt + 1;
			wr <= 1;
		end
		else
		begin
			map_out_tmp <= map_out_tmp;
			conv_tmp <= conv_tmp + mult_tmp;
			k_cnt <= k_cnt + 1;
			out_cnt <= out_cnt;
			wr <= 0;
		end
	end
end

always @ (posedge clk_in)
begin
	rst_tmp <= rst_n;
	rst_tmp2 <= rst_tmp;
	rst_tmp3 <= rst_tmp2;
	rst_tmp4 <= rst_tmp3;
	rst_tmp5 <= rst_tmp4;
end

always @ (posedge clk_in)
begin
	if (rst_tmp3 && rst_tmp5) 
		map_out <= map_out;
	else 
	begin
		if (map_out_tmp <= -20'sd32768)
			map_out <= -16'sd32768;
		else if (map_out_tmp >= 20'sd32767)
			map_out <= 16'sd32767;
		else
			map_out <= map_out_tmp[15:0];
	end
end

always @ (posedge clk_in)
begin
	if ((out_cnt == num_out) && rst_tmp5)
		ready <= 0;
	else
		ready <= 1;
end	

mult_16 u1(.clk(clk_in),.ce(~(rst_n && rst_tmp3)),.p(mult_tmp),.a(map_in),.b(k_in));		

endmodule

