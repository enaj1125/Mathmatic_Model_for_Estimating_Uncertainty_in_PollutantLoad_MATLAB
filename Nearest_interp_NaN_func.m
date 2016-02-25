function [Data] = Nearest_interp_NaN_func(data)

t = linspace(0.1, 10, numel(data));
nans = isnan(data);

% nearest neighbor
data(nans) = interp1(t(~nans), data(~nans), t(nans), 'nearest');

Data = data;