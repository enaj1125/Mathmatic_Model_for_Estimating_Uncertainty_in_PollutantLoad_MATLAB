function [output] = import_LOADEST(filename)

loadest_data = importdata(filename);
data = loadest_data.data;

date = data(:,1);
flow = data(:,3);
load = data(:,4);
output = [date,flow,load];

end 