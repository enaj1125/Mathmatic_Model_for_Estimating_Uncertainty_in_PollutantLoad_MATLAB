% % Get daily flow matrix and its correspoinding date 
function [Daily_flow,flow_timeindex] = Get_daily_flow_func(Daily_flow, n_years, flow_mat)
% % create a daily flow matrix, start from the first available day to the last,
% % if no data first use NaN, then fill with near-neigbour interpolation
% % should not use linear-interp, since it may result in negative values

% % 1 calculate average flow 
[Daily_flow] = Calculate_daily_ave(Daily_flow,n_years,flow_mat);
for i = 1: n_years
    temp = flow_mat(i,:);
    temp = reshape(temp, 50, 366);    
     for i2 = 1 : 366       
        temp2 = temp(:,i2);
        index = find(temp2>0); % find the day indexes that have flow data
        daily_flow = mean(temp2(index)); % get their mean & assign as the new flow data
        Daily_flow(i,i2) = daily_flow;
     end
end 

% % 2. fix NaN values by Interpolate nearest neighbor
%%% out of bound there are still NaN
for i = 1:n_years
    
    yearly_flow = Daily_flow(i,:);
    t = linspace(0.1, 1, numel(yearly_flow));
    % indices to NaN values in x;(assumes there are no NaNs in t)
    nans = isnan(yearly_flow);
    % replace all NaNs in x with nearest neighbor
    yearly_flow(nans) = interp1(t(~nans), yearly_flow(~nans), t(nans), 'nearest');
    Daily_flow(i,:) = yearly_flow;
end 

% % 3. Calculate the time index of daily flow which has the same
% availability with flow 
index = ~isnan(Daily_flow);
A = 1:366;
B = repmat(A,n_years,1);
flow_timeindex = index .* B; 
end 

% % 4. Calculate the time

