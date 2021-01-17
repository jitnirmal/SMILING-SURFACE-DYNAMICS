
%%
function  [optionChain,FitX,FitY] = sviVol(optionData,tenor,usePrecomputedIV)

% Auther : Nirmaljit
% Description : % We take SPX option quotes as of given date and 
% compute implied volatilities for all 14 expirations passed as tenor
% The result of fitting square-root SVI passed back for plotting. 
% Data was extracted from the excel file. For the calculation of the implied volatility, out of money data and close to the money data was used and the in the money data discarded. This is done as it is seen that in practice out of the money options are found to give better values of implied volatility. 

% Given mid implied volatilities ?ij = ?BS(ki, tj), compute mid option prices using the Black-Scholes formula.
% Fit the square-root SVI surface by minimizing sum of squared 

%% Inputs: 
%   optionData - option data required for np regression 
%   iv - precomputed implied volatility from option prices
% Output: 
%    [optionChain,FitX,FitY] -  
% FitX - fitted X for plotting
% FitY - fitted Y for plotting
% usePrecomputedIV  - Always true. (can cache the computation to matlab files)
%%
      
    RowSize=length(optionData(:,1));
    optionChain=zeros(RowSize,3);
    optionChain(:,1)=optionData(:,2); % Strike
    optionChain(:,2)=optionData(:,5);% Option Price
    optionChain(:,3)=(optionData(:,6)==1);% Call Put
    optionChain(:,4)=optionData(:,8);% precomputed IV
    optionChain(:,5)=optionData(:,9);% vol
    spot =optionData(1:1,1);
    rate =optionData(1:1,3);
    rate = 0.01;
    ex1=find(optionChain(:,3)>0 & optionChain(:,1)<spot);
    ex2=find(optionChain(:,3)<1 & optionChain(:,1)>spot);
    ex3=find(optionChain(:,2)<=0);
    ex4=find(optionChain(:,5)<1);
    
    ex=[ex1;ex2;ex3;ex4];
    optionChain(ex,:)=[];
    
    [Parameters,optionChain] = SVIParams(optionChain,tenor,spot,rate,usePrecomputedIV);
    
    [FitX FitY]=SVIFit(Parameters,optionChain(:,5));
end