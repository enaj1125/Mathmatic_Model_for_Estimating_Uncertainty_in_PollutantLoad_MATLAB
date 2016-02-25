%%%%%%%% Control File %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rela_u2_ADCI,rela_u2_MDFW,RMSE1, RMSE2] = iterationplot(Run_times)
%%%% 1. Read input data
File= 'Data_Rock.xlsx';   [ndata, text, rawdata] = xlsread(File,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 2. Sort missing data and split into annual series
[flow_mat, conc_mat,year_mat, month_mat, day_mat,day_365_mat] = storage_data_func(ndata, text, rawdata);
% % % flow_mat is the (366*50, number of years) dimentional matrix
% % % conc_mat is the (366*50, number of years) dimentional matrix
% % % year_mat is the (366*50, number of years) dimentional matrix 1978, 1999
% % % month_mat is the (366*50, number of years) dimentional matrix 0~12
% % % day_mat is the (n_years*366*50, number of years) dimentional matrix, values 0~31
% % % day_365_mat is the n_years*366*50, number of years matrix,values 0~365

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 3. Resample
%%%%% Note: output files are always the right size, if no sample data available, value of 0 is filled  
n_years = size(flow_mat,1);
%%%%% get the sample interval matrix
sample_interval = 30;  %[2, 7, 14, 21, ..];  !!!!!!!!!  interval  !!!!!!!!!
J = floor(365/sample_interval);
run_times = Run_times;                            %% !!!!!!!!!  runtimes  !!!!!!!!!
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
% % % matrix_index: (num of years, J)index obtained to use to extract subsamples from flow_mat, conc_mat 
% % % day_index: (num of years, J) day index of subsample, 0-366
% % % subday_index:(num of years, J)day index of subsample, 0-50
% % % n_sample:(num of years, 366)number of samples for each day 
for index = 1: n_years
    [matrix_index(index,:,runindex), day_index(index,:,runindex), subday_index(index,:,runindex),... 
        n_sample(index,:,runindex)] = ...       
        resample_func(flow_mat(index,:), sampleday_matrix);
end 

%%%%%% extract subsamples from the datasets
% % % sample_flow:(num of years, J) subsample flow values 
% % % sample_conc:(num of years, J) subsample conc vluae
% % Note: if sampled days have no data, their matrix_index is 0, so 
% % extractdata_func is used to fix the 0 index issues 
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 4. Deal with missing data
%%% To detect years with too many missing data, create a matrix 
%%% goodyears, good years(less than 30 days missing) with 1 & bad with 0.
num_sample = n_sample(:,:,1);   %% only use the first run result of n_sample
logic1 = num_sample ~= 0;
sum_nsample = sum(logic1,2);
i = find(sum_nsample < 335);
goodyears = ones(n_years,1);
goodyears(i) = 0;

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%% Prepare LOADEST input data (Optional) %%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% Note: output dataset is arranged as the order of year, month, day,
% % %%% flow, con, 5 columns. 
% % Data = zeros(J, 5, n_years,run_times);
% % for runindex = 1: run_times
% % PrepareLOADEST(matrix_index(:,:,runindex),year_mat,... 
% %     month_mat,day_mat,flow_mat,...
% %     conc_mat,Data(:,:,:,runindex),n_years,runindex)
% % end 

%%%% 4. True load Calculation   !! need to check if any 0 were used
True_Load = zeros(n_years,1);
True_Conc = zeros(n_years,1);
for i = 1: n_years
    [True_Load(i),True_Conc(i)] =  Calculate_trueload(conc_mat(i,:),flow_mat(i,:),day_365_mat(i,:)); 
end 


%%%% 5. Calcuate loads using two methods
% % create a daily flow matrix, start from the first available day to the last,
% % if no data: first use NaN, then fill with near-neigbour interpolation
% % (should not use linear-interp, since it may result in negative values!)

% % 1)calculate everyday average flow and its coresponding time index
Daily_flow = zeros(n_years, 366);
[Daily_flow,Daily_flow_time] = Get_daily_flow_func(Daily_flow, n_years, flow_mat);
% % round sample day index the same with flow 
rounded_sampleday365 = ceil(sample_day365);

% AL-CI Load
ADCI_Load = zeros(n_years,run_times);
for runindex = 1: run_times
    for i = 1: n_years
        daily_flow_time = Daily_flow_time(i,:);
        daily_flow = Daily_flow(i,:);
        sampleday365 = rounded_sampleday365(i,:,runindex);
        sampleconc = sample_conc(i,:,runindex);
        [annual_load,daily_conc,daily_load] =  Calculate_load1(daily_flow,daily_flow_time,...,
            sampleday365, sampleconc); 
        ADCI_Load(i,runindex) = annual_load;
    end 
end 
% % MD-FW Load 
MDFW_Load = zeros(n_years,run_times);
for runindex = 1: run_times
    for i = 1: n_years
        daily_flow = Daily_flow(i,:);
        sampleday365 = rounded_sampleday365(i,:,runindex);
        sampleconc = sample_conc(i,:,runindex);
        MDFW_Load(i,runindex) =  Calculate_load2(daily_flow,sampleday365,...,
            sampleconc); 
    end 
end 

% % % 6. Missing data & year selection
% % given indicator goodyears, select the right range of True_Load,ADCI_Load,MDFW_Load
bad_ind = find(goodyears == 0);
True_Load(bad_ind,:)=[];
ADCI_Load(bad_ind,:)=[];
MDFW_Load(bad_ind,:)=[];
bad_year_n = length(bad_ind); good_year_n = n_years - bad_year_n;


% % % % 7. Error Analysis
% % given True load, ALCI_Load, MDFW_Load, conduct uncertainty analysis
[rela_u2_ADCI,rela_u2_MDFW,P1,RMSE1,P2,RMSE2] = Uncertainty_analysis_func(True_Load,ADCI_Load,..., 
    MDFW_Load,run_times,good_year_n);
% % arrange result
A_result1 = [P1,RMSE1,P2,RMSE2];


% % % 8. Count sub-sample numbers
Good_sample_day365 = sample_day365;
Good_sample_day365(bad_ind,:,:) = [];
subsample_num = zeros(good_year_n,run_times);
for i = 1:good_year_n
    temp = Good_sample_day365(i,:,:);
    for i2 = 1:run_times
        temp2 = temp(:,:,i2);
        subsample_n = length(Get_continousdata(temp2));
        subsample_num(i,i2) = subsample_n;
    end 
end 
average_subsample_n = mean(mean(subsample_num,2));

% % % 9. Observed Annual Load & Conc.
% 
% % % observed annual load
% mean(True_Load)
% % % observed annual average conc
% mean(True_Conc)
% 
% A_result2 = [mean(True_Load);abs_e1;mean(True_Conc)];
end 