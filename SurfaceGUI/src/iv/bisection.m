function [volatility] = bisection(OptPrice,S,K,r,T,IsCall)

%%%%
% This function uses bisection method to find implied volatility.
%
% Expression:
%   [volatility,step_no] = bisection(OptPrice,S,K,r,T,IsCall)
%
% Input Parameter list:
%   OptPrice    The option price
%   S           Underlying price
%   K           Strike price
%   r           Risk-free rate. ie: 0.05 for 5% per year
%   T           Tenor, number of years to mature. ie: 0.5 for a half year
%   IsCall      A boolean parameter that indicates whether it is a call 
%               option. For put option, transfer false, otherwise true.
%
% Output Parameter list:
%   volatility  The implied volatility
%   step_no     The number of steps the bisection algorithm iterates


    % define anonymous functions that used to price options according to 
    % Black-Scholes
%%
      d1 = @(F, K, sigma, T)((log(F/K)+((sigma^2/2))*T)/(sigma*sqrt(T)));
    d2 = @(F, K, sigma, T)(d1(F, K, sigma, T)-sigma*sqrt(T));
    CallPrice = @(F, K, r, T, sigma) (exp(-r*T) * ((F*cdf('Normal', d1(F, K, sigma, T), 0, 1)-K*cdf('Normal', d2(F, K, sigma, T), 0, 1))));
    PutPrice = @(F, K, r, T, sigma) (exp(-r*T) * (-(F*cdf('Normal', -d1(F, K, sigma, T), 0, 1)-K*cdf('Normal', -d2(F, K, sigma, T), 0, 1))));
    
    % determine the right price function according to the option type
    if (IsCall == 1)
        price_fun=CallPrice;
    else
        price_fun=PutPrice;
    end
    
    % define upper bound and initialize it
    ub_vo = 0;
    % initialize the output parameter step_no
    step_no = 0;
    
    %=====================================================================
    % The following codes in this block find the appropriate lower bound
    % and upper bound.
    %
    % The fundamental concept is that let computer try some volatility
    % values each with a fixed difference, and find the first-tight upper
    % bound when the first trying price that is greater than the given
    % price, OptPrice, is found. This process is like moving a window in
    % window frame from left to right. The left side of the window
    % represents the lower bound. The right side represents a upper bound.
    % Moving the window from where the lower bound is zero to such a place
    % that the implied volatility (like a perpendicular string across the
    % window frame) is just between the two sides of the window. Each time
    % the window only moves to a distance equal to the length of its width.
    %
    % set window size to 0.1
    win_size=0.1;
    % moving window and find the upper bound
    while(price_fun(S,K,r,T,ub_vo) <  OptPrice)
        ub_vo = ub_vo + win_size;
    end
    % set lower bound
    lb_vo = ub_vo - win_size;
    % the mid_vo is the mean value between upper and lower bounds. This is
    % also the trying volatility in bisection process.
    mid_vo = ub_vo - win_size / 2;
    %=====================================================================
    
    % ***** MARK 001 *****
    
    % this while structure try to find the implied volatility by bisection
    % method.
    while( true )
        % find the trying price
        try_price = price_fun(S,K,r,T,mid_vo);
        % count iteration step
        step_no = step_no + 1;
        
        if(step_no > 100 || mid_vo < 0)
            volatility = -1;
            return;
        end
        
        % This structure judges when to stop the whole iteration thing.
        % If the difference between trying price and the real option price 
        % is less than 0.1%, make computer realize the implied volatility 
        % is found. 
        % This judgement can be changed to another form that the difference
        % of the last two trying volatility is no greater than 0.1%. To
        % achieve this, define a variale last_mid_vo at line 69 and assign
        % an "impossible" value, such like -10, to it. Then change the
        % following "if" judgement by replacing what in the parethesis by
        % the comment in one line below. Finally, remove the percentage
        % mark in line 105.
        if ( abs( try_price - OptPrice ) <= 0.001 * OptPrice )
            % abs(last_mid_vo - mid_vo ) <= 0.001 * last_mid_vo
            break;
        else
            if( try_price > OptPrice )
                ub_vo = mid_vo;         % use the left interval
            else
                lb_vo = mid_vo;         % discard the left interval
            end
            % ***** MARK 002 *****
            % last_mid_vo = mid_vo;
            mid_vo = (ub_vo - lb_vo) / 2 + lb_vo ;
        end
    end
    
    volatility = mid_vo;
end

