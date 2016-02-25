clc
clear

% how many groups 

%group_name = ['one', 'two', 'three', 'four', 'five', 'six', 'seven',...,
        %'eight', 'nine', 'ten', 'ele'];
sizes = zeros(3,2);
x = cell(3,1);
indx = 1;
for i = [5, 10, 20]
    Run_times = i;  
    [rela_u2_ADCI,rela_u2_MDFW,RMSE1, RMSE2] = iterationplot(Run_times);
    x{indx} = rela_u2_ADCI;
    sizes(indx,:) = size(rela_u2_ADCI);
    indx = indx + 1;
    
end

group = [repmat({'First'}, sizes(1,:)); repmat({'Second'}, sizes(2,:)); repmat({'Third'}, sizes(3,:))];

boxplot([x{1};x{2};x{3}], group)