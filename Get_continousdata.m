function [data_x] = Get_continousdata(Data)

i = find(Data>0);
data_x = Data(i);
