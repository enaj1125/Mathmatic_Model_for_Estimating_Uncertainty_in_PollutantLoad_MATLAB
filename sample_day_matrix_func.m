function [sampleday_matrix] = sample_day_matrix_func(sample_interval)

%%%%%% To adjust to the varibility, create a sampling index 
sample_size = floor(365/sample_interval);
interval = sample_interval * ones(sample_size,1);
interval(1) = 0;
interval = cumsum(interval);
initial_day = randi(sample_interval,1); %%%%% determine the initial day
interval = interval + initial_day;
t = interval';
if sample_interval>19 && sample_interval<61
    sampleday_matrix = [t-3; t-2; t-1; t; t+1; t+2; t+3];
elseif sample_interval>9 && sample_interval<20
    sampleday_matrix = [t-2; t-1; t; t+1; t+2];
elseif sample_interval>2 && sample_interval<10
    sampleday_matrix = [t-1; t; t+1];
elseif sample_interval>0 && sample_interval<3
    sampleday_matrix = t;
end 