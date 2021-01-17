clear
clc
close all
addpath('..\iv','..\datasrv');
disp(' Fetching data... ');
tic
vDataFileOrig = load('..\..\db\optiondata.csv');
toc
[recDates recDateStr]=xlsread('..\..\db\recDates.xlsx');
disp(' Fetched data... ');
records=unique(vDataFileOrig(:,10));
for record=1:size(records);
    dateStr=datestr(datenum(recDateStr(record)));
    filter=find(vDataFileOrig(:,10)==record);
    vDataFile=vDataFileOrig(filter,:);
    filename=strcat('..\..\mat\npr\SPX-',dateStr,'.mat')
    figname=strcat('..\..\charts\surface\SPX-',dateStr,'-SmthSurf.jpeg')
    figTitle=strcat('SPX-',dateStr,' Smooth')
    [SO]=loadSurface(filename,vDataFile);
    
    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using VolSurface.
    
    h=figure;
    surf(SO.fMon,SO.fMat,SO.fIV)
    % colormap hsv
    % alpha(0.3)
    hold on
    iv=SO.fIVf;
    %scatter3(iv.fmoneyness(iv.fcallFilter),iv.fmaturity(iv.fcallFilter),iv.fimpliedVol(iv.fcallFilter),'o',...
    %    'MarkerEdgeColor','b',...
    %    'MarkerFaceColor','b');
    % scatter3(iv.fmoneyness(iv.fputFilter),iv.fmaturity(iv.fputFilter),iv.fimpliedVol(iv.fputFilter),'o',...
    %   'MarkerEdgeColor','g',...
    %    'MarkerFaceColor','g');
    
    xlabel('Moneyness')
    ylabel('Time to Maturity')
    zlabel('Implied Volatility')
    title(figTitle,...
        'FontWeight','bold',...
        'FontSize',16);
    print(h,'-djpeg',figname)
    close(h);
    
    h=figure;
    figname=strcat('..\..\charts\surface\SPX-',dateStr,'-mktSurf.jpeg')
    figTitle=strcat('SPX-',dateStr,' MarketSurface')
    x=iv.fmoneyness;
    y=iv.fmaturity;
    z=iv.fimpliedVol;
    firstmon=0.8;
    lastmon=1.2;
    firstmat=0;
    lastmat=1;
    stepwidth=[0.02 1/52];
    lengthmon=ceil((lastmon-firstmon)/stepwidth(1));
    lengthmat=ceil((lastmat-firstmat)/stepwidth(2));
    xlin=linspace(0.8,1.2,lengthmon+1);
    ylin=linspace(0,1,lengthmat+1);
    
    [X,Y] = meshgrid(xlin,ylin);
    f = TriScatteredInterp(x,y,z);
    Z = f(X,Y);
    
    surf(X,Y,Z);
   
    xlabel('Moneyness')
    ylabel('Time to Maturity')
    zlabel('Implied Volatility')
    title(figTitle,...
        'FontWeight','bold',...
        'FontSize',16);
    print(h,'-djpeg',figname)
    hold off
    
    close(h);
    
   
end