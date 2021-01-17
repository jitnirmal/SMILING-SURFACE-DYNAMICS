function [Parameters,data] = SVIParams(data,tenor,S0,Rate,usePrecomputedIV)
%%
% Description : %This function generates two vectors for plotting the fitting curve.
%Paramters is a vector of SVI paramters in the order of a,b,sigma,rho and m.
%Moneyness is a vector containing the log of K over F in the same number of
%the observations.
%% Inputs:
%data - option data
%tenor - tenor for option maturity
%S0 - spot
%Rate - risk free rate of return
%usePrecomputedIV - not used
%%
%get implied vol
    for j = 1:size(data,1)
        data(j,4) = bisection(data(j,2), S0, data(j,1), Rate, tenor, data(j,3));
    end
    
    data(:,5) = log(data(:,1)./S0);

    Parameters=(fminsearch(@(SVIparameters)SVIPCalc(data,SVIparameters),[0.015 0.05 0.127 -0.568 0.165],optimset('MaxIter',1000000,'MaxFunEvals',1000000000)));
end
