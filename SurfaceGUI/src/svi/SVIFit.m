	function [SVIx,SVIy]=SVIFit(Parameters,Moneyness)

% Description : %This function generates two vectors for plotting the fitting curve.
%Paramters is a vector of SVI paramters in the order of a,b,sigma,rho and m.
%Moneyness is a vector containing the log of K over F in the same number of
%the observations.
%% Inputs: 
%   Parameters - pre computed parameters for SVI Fitting 
%   Moneyness - Option Moneyness
% Output: 
%    [optionChain,FitX,FitY] -  
% FitX - fitted X for plotting
% FitY - fitted Y for plotting
%%


    SVIvol=sqrt(Parameters(1)+Parameters(2).*(Parameters(4).*(Moneyness-Parameters(5))+sqrt((Moneyness-Parameters(5)).^2+Parameters(3)^2)));
    
    SVItemp(:,1)=Moneyness;
    SVItemp(:,2)=SVIvol;
    SVInew=sortrows(SVItemp);
    SVIx=SVInew(:,1);
    SVIy=SVInew(:,2);
end