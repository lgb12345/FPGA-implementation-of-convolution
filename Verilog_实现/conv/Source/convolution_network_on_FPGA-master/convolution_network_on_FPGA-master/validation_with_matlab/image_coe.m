%% ================Xilinx FPGA RAM COE�ļ����ɳ��� ===============


im_ = vectorize(im_);

neg=find(im_<0);
im_(neg)=im_(neg)+65536; 

fid = fopen('image.coe','wt'); %Ҳ��������TXT�ļ�֮�󣬽�txt��׺��Ϊcoe 

fprintf( fid, 'memory_initialization_radix=10;\n');

fprintf( fid, 'memory_initialization_vector =\n' ); 

fprintf(fid,'%d,\n',im_);

fclose(fid);
