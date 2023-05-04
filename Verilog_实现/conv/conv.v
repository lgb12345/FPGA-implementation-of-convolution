module conv(
				input wire rst,
				input wire clk,
				input wire [7:0] conv_data,
				input wire [7:0] core_data,
				//input wire signed  [7:0] CONV_iData,
				input wire [7:0] core_i,//卷积核是i*i的矩阵
				input wire [7:0] conv_i,//卷积输入大小i*i的矩阵
				input wire [7:0] stride,//步长
				//output reg signed [19:0] CONV_oData，
				output reg [7:0] cnt_1,//在输入中定位开始的地方
				//output reg flag_1,//在输入中定位开始的地方
				//output reg flag_2,//横行完成输出标志位
				output reg [7:0] cnt_2,//第一行输入反复计数
				//output reg [7:0] cnt_3,//第一行输入完成计数
				//output reg [7:0] cnt_4,//第一行全部完成计数
				output reg [19:0] core_loc,//定位卷积核的位置
				output reg [19:0] cnt_loc,//定位输入数据的位置
				
				//output reg [19:0] core_loc_1,//定位卷积核的位置(加入padding)
				//output reg [19:0] cnt_loc_1,//定位输入数据的位置（加入padding）
				
				
				//output reg [19:0] conv_mul,
				//output reg [19:0] conv_add,
				//output reg [7:0] conv_size,//卷积后格子大小
				output reg [19:0] conv_out
			  );

//reg [7:0] cnt_1;//用以计数输入了几个数据，当等于卷积核i时，输出标志位开始进行乘法运算
//reg [7:0] cnt_2;//输入数据第一行完成
//reg [20:0] cnt_loc;//定位输入



reg signed [19:0] CONV_oData;
//reg [7:0] cnt_1;//在输入中定位开始的地方
reg flag_1;//在输入中定位开始的地方
reg flag_2;//横行完成输出标志位
//reg [7:0] cnt_2;//第一行输入反复计数
reg [7:0] cnt_3;//第一行输入完成计数
reg [7:0] cnt_4;//第一行全部完成计数
//reg [19:0] core_loc;//定位卷积核的位置
//reg [19:0] cnt_loc;//定位输入数据的位置
				
reg [19:0] core_loc_1;//定位卷积核的位置(加入padding)
reg [19:0] cnt_loc_1;//定位输入数据的位置（加入padding）
				
				
reg [19:0] conv_mul;
reg [19:0] conv_add;
reg [7:0] conv_size;//卷积后格子大小






always@(posedge clk or negedge rst)
begin
  if(!rst)
  begin
  cnt_1 <= 8'd0;
  flag_1 <= 0;
  end
  else
  begin
  cnt_1 <= cnt_1 + 1;
    if(cnt_1 == core_i)
      begin
		flag_1 <= 1;
		cnt_1 <= 0;
		end
	 else
	 flag_1 <= 0;
  end
end

always@(posedge clk or negedge rst)
begin
  if(!rst)
  begin
  cnt_2 <= 0;
  cnt_3 <= 0;
  end
  else
  begin
  if(flag_1 == 1)
    begin
    if(cnt_2 == core_i)
	 begin
	 cnt_2 <= 8'd0;
	   if(cnt_3 < conv_size)
	   cnt_3 <= cnt_3 + 1;
		else
		cnt_3 <= 8'd0;
	 end
	 else
    cnt_2 <= cnt_2 + 1;
	 end
  else
    cnt_2 <= cnt_2;
  end
end


always@(posedge clk or negedge rst)
begin
  if(!rst)
  begin
  cnt_4 <= 8'd0;
  flag_2 <= 0;
  end
  else
  begin
    if(cnt_3 == conv_size && cnt_2 == core_i && flag_1 == 1)
    begin
      if(cnt_4 < conv_size)
      cnt_4 <= cnt_4 + 1;
      else
	   begin
      cnt_4 <= 8'd0;
	   flag_2 <= 1;
	   end
    end
    else
    cnt_4 <= cnt_4;
  end
end


always@(posedge clk or negedge rst)
begin
  if(!rst)
  begin
  cnt_loc <= 20'd1;
  core_loc <= 20'd1;
  end
  else
  begin
    if(cnt_2 < core_i)
	 begin
      if(flag_1 == 0)
		begin
		  if(cnt_3 == 0 && cnt_4 ==0)
		  begin
	     cnt_loc <= conv_i * (cnt_2 + cnt_4) + cnt_1 +cnt_3 ;
		  core_loc <= core_i * cnt_2 + cnt_1;
		  end
		  else if(cnt_4 == 0)
		  begin
		  cnt_loc <= conv_i * (cnt_2 + cnt_4) + cnt_1 + cnt_3 + (stride - 1)*cnt_3 ;
		  core_loc <= core_i * cnt_2 + cnt_1;
		  end
		  else
		  begin
		  cnt_loc <= conv_i * (cnt_2 + cnt_4*stride) + cnt_1 + cnt_3 + (stride - 1)*cnt_3 ;
		  core_loc <= core_i * cnt_2 + cnt_1;
		  end
		end
	   else
	   cnt_loc <= cnt_loc;
	 end
	 else
	 cnt_loc <= cnt_loc;
  end
end

always@(negedge clk or negedge rst)
begin
  if(!rst)
  conv_mul <= 20'd0;
  else
  if(cnt_1 == 2)
   conv_mul <= 20'd0;
  else
  conv_mul <= conv_data * core_data;
end



always@(negedge clk or negedge rst)
begin
   if(!rst)
   conv_add <= 20'd0;
	else
	begin
	  if(cnt_1 < 3 && cnt_2 == 0 && cnt_3 == 0 && cnt_4 == 0 && flag_1 == 0)
	  conv_add <= 20'd0;
	  else
	  begin
	  if(cnt_2 == 0 && cnt_1 == 2)
	  conv_add <= 20'd0;
	  else
	  conv_add <= conv_add + conv_mul;
	  end
	end
end


always@(negedge clk or negedge rst)
begin
  if(!rst)
  conv_out <= 20'd0;
  else
  begin
    if(cnt_2 == core_i && cnt_1 == 3)
	 conv_out <= conv_add;
	 else
	 conv_out <= conv_out;
  end
end



//卷积后格子大小
always@(posedge clk or negedge rst)
begin
  if(!rst)
  conv_size <= 8'd0;
  else
  conv_size <= (conv_i-core_i)/stride;
end







endmodule