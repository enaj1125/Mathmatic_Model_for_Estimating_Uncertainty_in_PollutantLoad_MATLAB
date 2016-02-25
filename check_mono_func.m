% check monotoic 

function [ind]= check_mono_func(Data)
data2 = zeros(size(Data));
data2(1:end-1) = Data(2:end);

compare = Data./data2; 

ind = find(compare ==1);