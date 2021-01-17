
%%
function  [MON,MAT,IV] = npregression(data,iv)

% Auther : Nirmaljit
% Description : % the kernel regression procedures employed in order to obtain 
% implied volatility surface time series on a given grid of 
% maturities MAT  and moneyness MON.We use quadratic kernels of order 2
% Important parameters are the bandwidth parameters h1, h2, 
% which determine the degree of smoothing

%% Inputs: 
%   data - option data required for np regression 
%   iv - precomputed implied volatility from option prices
% Output: 
%    [MON,MAT,IV] -  grid of moneyness, maturities and smoothened Implied
%    Vols.
% MON - Moneyness
% MAT - Maturires
% IV  - Smooth volatilities
%%
optionChain = data;

firstmon=0.8;
lastmon=1.2;
firstmat=0;
lastmat=1;
stepwidth=[0.02 1/52];
lengthmon=ceil((lastmon-firstmon)/stepwidth(1));
lengthmat=ceil((lastmat-firstmat)/stepwidth(2));
mongrid=linspace(0.8,1.2,lengthmon+1);
matgrid=linspace(0,1,lengthmat+1);

[MON, MAT]=meshgrid(mongrid,matgrid);
gmon=lengthmon+1;
gmat=lengthmat+1;
uu=size(optionChain);
v=uu(1,1);
beta=zeros(gmat,gmon);
j=1;

%nph = waitbar(0,'Kernel smoothing in progress. pls wait');

while (j<gmat+1);
    k=1;
    while (k<gmon+1);
		Y=iv;
        h1=0.1;
        h2=0.75;
        W=zeros(v,v); %Kernel matrix
        i=1;
        X=zeros(v,3);
        while (i<v+1);
            u1=(optionChain(i,7)-MON(j,k));
            u2=(optionChain(i,4)-MAT(j,k));
            X(i,:)=[1,u1, u2];
            u1=u1/h1;
			u2=u2/h2;
			aa=15/16*(1-u1^2)^2*(abs(u1) <= 1)/h1;
            bb=15/16*(1-u2^2)^2*(abs(u2) <= 1)/h2;
            W(i,i)=aa*bb;
            i=i+1;
        end
        est=(X'*W*X)\(X'*W*Y);
        beta(j,k)=est(1);
        k=k+1;
    end
    j=j+1;
 %   waitbar(j/(gmat+1))
end
%close(nph) 

IV=beta;
end