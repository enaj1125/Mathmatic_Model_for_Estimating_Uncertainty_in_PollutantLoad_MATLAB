
% % analysis all the error
error_data = xlsread('LOADEST_result.xlsx',3);
errors = reshape(error_data,[],1);

A_percentile = prctile(errors,[5 50 95]);

A_rmse = (sum(errors.^2)/length(errors)).^(0.5);