function [ B ] = vectorize2( A )
%VECTORIZE ������Ԫ�����л�������ROM�洢����������

m = size(A,4);
B = [];

for i = 1:m
    B = [B,vectorize(A(:,:,:,i))];
end

end

