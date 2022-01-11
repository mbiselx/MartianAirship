function [ma] = addedMass(AS)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    ma = 2/3 * pi * AS.balloon.radius^3 * rho_atm(-AS.state.p(3));

end

