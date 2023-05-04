`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:38:01 03/01/2017 
// Design Name: 
// Module Name:    m_layer_input_4 
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
module m_layer_input_4(
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
parameter num_in = 6'd35;	//map_in��Ŀ-1

parameter num_loop = 7'd119;	//��Ҫѭ���Ĵ���-1

input clk_in;
input rst_n;	//�͸�λ
input signed [15:0] map_in;	//��1�㣺��������룬��һ����˳����Ҫ���� 
input wr;	//������������ٶȲ�ͬ����Ҫ���浽ram�У���Ϊд���ź�
output signed [15:0] map_out;	//��������� 
output k_ready;	//�������˲����������źţ��൱����ǰ��ind_ready_tmp3
output reg ready = 1;	//��Ϊ��һ���ĵ͸�λ

output reg k_loop = 0;	//����һ�β�������ܶ��������Դ���ޣ����ʷֳɼ���ѭ������Ϊһ��ѭ����־
reg [6:0] loop_cnt = 0;	//ѭ���Ĵ�������
	
reg end_flag = 1;	// trick
reg end_flag_tmp = 1;	// trick


//##��Ҫ��ʵ������޸�λ��
reg [5:0] addr_wr = 0;	//ram��ַ

reg [2:0] ind_cnt = 0;	//�������ӷ��ļ�����
reg [5:0] addr_rd = 0;	////ram�ĵ�ַ

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

always @ (posedge clk_in)
begin
	if (rst_n) 
	begin
		addr_rd <= 0;
		loop_cnt <= 0;
		k_loop <= 0;
		end_flag <= 1;
	end
	else 
	begin
		if (addr_rd == 30)	//�����ȴ�����ˣ�ͨ�����Եõ�
		begin
			addr_rd <= addr_rd + 1;
			if (loop_cnt >= num_loop)
			begin
				loop_cnt <= num_loop + 1;
				k_loop <= 0;
			end 
			else
			begin
				loop_cnt <= loop_cnt + 1;
				k_loop <= 1;
			end
			end_flag <= 1;
		end
		else if (addr_rd == num_in)
		begin
//			addr_rd <= 0;
			loop_cnt <= loop_cnt;
			k_loop <= 0;
			if (loop_cnt > num_loop)
			begin
				addr_rd <= addr_rd;
				end_flag <= 0;
			end
			else
			begin
				addr_rd <= 0;
				end_flag <= 1;
			end
		end
		else
		begin
			addr_rd <= addr_rd + 1;
			loop_cnt <= loop_cnt;
			k_loop <= 0;
			end_flag <= 1;
		end
	end
end

assign k_ready = (~rst_n) && (end_flag_tmp);	//trick

always @ (posedge clk_in)
begin
	if (rst_n) 
	begin
		ready <= 1;
		end_flag_tmp <= 1;
	end
	else
	begin
		ready <= ~k_ready;
		end_flag_tmp <= end_flag;
	end
end

m_max_4_ram u1(.clka(clk_in),.ena(rst_n),.wea(wr),.addra(addr_wr),.dina(map_in),.clkb(clk_in),.enb(k_ready),.addrb(addr_rd),.doutb(map_out));

endmodule
