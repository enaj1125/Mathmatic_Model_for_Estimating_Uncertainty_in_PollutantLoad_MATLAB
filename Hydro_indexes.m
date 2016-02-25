function [ RB, V2, Lag1] = Hydro_indexes(flow_Data)


flow_Data = flow_Data(~isnan(flow_Data)); 
mean_flow = mean(flow_Data);
% % 1. Calculate RB
serie1 = flow_Data(1:end-1);
serie2 = flow_Data(2:end);
RB = sum(abs(serie2 - serie1))/sum(flow_Data);
% % 2. Calculate V2
ranked_flow = sort(flow_Data,'descend');
highflow = ranked_flow(1:round(length(ranked_flow)*0.02));
V2 = sum(highflow)/sum(flow_Data);
% % 3. Calculate Lag1
a = sum((serie1-mean_flow).*(serie2-mean_flow));
b = sum((flow_Data - mean_flow).^2);
Lag1 = a/b;
end

