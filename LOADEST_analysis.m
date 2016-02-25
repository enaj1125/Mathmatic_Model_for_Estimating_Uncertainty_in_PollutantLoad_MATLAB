%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% analyze the output file   %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [e, annual_load] = LOADEST_analysis(true_load)
% % 1. prepare data 
filename = 'nitrate.ind';
data = import_LOADEST(filename);
[year,month,day] = split_date(data(:,1)); % % date format
flow = data(:,2);load = data(:,3); 

% % 2.determine the fisrt/last date of water years
i=1;
while month(i)<10
    i=i+1;
end
N=length(month); j=N;
while month(j)>9
    j=j-1;
end
% % extract the right range of flow, conc, date 
year = year(i:j,1);month = month(i:j,1);day = day(i:j,1);

% % 3.number the year of the data
index1 = find(month==10|month ==11|month==12);
adj_index = zeros(size(year));
adj_index(index1)= 1;
adj_year = adj_index + year;

% % 4.calculate annual load
Years = unique(adj_year);
n_years = length(Years);
annual_load = zeros(n_years,1);
for i = 1:n_years
    year_idx = find(adj_year == Years(i));
    annual_load(i) = sum(load(year_idx));
end 

% % 5. Uncertainty analysis by comparing with True load
trueload = true_load(:,1);
e = 100*(annual_load - trueload)./trueload;

end 
