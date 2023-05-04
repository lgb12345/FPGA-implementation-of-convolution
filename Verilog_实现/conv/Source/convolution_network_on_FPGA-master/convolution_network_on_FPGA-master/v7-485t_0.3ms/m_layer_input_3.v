`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:24:04 02/28/2017 
// Design Name: 
// Module Name:    m_layer_input_3 
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
module m_layer_input_3(
   clk_in,
	rst_n,
	rst_n_tmp,	
	map_in,
	wr,
	map_out,
	ready
   );
	 
//##��Ҫ��ʵ������޸Ĳ���	 
parameter num_ind = 5'd17;	//������Ŀ��С-1��ͨ��������һ�У��õ�������ַ
parameter max_ind = 6'd53;	//����������������жϿ����߼�
parameter size_in = 5'd18;	//map_in��С
parameter num_in = 9'd323;	//map_in��Ŀ-1
parameter size_kernel = 2'd2;	//����˻�ػ��˵ı߳���С-1,Ҳ�����˷�Ƶϵ��
parameter size_out = 3'd5;	//map_out��С-1

input clk_in;
input rst_n;	//�͸�λ�����һ�ζ�
input rst_n_tmp;	//����½��д��
input signed [15:0] map_in;	//��1�㣺��������룬��һ����˳����Ҫ���� 
input wr;	//������������ٶȲ�ͬ����Ҫ���浽ram�У���Ϊд���ź�
output signed [15:0] map_out;	//��������� 
output reg ready = 1;	//��Ϊ��һ���ĵ͸�λ


//##��Ҫ��ʵ������޸�λ��
reg [8:0] addr_wr = 0;	//ram��ַ
reg [4:0] addr_ind = 0;	//һ��˳��������ĵ�ַ
wire [5:0] ind_out;	//�������
reg [5:0] ind_out_tmp = 0;	//�������棬���ӷ���Ľ��
reg [1:0] ind_cnt = 0;	//�������ӷ��ļ�����
reg [8:0] ind_out_tmp2 = 0;	//�������棬��ƫ�ú�Ľ��
reg [2:0] ind_cnt2 = 0;	//�������˷��ļ�����
wire [8:0] bias;	//��Ҫƫ�õľ���
reg [8:0] addr_rd = 0;	////ram�ĵ�ַ

reg ind_ready = 0;	//��ʾ���ӳ������£�map_out��k���Կ�ʼ���
reg ind_ready_tmp = 0;	//�˷�������������Ҫ�ӳ١���Ϊind_ready���ӳ�
reg ind_ready_tmp2 = 0;
reg ind_ready_tmp3 = 0;

reg [5:0] mult_tmp = 0;	//�˷�������������Ҫ�ӳ٣���ַ����Ļ���
reg [5:0] mult_tmp2 = 0;
reg [5:0] mult_tmp3 = 0;
wire clk_in_div_slow;	//��ʱ�ӣ�����ȡ���ھ���˻�ػ�����Ĵ�Сfr

always @ (posedge clk_in)
begin
	if (~rst_n)
	begin
		addr_wr <= 0;
	end
	else
	begin
		if (wr)
		begin
			if (addr_wr == num_in)
				addr_wr <= 0;
			else
				addr_wr <= addr_wr + 1;	
		end
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
	end
	else 
	begin
		if (ind_out_tmp == max_ind)
		begin	
			if (ind_cnt2 >= size_out)	//��Ҫƫ�õĴ���
			begin
				ind_cnt2 <= 7;
			end
			else
			begin
				ind_cnt2 <= ind_cnt2 + 1;
			end
		end
		else
		begin
			ind_cnt2 <= ind_cnt2;
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
		ind_ready_tmp3 <= 0;
		ready <= 1;
	end
	else
	begin
		if	(ind_out_tmp || ind_cnt2)
			ind_ready <= 1;	
		else
			ind_ready <= 0;
		ind_ready_tmp <= ind_ready;
		ind_ready_tmp2 <= ind_ready_tmp;
		if (ind_out_tmp2 > num_in)	//����rom�������
			ind_ready_tmp3 <= 0;
		else
			ind_ready_tmp3 <= ind_ready_tmp2;	//����rom�����ʼ
		ready <= ~ind_ready_tmp3;
	end
end
           
clk_div u1(.clk_in(clk_in),.rst_n(rst_n),.n(size_kernel+4'd1),.clk_out(clk_in_div_slow));

bias_mult4 u2(.clk(clk_in),.ce(~rst_n),.p(bias),.a(ind_cnt2));

ind_conv2_in u3(.clka(clk_in),.ena(~rst_n),.addra(addr_ind),.douta(ind_out));

//���⣬��Ҫ���ƶ�ʱ�򣬸�ͨ�����½��д�룬���һ���
m_conv_3_ram u4(.clka(clk_in),.ena(rst_n_tmp),.wea(wr),.addra(addr_wr),.dina(map_in),.clkb(clk_in),.enb(ind_ready_tmp3),.addrb(addr_rd),.doutb(map_out));


endmodule

