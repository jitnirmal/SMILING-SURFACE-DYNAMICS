function  [optionChain,FitX,FitY] = sviVol(optionData,filterOn)
    
    RowSize=length(optionData(:,1));
    optionChain=zeros(RowSize,3);
    optionChain(:,1)=optionData(:,3); % Strike
    optionChain(:,2)=optionData(:,5);% Option Price
    optionChain(:,3)=(optionData(:,4)==1);% Call Put
    optionChain(:,4)=optionData(:,8);% precomputed IV
    optionChain(:,5)=optionData(:,7);% vol
    spot =optionData(1:1);
   
    ex1=find(optionChain(:,3)>0 & optionChain(:,1)<spot);
    ex2=find(optionChain(:,3)<1 & optionChain(:,1)>spot);
    ex3=find(optionChain(:,2)<=0);
    ex4=find(optionChain(:,5)<1);
    
    ex=[ex1;ex2;ex3;ex4];
    optionChain(ex,:)=[];
    
    [Parameters,optionChain] = SVIParams(optionChain,tenor,spot,Rate,usePrecomputedIV);
    
    [FitX FitY]=SVIFit(Parameters,optionChain(:,5));
end