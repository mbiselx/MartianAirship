function [ma] = addedMass(p)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

airship_params

ma = 2/3 * pi * r_b^3 * rho_atm(-p(3));

end

