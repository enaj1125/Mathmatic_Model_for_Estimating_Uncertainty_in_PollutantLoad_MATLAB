function [x1] = Find_1st_nonNan_func(X)

x = X(~isnan(X));
temp = x(x>0);
x1 = temp(1);

end 