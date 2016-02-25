function [Total_set] = Prepare_Calib(Daily_flow,matrix_index,year_mat,month_mat,day_mat,conc_mat,n_years)

Total_set = [];

for index = 1: n_years
    idx = matrix_index(index,:);
    %%% extract the data using matrix index
    year_temp = year_mat(index,:);  %%% year
    year = extractdata_func(idx,year_temp);
    month_temp = month_mat(index,:); %% month
    month = extractdata_func(idx,month_temp);
    day_temp = day_mat(index,:);    %% day
    day = extractdata_func(idx,day_temp);  
    
    conc_temp = conc_mat(index,:);   %% conc
    conc = extractdata_func(idx,conc_temp);
        
    % % find base date
    i = find(year_temp>0);
    beginyear = year_temp(i(1));
    begin_num = datenum(beginyear,10,1);
    sample_daynum =datenum(year,month,day);
        
    order_num = sample_daynum - begin_num + 1;
    % % if the sample day has no data, year, month,day = 0, so need to
    % delete negative order_num
    neg_idx = find(order_num <= 0);
    posi_idx = find(order_num > 0); 
    flow_temp = Daily_flow(index,:);
    Size = size(order_num);
    avg_flow = (-1) * ones(Size);
    avg_flow(posi_idx) = flow_temp(order_num(posi_idx));
    avg_flow(neg_idx) = -99;
    
    %%% output data   
    a = num2str(year');
    b = num2str(month','%02i');
    c = num2str(day','%02i');
    strings = strcat(a,b,c);
    date = str2num(strings);
    one_set = [date,avg_flow',conc']; %%% everyday dataset
    %%%%%%%%% get rid of no data + no flow days %%%%%%%%%%%%%%%%%%%%
    aa = one_set(:,1);
    bad_days = find(aa ==0);
    bad_flows = find(avg_flow < 0)';
    bads = cat(1,bad_days,bad_flows); 
    Bads = unique(bads);
    one_set(Bads,:) = [];
    %%%%%%% output %%%%%%%
    Total_set = vertcat(Total_set,one_set);   
end
a = Total_set(:,1); b = Total_set(:,2); c = Total_set(:,3);
d = zeros(length(a),1);
Total_set = [a,d,b,c];
%xlswrite('1cali_file',Total_set,1);

end 

