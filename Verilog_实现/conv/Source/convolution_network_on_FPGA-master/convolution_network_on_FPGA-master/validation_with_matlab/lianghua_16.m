function [ A ] = lianghua_16( A )
%LIANGHUA_16 Summary of this function goes here
%   Detailed explanation goes here

% A = round(A./8*32767); %�ȼ�������
A = round(A * 4096);

end

