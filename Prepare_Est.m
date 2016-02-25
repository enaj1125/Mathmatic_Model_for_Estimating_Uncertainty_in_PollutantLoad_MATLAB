function [Daily_Flow, data_mat] = Prepare_Est(n_years,flow_mat,year_mat,month_mat,day_mat)

Daily_flow = zeros(n_years, 366);
[Daily_Flow,flow_timeindex] = Get_daily_flow_func(Daily_flow,n_years,flow_mat);
Daily_flow = reshape(Daily_Flow',[],1);
Daily_flow = Daily_flow(~isnan(Daily_flow));

%%%% calculate the current date
year1 = zeros(n_years,1);
month1 = zeros(n_years,1);
day1 = zeros(n_years,1);
for yr_indx = 1: n_years   
    year1(yr_indx) = Find_1st_nonNan_func(year_mat(yr_indx,:));
    month1(yr_indx) = Find_1st_nonNan_func(month_mat(yr_indx,:));
    day1(yr_indx) = Find_1st_nonNan_func(day_mat(yr_indx,:));
end 

% % adjust the baseyear in case of month1 start from Jan, Feb...
logic1 = month1 < 10;
year1 = year1 - logic1;
% % calculate basedate
base_datenum = datenum(year1,10,1);
Base_datenum = repmat(base_datenum,1,366);
flow_timeindex(flow_timeindex == 0)= -999999999; 
current_time = flow_timeindex + Base_datenum - 1;

Daily_year = year(current_time); 
Daily_month = month(current_time); 
Daily_day = day(current_time); 

Daily_year = reshape(Daily_year',[],1);
Daily_month = reshape(Daily_month',[],1);
Daily_day = reshape(Daily_day',[],1);

% % % make a hard copy
a = num2str(Daily_year);
b = num2str(Daily_month,'%02i');
c = num2str(Daily_day,'%02i');
strings = strcat(a,b,c);

date = str2num(strings);
date = date(date>0); %%% the noflow days have negative date
data_mat = [date,Daily_flow]';
     
xlswrite('1est_file',date,1,'A')
xlswrite('1est_file',zeros(length(date),1),1,'B');
xlswrite('1est_file',Daily_flow,1,'C');

% fileID = fopen('EST.INP','w');
% fprintf(fileID,'1\n');
% fprintf(fileID,'%.f	0000	%.f \n',data_mat);
% fclose(fileID);
end


