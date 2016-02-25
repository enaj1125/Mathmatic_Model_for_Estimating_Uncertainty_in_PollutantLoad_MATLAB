% % given matrix_index, find the values in data_mat; 
% % matrix_index have zeros
function [newdata] = extractdata_func(matrix_index,data_mat)
% % index1: 
zeros_index1 = find(~matrix_index);
zeros_index2 = matrix_index(find(~matrix_index));
nozeros_index1 = find(matrix_index);
nozeros_index2 = matrix_index(find(matrix_index));
temp = matrix_index;
temp(zeros_index1) = 0;
temp(nozeros_index1) = data_mat(nozeros_index2);

newdata = temp;

end 