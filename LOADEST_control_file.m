clc
clear
% 
File= 'N_grand.xlsx';   [ndata, text, rawdata] = xlsread(File,1);
run_times = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Sort missing data and split into annual series
[flow_mat, conc_mat,year_mat, month_mat, day_mat,day_365_mat] = storage_data_func(ndata, text, rawdata);
%%%% 3. Resample
%%%%% Note: output files are always the right size, if no sample data available, value of 0 is filled  
n_years = size(flow_mat,1);
%%%%% get the sample interval matrix
sample_interval = 30;  %[2, 7, 14, 21, ..];  !!!!!!!!!  interval  !!!!!!!!!
J = floor(365/sample_interval);
matrix_index = zeros(n_years,J,run_times);   %% prepare data storage
day_index = zeros(n_years,J,run_times);
subday_index = zeros(n_years,J,run_times);
sample_flow = zeros(n_years,J,run_times);
sample_conc = zeros(n_years,J,run_times);
sample_day365 = zeros(n_years,J,run_times);
n_sample = zeros(n_years,366,run_times);
for runindex = 1: run_times
[sampleday_matrix] = sample_day_matrix_func(sample_interval);
[I, J] = size(sampleday_matrix); %%%% I rows-range of numbers; J sampletimes
%%%%%% resample and get matrixes index  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for index = 1: n_years
    [matrix_index(index,:,runindex), day_index(index,:,runindex), subday_index(index,:,runindex),... 
        n_sample(index,:,runindex)] = ...       
        resample_func(flow_mat(index,:), sampleday_matrix);
end 
%%%%%% extract subsamples from the datasets
for index = 1:n_years
    indx = matrix_index(index,:,runindex);
    flow_temp = flow_mat(index,:);  
    sample_flow(index,:,runindex) = extractdata_func(indx,flow_temp);
    sample_conc_temp = conc_mat(index,:);
    sample_conc(index,:,runindex) = extractdata_func(indx,sample_conc_temp);
    sample_day365_temp = day_365_mat(index,:);
    sample_day365(index,:,runindex) = extractdata_func(indx,sample_day365_temp);
end
end 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % 1.make folders and prepare the input files
for i = 1:5
    number = num2str(i);
    filename = strcat('test',number);
    mkdir('../Tests',filename);
    newdir = strcat('../Tests/',filename,'/');
    copyfile('test3/CO*',newdir);
    copyfile('test3/HEAD*',newdir);
    copyfile('test3/load*',newdir);
end 

% 2. create input files
% resample
[Daily_flow, data_mat] = Prepare_Est(n_years,flow_mat,year_mat,month_mat,day_mat);
thedate = data_mat(1,:)'; theflow= data_mat(2,:)';
content = [thedate, zeros(size(thedate)), theflow];
write_inp_files(content,'EST.INP')

% % prepare calibration file
for runindex = 1: run_times
    runindex
    [Total_set] = Prepare_Calib(Daily_flow,matrix_index(:,:,runindex),year_mat,... 
    month_mat,day_mat,conc_mat,n_years);
    write_inp_files(Total_set,'CALIB.INP');
  	number = num2str(runindex+21);   %%%%%% runindex+5
    savdir = strcat('D:\A_Now\Tests\test',number);
    copyfile('CALIB.INP',savdir);
    copyfile('EST.INP',savdir);
    LOADEST_path = strcat(savdir,'\loadest.exe');
    winopen(LOADEST_path);
    delete('CALIB.INP');
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% after finishing the LOADEST run %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% analyze errors based on the output files

analysis_num = 50;
E = zeros(n_years,analysis_num);  %%%%%%%% change run_times
Annual_load_estimates = zeros(n_years,analysis_num);
Page = 7;     %%%%% change true load page !!!!!!!!!!!!!!!!!!!!!!!!
true_load = xlsread('N_trueload.xlsx',Page);
filter = xlsread('N_trueload.xlsx',Page,'B:B');
for i = 1: analysis_num
    i
    filename = strcat('D:\A_Now\Tests\test',num2str(i),'/nitrate.IND');
    copyfile(filename,'D:\A_Now\A_practice_Matlab_2014');
    [E(:,i), Annual_load_estimates(:,i)] = LOADEST_analysis(true_load);  
    delete('nitrate.IND')
end 
% 
% %%%% uncertainty analysis
% badyear = find(filter == 0);
% E(badyear,:) = [];
% Annual_load_estimates(badyear,:) = [];
% true_load(badyear,:) = [];
% errors = reshape(E,[],1);
% A_percentile = prctile(errors,[5 50 95]);
% A_rmse = (sum(errors.^2)/length(errors)).^(0.5);
% 
% %%%%% compare estimated loads with real load; also show errors
% Mean_annual_load_est = 86.4 * mean(Annual_load_estimates,2);
% STD_annual_load_est = 86.4 * std(Annual_load_estimates,0,2);
% true_load = 86.4 * true_load;
% 
% wd_name='Grand';   %%%%%%%%!!!!!!!!!!!!!!! change
% fontsize = 24;       %%%%%%%%%!!!!!!!!!!!!!
% 
% %%%%% plot est load and true load
% subplot(2,1,1)
% errorbar(Mean_annual_load_est,STD_annual_load_est,'--or','LineWidth',2);
% hold on
% plot(true_load(:,1),'--ok','LineWidth',2,'MarkerFaceColor','k')
% set(gca,'FontSize',fontsize)
% legend('Average load estimates with standard deviation','True load','FontSize',fontsize) %%%!!!
% ylabel('Annual Load (kg/yr)','FontSize',fontsize-4)
% title_char=strcat(wd_name,' Watershed');
% title(title_char, 'Color', 'k','fontsize',fontsize+2);
% %%%%% plot errors trends
% Mean_E = mean(abs(E),2);
% STD_E = std(abs(E),0,2);
% subplot(2,1,2)
% errorbar(Mean_E,STD_E,'-ok','LineWidth',2,'MarkerFaceColor','k');
% hold on
% a = 0:0.01:size(E,1);
% b = zeros(1,length(a));
% plot(a,b)
% legend('Average load estimation errors with standard deviation','0 error')  %%%%%%%%!!!!
% xlabel('number of years','FontSize',fontsize-4)
% ylabel('Percentage Errors (%)','FontSize',fontsize-4)
% set(gca,'FontSize',fontsize)
