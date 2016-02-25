rmse1 = (sum(u1.^2,2)/500).^0.5;  %%%% u1 and u2 are the 500* n_years matrix

rmse2 = (sum(u2.^2,2)/500).^0.5;

missingdays = 365 - sum_nsample;
missingdays(missingdays > 100)=[];


%%% plot 
font_size = 18;

subplot(1,2,1)
plot(missingdays,rmse1,'o','MarkerEdgeColor','k',...
                'MarkerFaceColor','k',...
                'MarkerSize',10);
set(gca,'Fontsize',font_size)
ylim([0,100]);


subplot(1,2,2)
plot(missingdays,rmse2,'o','MarkerEdgeColor','k',...
                'MarkerFaceColor','k',...
                'MarkerSize',10);
set(gca,'Fontsize',font_size)
ylim([0,100]); 

xlabel('Missing data days','Fontsize',font_size)
ylabel('Uncertainty interms of CV_{Calculation}(%)','Fontsize',font_size)


            