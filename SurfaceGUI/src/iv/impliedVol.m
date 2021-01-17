%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By: Nirmaljit Singh
% File: analysis.m
% Conducts the major analysis for part D. Uncomment lines in the Plot
% section to see the appropriate plots.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
%% Import all t he surfaces etc.

function  IVObject = impliedVol(data,filterOn)

optionChain = data;

if (filterOn == 1)
    ex1=find(optionChain(:,4)>1);
	ex2=find(optionChain(:,7)<0.8 |optionChain(:,7)>1.2);
	ex=[ex1;ex2];
    optionChain(ex,:)=[];
    moneyness=optionChain(:,7); 
    callF=find(optionChain(:,6)==1);  
    putF=find(optionChain(:,6)==0);  
end

Price=optionChain(:,1);
Strike=optionChain(:,2);
Rate=optionChain(:,3);
maturity=optionChain(:,4);
Value=optionChain(:,5);
Class=optionChain(:,6);
%ivh = msgbox('IV computation in progress. pls wait');
impliedVol = blsimpv(Price, Strike, Rate, maturity, Value,[],[], [],Class);

if (filterOn == 1)
    IVObject = struct('fmoneyness',moneyness,'fmaturity',maturity,'fimpliedVol',impliedVol,'fcallFilter',callF,'fputFilter',putF);
else
    IVObject = struct('fimpliedVol',impliedVol);
end
%close(ivh)
end