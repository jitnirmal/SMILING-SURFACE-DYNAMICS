date='15-Sep-2011';
path=strcat('..\..\charts\svi\',date);
mkdir(path);
filename = strcat('..\..\db\SPX-',date,'.xlsx');
addpath('..\iv','..\svi');
Rate = .01;
usePrecomputedIV=0;
data=xlsread(filename);
epsilon=0.00001;
tenorList=unique(data(1:end,9));
for index = 1:size(tenorList)
    tenor=tenorList(index)
    optionData=data;
    if(tenor~=0)
        filter=find(abs(optionData(2:end,9)-tenor)>epsilon);
        optionData(filter,:)=[];
    end
    
    
    RowSize=length(optionData(:,1));
    optionChain=zeros(RowSize,3);
    optionChain(:,1)=optionData(:,3); % Strike
    optionChain(:,2)=optionData(:,5);% Option Price
    optionChain(:,3)=(optionData(:,4)==1);% Call Put
    optionChain(:,4)=optionData(1:end,8);% precomputed IV
    optionChain(:,5)=optionData(1:end,9);% vol
    spot =optionData(1:1);
    
    ex1=find(optionChain(1:end,3)>0 & optionChain(:,1)<spot);
    ex2=find(optionChain(1:end,3)<1 & optionChain(:,1)>spot);
    ex3=find(optionChain(1:end,)<=0); %
    ex4=find(optionChain(1:end,5)<1);
    
    ex=[ex1;ex2;ex3;ex4];
    optionChain(ex,:)=[];
    
    [Parameters,optionChain] = SVIParams(optionChain,tenor,spot,Rate,usePrecomputedIV);
    
    [FitX FitY]=SVIFit(Parameters,optionChain(:,5));
    
    h=figure;
    
    plot(optionChain(:,5),optionChain(:,4),'o','LineWidth',2,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor','g',...
        'MarkerSize',5);
    xlabel('log(K/S)');
    ylabel('Vol (%)');
    titleName=strcat('SPX    Tenor : ',num2str(tenor));
    title(titleName);
    hold on;
    plot(FitX,FitY')
    legend('Market','Fitted');
    
    pfileName=strcat(path,'\-SPX-Tenor-',num2str(tenor),'.jpeg');
    print(h, '-djpeg', pfileName);
 
    close(h);
end