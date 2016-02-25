%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Resample %%%%%%%%%%%%%%%%%%
function [matrix_index, day_index, subday_index, n_sample_mat] = resample_func(flow_mat, sampleday_matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%% 1.  define indexes to use
[I, J] = size(sampleday_matrix); %%%% I rows-range of numbers; J sampletimes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% 2. To find how many sample numbers of one day, create a
%%%%% "sample_n_matrix(I,J)"
logic1 = flow_mat~=0;
logic1 = reshape(logic1,50,366);
logic1 = logic1';
n_sample_mat = sum(logic1,2);         %%% create such a matrix for one year
%%%%%% based on the previous info, find the the sample num of selected 
%%%%%% sampled days
sample_n_matrix = zeros([I,J]); 
for i=1:I                              %%% loop through years
    temp = sampleday_matrix(i,:);      %%% find bad dayindex (<0 && >366)
    index = find(temp > 0 & temp < 367);
    sample_n_matrix(i,index) = n_sample_mat(temp(index));    
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% 3. Randomely pick up one subday sample from the "sample_n_matrix". 
subday_matrix = zeros([I,J]);
for i = 1:I
    for j = 1:J
        if sample_n_matrix(i,j)>0  %%%% if no data on this day, value = 0
            subday_matrix(i,j) = randi(sample_n_matrix(i,j),1);
        end 
    end        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% 4. Decide which day should be used for that resample by determing the
%%%%% row index of sampleday_matrix
% % % count the total number of sample could be used for one-day's resample  
sample_temp = zeros([I,J]);
nozero_sample_temp = sample_n_matrix ~= 0;
sum_subday_n = sum(nozero_sample_temp,1); %%%%% count how many sampledays are available for 
%%%%%% one sampling pick-up
row_num = zeros(1,J); %%%%% then pick up one day from the avaialbe and create row_num 
for j = 1: J
    temp = sum_subday_n(j);
    if temp >0 
        row_num(j) = randi (sum_subday_n(j),1);  %%%%% random pick up , find the relative row index   
    end 
end
%%%%% find row index of sampleday that were picked by calcuating the row_index 
adj_sample_n = cumsum(nozero_sample_temp,1); %%%% find the relative index by accumulating
row_index = zeros(1,j);   %%%%%% match the relative 
for j=1:J
    temp = find(adj_sample_n(:,j) == row_num(j));
    temp = temp(1);
    row_index(j) = temp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 5. find day index and sub-daily index
%%%%% find the sub-daily index based on subday_matrix
col_index = 1: J;
day_index = zeros(J,1);
subday_index = zeros(J,1);
for j = 1:J
    day_index(j) =  sampleday_matrix(row_index(j), col_index(j)); 
    subday_index(j) = subday_matrix(row_index(j), col_index(j));
end 

%%%%% 6. output and write into a excel file
matrix_index = (day_index-1)*50 + subday_index;
zero_ind = find(subday_index == 0);
matrix_index(zero_ind) = 0;

end 