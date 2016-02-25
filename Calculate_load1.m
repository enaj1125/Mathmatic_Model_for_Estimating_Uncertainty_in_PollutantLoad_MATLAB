function [fwmc,annual_load,daily_conc,daily_load,sample_conc] =  Calculate_load1(daily_flow,daily_flow_time,sampleday365,sample_conc)

% % 1. find sample day and conc | x, y 
% since 0 values are used to fill in missing data days, so first get rid of these missing days 
sample_conc = Get_continousdata(sample_conc); 
sampleday365 = Get_continousdata(sampleday365); 

%%% 2. use interpolation to estimate 

% % interpolate conc in the range of sampled days
daily_conc = interp1(sampleday365,sample_conc,daily_flow_time,'linear',0);

% % mark the dates out of the range of daily flow days as NaN, so they won't be
% % filled in the next step
ind_1st = find(daily_flow_time, 1, 'first');
ind_last = find(daily_flow_time, 1, 'last');
if ind_1st > 1
    daily_conc(1:ind_1st-1) = NaN;
end 
if ind_last <366
    daily_conc(ind_last+1:end) = NaN;
end 

% % find the days with the range of daily flow that still need to be filled
outofrange_index = find(daily_conc == 0);
temp = interp1(sampleday365, sample_conc, outofrange_index,'nearest','extrap');
daily_conc(outofrange_index)= temp;

% % 3. Calculate load
daily_load = daily_conc .* daily_flow .* 2.4468;
% % sum up annual
annual_load = nansum(daily_load(1:end-1)); %%% because of back forward end-1; nansum control the range
% % FWMC
fwmc = annual_load/(nansum(daily_flow)* 2.4468);
end 


% % %%%%%%% Example of how to deal with interpolation and extrapolation
% % % define x,y
% % x = 1:5
% % Y = randi(10,5,1)
% % % interpolate yi in range
% % yi = interp1(x,Y,xi,'linear',0)
% % % find out of range index
% % outofrange_index = find(yi==0)
% % % extrapolate using nearest neiborghor 
% % temp = interp1(x,Y,outofrange_index,'nearest','extrap')
% % yi(outofrange_index)= temp;