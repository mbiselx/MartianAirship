close all
clc
clear

addpath("functions\utilities\")
addpath("functions\parameters")
addpath("functions\aerodynamics")
addpath("functions\plotting")

%% set parameter

airship_params

v_air   = [10; 0; 0];       % [m/s]
% v_air   = [0; 0; 0];       % [m/s]

T0      = 200;              % [N] % nominal total propulsion 
% T0      = 400;              % [N] % nominal total propulsion 
D       = 4;                % [m] % propeller diameter
nb_prop = 4;
% P0 = propulsionForce('init', T0, 10, D, nb_prop, p(:,1))
P0      = 3.5e3;            % [W] % nominal total power
% P0      = 8e3;            % [W] % nominal total power

dt = .01;
integrate   = @(x, i) (.5*(x(:,i) + x(:,i-1))*dt);

figure()
lh = [];
ll = {};

for h  = -1000:-1000:-4000

    t  = 0:dt:150;
    p  = zeros(3, length(t));
    v  = zeros(3, length(t));
    a  = zeros(3, length(t));
    Fp = zeros(3, length(t));
    Fd = zeros(3, length(t));

    p(:,1) = [0; 0; -h];
    v(:,1) = v_air;
%     P0 = propulsionForce('init', T0, 10, D, nb_prop, p(:,1))
    propulsionForce('init', P0, D, nb_prop);
    Fp(:,1) = propulsionForce('get', v_air - v(:,1), p(:,1));
    Fd(:,1) = dragForce(v_air - v(:,1), p(:,1));
    a(:,1) = (Fd(:,1) - Fp(:,1)) / (m+addedMass(p(:,1)));
    for i = 2:length(t)

        Fp(:,i) = propulsionForce('get', v_air - v(:,i-1), p(:,i-1));
        Fd(:,i) = dragForce(v_air - v(:,i-1), p(:,i-1));
        a(:,i)  = (Fd(:,i) - Fp(:,i))/(m+addedMass(p(:,i-1)));
        v(:,i)  = v(:,i-1) + integrate(a, i);
        p(:,i)  = p(:,i-1) + integrate(v, i);

        if v(1,i) < 0   % if the balloon can reverse its direction
            Fp = Fp(:,1:i);
            Fd = Fd(:,1:i);
            a  = a(:,1:i);
            v  = v(:,1:i);
            p  = p(:,1:i);
            break;
        end
    end

    if i < length(t)
        fprintf("Time to stop: %.1f s \n", t(i));
        fprintf("distance to stop: %.1f m\n", p(1,end));
        t = t(1:i);
    else
        disp("balloon did not stop in time");
    end

    subplot(3,1,1)
%         plot(t, a(1,:)), hold on
%         xlabel("time [s]"), ylabel("deceleration [m / s^2]")
        plot(t, Fp(1,:)), hold on
        xlabel("time [s]"), ylabel("Propulsion [N]")
        grid on
        axis tight
    subplot(3,1,2)
        plot(t, v(1,:)), hold on
        xlabel("time [s]"), ylabel("velocity [m / s]")
        grid on
        axis tight
    subplot(3,1,3)
        lh = [lh, plot(t, p(1,:))]; hold on
        ll = [ll, {sprintf("%d m, %.0f g/m^3", h, rho_atm(h) * 1000)}];
        xlabel("time [s]"), ylabel("distance [m]")
        grid on
        axis tight
end

legend(lh, ll, 'location', 'southeast')
sgtitle(sprintf("Stopping distance/time for %.1f kW (~%d N) propulsion", P0/1000, T0))
