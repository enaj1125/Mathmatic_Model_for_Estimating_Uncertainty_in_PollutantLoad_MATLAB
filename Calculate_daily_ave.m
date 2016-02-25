function [Daily_flow] = Calculate_daily_ave(Daily_flow,n_years,flow_mat)

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

end 