`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:55:32 02/25/2017 
// Design Name: 
// Module Name:    m_layer_input_2 
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
module m_layer_input_2(
   clk_in,
	rst_n,
	map_in,
	wr,
	map_out,
	k_loop,
	k_ready,
	ready
   );
	 
//##��Ҫ��ʵ������޸Ĳ���	 
parameter num_ind = 7'd89;	//������Ŀ��С-1��ͨ��������һ�У��õ�������ַ
parameter max_ind = 7'd109;	//����������������жϿ����߼�
parameter size_in = 5'd22;	//map_in��С
parameter num_in = 9'd483;	//map_in��Ŀ-1
parameter size_kernel = 3'd4;	//����˻�ػ��˵ı߳���С-1,Ҳ�����˷�Ƶϵ��
parameter size_out = 5'd17;	//map_out��С-1

parameter num_loop = 1'd0;	//��Ҫѭ���Ĵ���-1

input clk_in;
input rst_n;	//�͸�λ
input signed [15:0] map_in;	//��1�㣺��������룬��һ����˳����Ҫ���� 
input wr;	//������������ٶȲ�ͬ����Ҫ���浽ram�У���Ϊд���ź�
output signed [15:0] map_out;	//��������� 
output reg k_ready = 0;	//�������˲����������źţ��൱����ǰ��ind_ready_tmp3
output reg ready = 1;	//��Ϊ��һ���ĵ͸�λ

output reg k_loop = 0;	//����һ�β�������ܶ��������Դ���ޣ����ʷֳɼ���ѭ������Ϊһ��ѭ����־
reg [2:0] loop_cnt = 0;	//ѭ���Ĵ�������

//##��Ҫ��ʵ������޸�λ��
reg [8:0] addr_wr = 0;	//ram��ַ
reg [6:0] addr_ind = 0;	//һ��˳��������ĵ�ַ
wire [6:0] ind_out;	//�������
reg [6:0] ind_out_tmp = 0;	//�������棬���ӷ���Ľ��
reg [2:0] ind_cnt = 0;	//�������ӷ��ļ�����
reg [9:0] ind_out_tmp2 = 0;	//�������棬��ƫ�ú�Ľ��
reg [4:0] ind_cnt2 = 0;	//�������˷��ļ�����
wire [9:0] bias;	//��Ҫƫ�õľ���
reg [9:0] addr_rd = 0;	////ram�ĵ�ַ

reg ind_ready = 0;	//��ʾ���ӳ������£�map_out��k���Կ�ʼ���
reg ind_ready_tmp = 0;	//�˷�������������Ҫ�ӳ١���Ϊind_ready���ӳ�
reg ind_ready_tmp2 = 0;

reg [6:0] mult_tmp = 0;	//�˷�������������Ҫ�ӳ٣���ַ����Ļ���
reg [6:0] mult_tmp2 = 0;
reg [6:0] mult_tmp3 = 0;
wire clk_in_div_slow;	//��ʱ�ӣ�����ȡ���ھ���˻�ػ�����Ĵ�С

always @ (posedge clk_in)
begin
	if (~rst_n)
	begin
		addr_wr <= 0;
	end
	else
	begin
		if (wr)
			addr_wr <= addr_wr + 1;	
		else
			addr_wr <= addr_wr;
	end
end

always @ (posedge clk_in_div_slow)	
begin
	if (rst_n) 
		addr_ind <= 0;
	else 
	begin
		if (addr_ind == num_ind)	
			addr_ind <= 0;
		else
			addr_ind <= addr_ind + 1;
	end
end

always @ (posedge clk_in)
begin
	if (rst_n) 
	begin
		ind_cnt <= 0;
		ind_out_tmp <= 0;
		mult_tmp <= 0;
		mult_tmp2 <= 0;
		mult_tmp3 <= 0;
		ind_out_tmp2 <= 0;
		addr_rd <= 0;
	end
	else 
	begin
		if (ind_cnt == size_kernel)
			ind_cnt <= 0;
		else 
			ind_cnt <= ind_cnt + 1;
		ind_out_tmp <= ind_out + ind_cnt;
		mult_tmp <= ind_out_tmp;
		mult_tmp2 <= mult_tmp;
		mult_tmp3 <= mult_tmp2;
		ind_out_tmp2 <= mult_tmp3 + bias;
		addr_rd <= ind_out_tmp2;
	end
end

always @ (posedge clk_in)
begin
	if (rst_n) 
	begin
		ind_cnt2 <= 0;
		loop_cnt <= 0;
		k_loop <= 0;
	end
	else 
	begin
		if (ind_out_tmp == max_ind)
		begin	
			if (ind_cnt2 >= size_out)	//��Ҫƫ�õĴ���
			begin
				if (loop_cnt >= num_loop)
				begin
					ind_cnt2 <= 127;
					loop_cnt <= num_loop+1;
					k_loop <= 0;
				end
				else
				begin
					ind_cnt2 <= 0;
					loop_cnt <= loop_cnt + 1;
					k_loop <= 1;
				end
			end
			else
			begin
				ind_cnt2 <= ind_cnt2 + 1;
				loop_cnt <= loop_cnt;
				k_loop <= 0;
			end
		end
		else
		begin
			ind_cnt2 <= ind_cnt2;
			k_loop <= 0;
		end
	end
end

always @ (posedge clk_in)
begin
	if (rst_n) 
	begin
		ind_ready <= 0;
		ind_ready_tmp <= 0;
		ind_ready_tmp2 <= 0;
		k_ready <= 0;
		ready <= 1;
	end
	else
	begin
		if	(ind_out_tmp || ind_cnt2 || loop_cnt)
			ind_ready <= 1;	
		else
			ind_ready <= 0;
		ind_ready_tmp <= ind_ready;
		ind_ready_tmp2 <= ind_ready_tmp;
		if (ind_out_tmp2 > num_in && loop_cnt > num_loop)	//����rom�������
			k_ready <= 0;
		else
			k_ready <= ind_ready_tmp2;	//����rom�����ʼ
		ready <= ~k_ready;
	end
end
           
clk_div u1(.clk_in(clk_in),.rst_n(rst_n),.n(size_kernel+4'd1),.clk_out(clk_in_div_slow));

bias_mult3 u2(.clk(clk_in),.ce(~rst_n),.p(bias),.a(ind_cnt2));

ind_max_in u3(.clka(clk_in),.ena(~rst_n),.addra(addr_ind),.douta(ind_out));

max_ram u4(.clka(clk_in),.ena(rst_n),.wea(wr),.addra(addr_wr),.dina(map_in),.clkb(clk_in),.enb(k_ready),.addrb(addr_rd),.doutb(map_out));


endmodule
