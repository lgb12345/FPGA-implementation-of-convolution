`timescale 1ns/1ps
module tb_conv();
reg clk;
reg rst;
reg [7:0] core_i;
reg [7:0] conv_i;
reg [7:0] conv_data;
reg [7:0] core_data;
reg [7:0] stride;
wire [7:0] cnt_1;//在输入中定位开始的地方
wire flag_1;//在输入中定位开始的地方
wire flag_2;
wire [7:0] cnt_2;
wire [7:0] cnt_3;
wire [7:0] cnt_4;
wire [19:0] cnt_loc;
wire [19:0] core_loc;
wire [19:0] conv_mul;
wire [19:0] conv_add;
wire [19:0] conv_out;
wire [7:0] conv_size;



conv tb_conv(
				.clk(clk),
				.rst(rst),
				.conv_data(conv_data),
				.core_data(core_data),
				.core_i(core_i),
				.conv_i(conv_i),
				.stride(stride),
				.cnt_1(cnt_1),
				//.flag_1(flag_1),
				//.flag_2(flag_2),
				.cnt_2(cnt_2),
				//.cnt_3(cnt_3),
				//.cnt_4(cnt_4),
				.core_loc(core_loc),
				//.conv_mul(conv_mul),
				//.conv_add(conv_add),
				.cnt_loc(cnt_loc),
				//.conv_size(conv_size),
				.conv_out(conv_out)
			  );
			  
reg  [7:0] data_0 [1:100];	//暂存矩阵数据		 
reg  [7:0] data_1 [1:100];	//暂存卷积核数据	 
integer i;			  

initial begin
        clk = 1'b0 ;
        forever 
		  begin
            # 100 ;
            clk = ~clk ;
        end
        end
		  
initial begin
        rst = 1'b0 ;
		  core_i = 0;
		  conv_i = 0;
		  stride = 0;
        # 30   rst = 1'b1 ;
		  core_i = 7'd3;
		  conv_i = 7'd10;
		  stride = 7'd4;
        # 1000000;
        $finish ;
    end 

initial begin
		  $readmemh("data_input0.txt", data_0);
		  $readmemh("data_input1.txt", data_1);
		  i=0;
		  conv_data=0;
		  core_data=0;
		  #100
        forever begin
        @(negedge clk) begin
		  if(i==1500)
        i = 0;
        else
        begin
        conv_data = data_0[cnt_loc];
		  core_data = data_1[core_loc];
        end
		  end
		  end
		  end


integer save_file;
initial begin
    save_file = $fopen("E:/Source_Competition/FPGA/conv_1/data_out.txt");    //打开所创建的文件；若找不到该文件，则会自动创建该文件。
    if(save_file == 0)begin 
        $display ("can not open the file!");    //如果创建文件失败，则会显示"can not open the file!"信息。
        $stop;
    end
end

always @(posedge clk) begin
    if (cnt_2==core_i&&cnt_1==core_i) begin
        $fdisplay(save_file,"%d",conv_out);    //在使能信号为高时，每当时钟的上升沿到来时将数据写入到所创建的.txt文件中
    end
end




	 
endmodule