function [out] = dragForce(AS, v_air, drag_type)


    if nargin < 3
        drag_type = 'BH';
    end

    nu_atm  = 1.23E-05; % [Pa s]
    z       = -AS.state.p(3);
    r_b     = [sin(AS.state.theta); 0; cos(AS.state.theta)] * ...
              (AS.CoM - AS.balloon.radius - AS.gondola.height/2) ;
    v       = v_air - (AS.state.v + cross([0;AS.state.omega;0], r_b));
    
    RE      = 2*rho_atm(z) * AS.balloon.radius / nu_atm * (vecnorm(v)+1e-10); % cheat so that RE is not 0

    switch drag_type
        case "WC" % worst case
            drag_coef = 0.47+24/(RE+0.01);
            drag_coef(RE > 4.5e5) = 0.3;   % unsurprisingly, non-continuous stuff is bad
        case "BH" % balloon handbook
            drag_coef = 24/RE + 2.6*(RE/5)/(1+(RE/5)^1.52) + ...
                        0.411*(RE/263000)^-7.94/(1+(RE/263000)^-8) + ...
                        0.25*RE/1e6/(1+RE/1e6);
        case "PA" % Pierre-Alain Haldi
            if RE < 1
                drag_coef = 24./RE;
            elseif RE < 1e3
                drag_coef = 18.5./(RE.^.6); % unsurprisingly, non-continuous stuff is bad
            elseif RE < 3e5
                drag_coef = .5;
            else
                drag_coef = .07;
            end

    end


     out = sign(v) .* rho_atm(z)/2 * pi * AS.balloon.radius^2 .* drag_coef .* v.^2;


end
