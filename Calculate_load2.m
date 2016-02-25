function [annual_load] =  Calculate_load2(daily_flow,rounded_sampleday365,sample_conc)

% % 1, get measured days conc and flow(flow is getting from the daily
% average flow
measured_conc = Get_continousdata(sample_conc); % since 0 values are
% % used to fill in missing data days, so first get rid of these missing days 
sampleday365 = Get_continousdata(rounded_sampleday365);

measured_flow = daily_flow(sampleday365);

% % 2, calculate load
f = nansum(measured_conc .* measured_flow)/nansum(measured_flow);
annual_load = nansum(daily_flow) * f .* 2.4468;
end 
