function [year,month,day] = split_date(a)

year = floor(a/10000);
month = floor((a - year*10000)/100);
day = a - year*10000 - month*100;

end 