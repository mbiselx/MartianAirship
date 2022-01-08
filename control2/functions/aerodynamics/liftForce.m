function [Fa] = liftForce(AS, mars)
%LIFTFORCE Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('mars', 'var') || isempty(mars)
        load("data\mars.mat", 'mars');
    end
    
    Fa = -4/3* pi * AS.balloon.radius^3 * rho_atm(-AS.state.p(3)) * [0;0;mars.g];


end

