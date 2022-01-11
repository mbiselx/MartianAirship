function heq = equilibrium_altitude(airship)
%EQUILIBRIUM_ALTITUDE Summary of this function goes here
%   Detailed explanation goes here

    C = (airship.mass + airship.ballonnet.ballast) / (4/3* pi * airship.balloon.radius^3);
    [~, idx] = min(abs(rho_atm((-5000):20:(+1000)) - C));
    heq = -5000 + 20*idx;
    [~, idx] = min(abs(rho_atm((heq-40):.1:(heq+40)) - C ));
    heq =  heq-40 + .1*idx; 
    [~, idx] = min(abs(rho_atm((heq-.2):.001:(heq+.2)) - C ));
    heq =  heq-.2 + .001*idx; 

end

