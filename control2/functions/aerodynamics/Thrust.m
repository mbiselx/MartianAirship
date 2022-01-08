function [varargout] = Thrust(P, v, D, T0, h)
%THRUST calculate the thrust and efficiency for an ideal propeller
%   param P       : Power into propeller
%   param v       : air velocity away from propeller
%   param D       : diameter of propeller
%   param T0      : initial guess at the thrust
%   param h       : altitude 

    % initial guess for the thrust (closer -> quicker convergence)
    if nargin < 5
        T = 0; % [N]
    else 
        T = T0;
    end
    

    if abs(v) < 1e-16   % fix sigularity issue by ignoring it
        v = 1e-16;
    end
    
    % use iteration to solve for T bc I flunked Analyse I, II, III & IV
    TT  = Inf; % [N]
    c1  = 2 * P / v;
    if nargin < 6 
        c2  = pi / 8 * rho_atm()  * (D * v)^2;
    else 
        c2  = pi / 8 * rho_atm(h) * (D * v)^2;
    end
    while abs(TT - T) > .1   % arbitrary iteration halt 
        TT = T;
        T  = c1 / (1 + sqrt(1 + T/c2));
    end
    

    if nargout < 2
        varargout = {T};
    else 
        eta = T*v/P;
        varargout = {T, eta};
    end

end

