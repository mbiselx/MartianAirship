%% paternoster
close all
clc
clear

addpath("functions\utilities\")
addpath("functions\parameters\")
addpath("functions\aerodynamics\")
addpath("functions\plotting\")
addpath("data\")

%% parameters 

load("data\airship.mat")

v_air   = [-10; 0; 0];       % [m/s]
% v_air   = [0; 0; 0];       % [m/s]

P0 = propulsionForce('init', airship.propulsion.nb_plant * airship.propulsion.plant.power_in, ...
                airship.propulsion.plant.propeller.diameter, ...
                airship.propulsion.nb_plant * airship.propulsion.plant.nb_prop);



figure()
lh = [];
ll = {};

for h  = -1000:-2000:-5000
% for h  = -1000:-1000:-4000

    dt      = .01;
    t       = 0:dt:150;
    
    % allocate memory 
    p  = zeros(3, length(t));
    v  = zeros(3, length(t));
    a  = zeros(3, length(t));
    Fp = zeros(3, length(t));
    Fd = zeros(3, length(t));
    
    airship.state.p = [0; 0; -h];
    airship.state.v = v_air;
    airship.state.a = [0; 0; 0];
    
    for k = 1:length(t)

        [a(:,k), Fp(:,k), Fd(:,k)] = dynamics(airship, v_air);
    
%         a(:, k) = dynamics(airship, v_air);
        v(:, k) = airship.state.v + integrate(a, dt, k);
        p(:, k) = airship.state.p + integrate(v, dt, k);
    
        airship.state.a = a(:, k);
        airship.state.v = v(:, k);
        airship.state.p = p(:, k);
    
        if v(1,k) > 0   % the airship has reversed its direction
            Fp = Fp(:,1:k);
            Fd = Fd(:,1:k);
            a  = a(:,1:k);
            v  = v(:,1:k);
            p  = p(:,1:k);
            break
        end
    
    end
    
    if k < length(t)
        fprintf("Time to stop: %.1f s \n", t(k));
        fprintf("distance to stop: %.1f m\n", abs(p(1,end)));
        t = t(1:k);
    else
        disp("balloon did not stop in time");
    end
    
    subplot(3,1,1)
        plot(t, a(1,:)), hold on
        xlabel("time [s]"), ylabel("deceleration [m / s^2]")
        grid on
        axis tight
    subplot(3,1,2)
        plot(t, -v(1,:)), hold on
        xlabel("time [s]"), ylabel("velocity [m / s]")
        grid on
        axis tight
    subplot(3,1,3)
        lh = [lh, plot(t, -p(1,:))]; hold on
        ll = [ll, {sprintf("%d m, %.0f g/m^3", h, rho_atm(h) * 1000)}];
        xlabel("time [s]"), ylabel("distance [m]")
        grid on
        axis tight

end

legend(lh, ll, 'location', 'southeast')
sgtitle(sprintf("Stopping distance/time for %.1f kW propulsion", P0/1000))


%% simulation dynamics 

function [a, Fp, Fd] = dynamics(AS, v_air)
    Fp = propulsionForce('get', AS.state.v - v_air, AS.state.p);
    Fd = dragForce(AS, v_air);

    a = (Fp + Fd)/(AS.mass + AS.ballonnet.ballast + addedMass(AS));
end