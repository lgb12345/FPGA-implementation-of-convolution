k = [];
for i = 1:120
    tmp = kernel_3(:,:,37,i);
    neg=find(tmp<0);
    tmp(neg)=tmp(neg)+65536; 
    tmp = vectorize(tmp);
    tmp = tmp';
    k = [k;tmp];
end

fid = fopen('kernel3_37.coe','wt'); %Ҳ��������TXT�ļ�֮�󣬽�txt��׺��Ϊcoe 

fprintf( fid, 'memory_initialization_radix=10;\n');

fprintf( fid, 'memory_initialization_vector =\n' ); 

fprintf(fid,'%d,\n',k);

fclose(fid);