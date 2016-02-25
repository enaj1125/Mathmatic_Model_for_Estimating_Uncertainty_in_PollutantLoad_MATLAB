%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Sort and Storage data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [flow_mat, conc_mat,year_mat, month_mat, day_mat,day_365_mat] = storage_data_func(ndata, text, rawdata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% fix missing data %%%%%%%%%%%%%%%%%%%%%
% % 1. Find the negative and NaN values in Conc, delete the places in Flow, Conc and Date;
% % 2. Find the negative and NaN values in Flow, replace and fill in missing data place 
%%%% convert the date into numeric date array
raw_date = rawdata(:,1);
n = length(text);
Date = zeros(n,1);
for idx = 1:numel(text)
    Date(idx) = datenum(raw_date{idx});
    idx, Date(idx)
    
end
%%%% In concs, find elements that are not NAN and non-negative, not include
%%%% 0!!, some missing data appear as 0
Conc = ndata(:,1);
Flow = ndata(:,2);
i = find(isnan(Conc) | Conc <= 0);
Flow(i) = [];
Conc(i) = [];
Date(i) = [];
%%%%% In flows, 
i = find(isnan(Conc) | Flow <= 0);
Flow(i) = NaN;
Flow = Nearest_interp_NaN_func(Flow);   %%% use nearest neibourghor !!!
% % ________________________________________________________________


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Storage data into annual matirx %%%%%%%%%%%%%%%%%%
%%%% 1. determine the 1st and last day of study period
%%%% 2. calcuate "Year index" and "day index", then find col_num and row_num to store data
%%%% 3. read through and split into year matirxes

% % 1. To create "Water Year", determine the fisrt/last date of water years
i=1;
while month(Date(i))<10
    i=i+1;
end
%%%%%%%%%%%%%%%
N=length(Date); j=N;
while month(Date(j))>9
    j=j-1;
end
%%%% extract the right range of flow, conc, date 
Date = Date(i:j,1);
Flow = Flow(i:j,1);
Conc = Conc(i:j,1);
%%%% determine the beginning year and endyear, the number of study years
beginyear=year(text{1});
endyear=year(text{end});
num_year=endyear-beginyear;
%%% find the base year of each data 1976, 1980,..., get Year_adj 
day_idx = 0;
Year = year(Date);
Month = month(Date);
adj = find( Month < 10);
logics = zeros(length(Year),1);
logics (adj) = 1;
Year_adj = Year - logics;
length_Date=length(Date);  %%%%% This can be used for loop index
%%% To calculate "Year index", find how many differnt years (considering missing years)
Year_collect = [Year_adj(1)]; %% find the real year number, 1976,1977,..
Year_index = ones(length_Date,1); %% find the "Year index", 1,1,2,2,3,...
for i = 1:length_Date-1
    if Year_adj(i+1) ~= Year_adj(i)
        Year_collect = [Year_collect, Year_adj(i+1)];
        Year_index(i+1) = Year_index(i) + 1;
    else
        Year_index(i+1) = Year_index(i);
    end
end 
%%%%%% create a base_num matrix, or "day index" 
base_num = zeros(length(Year_adj),1);
for i = 1: length(Year_collect)
    which_year = Year_collect(i);
    idx = find(Year_adj == which_year);
    base_num(idx) = datenum(which_year, 10, 1); %%%%% Oct 1th is base date
end 
%%%%% obtain a datenum index
adj_Date = Date - base_num;
Day_index = floor(adj_Date) + 1;
% % ________________________________________________________________________


%%%% 3. split annual data
flow_mat = zeros(num_year, 366*50);
conc_mat = zeros(num_year, 366*50);
year_mat = zeros(num_year, 366*50);
month_mat = zeros(num_year, 366*50);
day_mat = zeros(num_year, 366*50);
day_365_mat = zeros(num_year, 366*50);
%%%% initialize data in the first day
old_day_idx = 1;
Day_inmonth = day(Date);       %%%% adjust the day number in the environ of a month
for i = 2: length_Date         %%%%%% loop through the right range 
    year_index = Year_index(i);
    Day = Day_index(i);
    if Day_index(i) ~= Day_index(i-1)
        iidx = 1;
        old_day_idx = 1;
    else
        iidx = old_day_idx+1;
    end
    old_day_idx = iidx;
    col_num = (Day-1)*50+iidx;
    row_num = year_index;
    %%%% store 
    flow_mat(row_num, col_num) = Flow(i);
    conc_mat(row_num, col_num) = Conc(i);
    year_mat(row_num, col_num) = Year(i);       %%% the year 1977, 1978, ..
    day_mat(row_num, col_num) = Day_inmonth(i); %%% the day in a month, 1~31;
    month_mat(row_num, col_num) = Month(i);     %%% 
    day_365_mat(row_num, col_num) = adj_Date(i); %%% the day in a year, 0-366
end 
%%% for i = 1, since it is not necessary the "first" day of the year
iidx = 1;
Year = Year_index(1);
Day = Day_index(1);
col_num = (Day-1)*50+iidx;
row_num = Year;
flow_mat(row_num, col_num) = Flow(1);
conc_mat(row_num, col_num) = Conc(1);
year_mat(row_num, col_num) = Year_adj(1);
day_mat(row_num, col_num) = Day;
month_mat(row_num, col_num) = Month(1);
day_365_mat(row_num, col_num) = adj_Date(1);

end 





