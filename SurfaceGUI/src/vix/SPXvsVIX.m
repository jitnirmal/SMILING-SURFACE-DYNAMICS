clear
clc
close all
%%
% Auther : Nirmaljit
% Description : % It take SNP 500 Index prices and VIX prices from 1990 - 2012 to find relations between index volatility vs VIX.
%Load data
%%
x = load('data\implvola.dat');

numOfRecords=length(x(:,1));
startRecord=1;
endRecord=numOfRecords;

startDate = datenum('31-Jan-1990');
endDate = datenum('31-Jan-2012');

xData = linspace(startDate,endDate,numOfRecords);
dat1=[xData;x(:,2)'];
dat2=[xData;x(:,3)'];

y1 = linspace(0,2000,5)
y2 = linspace(0,100,5)

%hold on

[AX,H1,H2] = plotyy(dat1(1,:), dat1(2,:),dat2(1,:), dat2(2,:));

set(AX,'XTick',[]) 
set(AX(1),'YTick',y1)
set(AX(2),'YTick',y2)

datetick('x','yyyy')

set(gca,'YMinorTick','on')

set(get(AX(1),'Ylabel'),'String','SPX Index')

set(get(AX(2),'Ylabel'),'String','VIX') 
xlabel('Time Scale') 
set(H1,'Color','b','LineWidth',2,'LineStyle','-')
set(H2,'Color','r','LineWidth',2,'LineStyle','-')
set(gca, 'YMinorTick', 'on');

hold off
t=title('Inverted relation of Index and Volatility') 
set(t, 'FontSize', 12);
