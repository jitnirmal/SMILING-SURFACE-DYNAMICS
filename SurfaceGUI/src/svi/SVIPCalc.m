function[SLS]=SVIPCalc(optionChain,params)
%%
% Description : %This function is defined as the objective function in the least square
%%process.
%% Inputs:
%optionChain - option data
%params - intermediate params for curve fitting
%%

    SLS=0;
    DSize=length(optionChain(:,1));
    for i=1:DSize
        %Temp=sqrt(params(1)+params(2)*(params(4)*(optionChain(i,5)-params(5))+sqrt((optionChain(i,5)-params(5))^2+params(3)^2)))-optionChain(i,4);
        Temp=params(1)+params(2)*(params(4)*(optionChain(i,5)-params(5))+sqrt((optionChain(i,5)-params(5))^2+params(3)^2))-optionChain(i,4)^2;
        SLS=SLS+Temp^2;
    end

end