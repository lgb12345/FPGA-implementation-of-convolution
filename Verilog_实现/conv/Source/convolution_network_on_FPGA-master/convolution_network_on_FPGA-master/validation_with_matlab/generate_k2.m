k = [];
for i = 1:36
    tmp = kernel_2(:,:,18,i);
    neg=find(tmp<0);
    tmp(neg)=tmp(neg)+65536; 
    tmp = vectorize(tmp);
    tmp = tmp';
    k = [k;tmp];
end

fid = fopen('kernel2_18.coe','wt'); %Ҳ��������TXT�ļ�֮�󣬽�txt��׺��Ϊcoe 

fprintf( fid, 'memory_initialization_radix=10;\n');

fprintf( fid, 'memory_initialization_vector =\n' ); 

fprintf(fid,'%d,\n',k);

fclose(fid);
