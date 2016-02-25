function [FWMC_rmse,FWMC_abs,rela_u_ADCI, rela_u_MDFW, P1,RMSE1,P2,RMSE2,ABS_Err_1,ABS_Err_2,STD_ABS_Err_1,STD_ABS_Err_2] = Uncertainty_analysis_func(True_FWMC,est_FWMC,True_Load,...,
    ADCI_Load,MDFW_Load,run_times,n_years)

% % create a True load matrix of the same size with ADCI and MDFW
True_Load_matrix = repmat(True_Load,1,run_times);
True_FWMC_matrix = repmat(True_FWMC,1,run_times);

% % 1. relative error 
rela_u_ADCI = 100*(ADCI_Load - True_Load_matrix)./True_Load_matrix;
rela_u_MDFW = 100*(MDFW_Load - True_Load_matrix)./True_Load_matrix;

rela_u_FWMC = 100*(est_FWMC - True_FWMC_matrix)./True_FWMC_matrix;

% % rela_u2 is to reshape the matrix into a one-dimentional vector 
rela_u2_ADCI = reshape(rela_u_ADCI,n_years * run_times,1);
rela_u2_MDFW = reshape(rela_u_MDFW,n_years * run_times,1);
rela_u2_FWMC = reshape(rela_u_FWMC,n_years * run_times,1);

% % percentiles
P1 = prctile(rela_u2_ADCI,[5 50 95]);  % get the 5th, 50th, 95th percentiels
P2 = prctile(rela_u2_MDFW,[5 50 95]);


% % 2. RMSE
rela_u3_ADCI = abs(rela_u2_ADCI);   % get the absolute values 
rela_u3_MDFW = abs(rela_u2_MDFW);
rela_u3_FWMC = abs(rela_u2_FWMC);

RMSE1 = (sum(rela_u3_ADCI.^2)/(n_years * run_times)).^0.5;
RMSE2 = (sum(rela_u3_MDFW.^2)/(n_years * run_times)).^0.5;
FWMC_rmse = (sum(rela_u3_FWMC.^2)/(n_years * run_times)).^0.5;

% % 3. ABS 
ABS_Err_1 = mean2(abs(ADCI_Load - True_Load_matrix));
STD_ABS_Err_1 = std2(abs(ADCI_Load - True_Load_matrix));
ABS_Err_2 = mean2(abs(MDFW_Load - True_Load_matrix));
STD_ABS_Err_2 = std2(abs(MDFW_Load - True_Load_matrix));

% % FWMC
FWMC_abs = mean2(abs(est_FWMC - True_FWMC_matrix));







