function [Fa] = liftForce(p)
%LIFTFORCE Summary of this function goes here
%   Detailed explanation goes here

    airship_params
    
    Fa = -4/3* pi * r_b^3 * rho_atm(-p(3,:)) * g;


end

