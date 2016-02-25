function [Load,fwmc] =  Calculate_trueload(conc_mat,flow_mat,day_365_mat) 

%%% if the the starting date is 12 am of Oct 1st, the first day will be
%%% slightly modified to be not filterd in the get_continous function.
if day_365_mat(1)== 0
    day_365_mat(1) = day_365_mat(1)+ 0.0000001;
end

%%% get the conc, flow, t, continous
conc = Get_continousdata(conc_mat);
flow = Get_continousdata(flow_mat);
Time = Get_continousdata(day_365_mat);

%%% calculate interval t
t = Time(1:end-1);
Time_interval = Time(2:end) - t;
%%% calcate load, based on forward difference ( the last conc. and flow
%%% were not used
length(conc),length(flow),length(Time) 
load_continous = conc(1:end-1) .* flow(1:end-1) .* Time_interval .* 2.4468; %(kg/yr = mg/L * cfs * day * 2.4468)
Load = sum(load_continous);

%%% FWMC
fwmc = sum(conc(1:end-1).*flow(1:end-1).*Time_interval)./sum(flow(1:end-1) .* Time_interval);

end 