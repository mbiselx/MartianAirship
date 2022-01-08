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
load("data\mars.mat")

T_vent      = 60^2;
v_air       = [0; 0; 0];       % [m/s]

lh = [];
ll = {};
h = -1000:-2000:-5000;

for i  = 1:length(h)
    disp(h(i))

    dt       = .1;
    t        = 0:dt:5000;

    % allocate memory 
    p        = zeros(3, length(t));
    peq      = zeros(3, length(t));
    v        = zeros(3, length(t));
    a        = zeros(3, length(t));
    Fa       = zeros(3, length(t));
    Fd       = zeros(3, length(t));
    Fg       = zeros(3, length(t));

    airship.state.p = [0; 0; -h(i)];
    airship.state.v = v_air;
    airship.state.a = [0; 0; 0];

    airship.ballonnet.ballast = 4/3*pi*airship.ballonnet.radius^3 * ...
                                airship.balloon.superpressure * rho_atm(-airship.state.p(3));

    ballast_vent_rate = airship.ballonnet.ballast/T_vent;

    fa = liftForce(airship);
    airship.mass = (-fa(3))/mars.g - airship.ballonnet.ballast;
    disp(airship.mass)
    fa = liftForce(airship)/rho_atm(-airship.state.p(3));

    for k = 1:length(t)

        % dynamics
        [a(:,k), Fa(:,k), Fd(:,k), Fg(:,k)] = dynamics(airship, mars, v_air);
        v(:, k) = airship.state.v + integrate(a, dt, k);
        p(:, k) = airship.state.p + integrate(v, dt, k);

        airship.state.a = a(:, k);
        airship.state.v = v(:, k);
        airship.state.p = p(:, k);

        % equilibrium altitude
        peq(3,k) = -equilibrium_altitude(airship);

        % vent ballonnet 
        airship.ballonnet.ballast = max(0, airship.ballonnet.ballast - ballast_vent_rate*dt); 

    end

   
    figure(1)
    C = colororder;
    subplot(3,1,1)
        plot(t, Fg(3,:), '--', "Color", C(i,:)), hold on
        plot(t, -Fa(3,:),"Color", C(i,:)), hold on
        xlabel("time [s]"), ylabel("Force [N]")
        grid on
        axis tight
    subplot(3,1,2)
        plot(t, -v(3,:), "Color", C(i,:)), hold on
        xlabel("time [s]"), ylabel("velocity [m / s]")
        grid on
        axis tight
    subplot(3,1,3)
        lh = [lh, plot(t, -p(3,:)-h(i), "Color", C(i,:))]; hold on
        plot(t, -peq(3,:)-h(i), '--', "Color", C(i,:))
        ll = [ll, {sprintf("%d m", h(i))}];
        xlabel("time [s]"), ylabel("\Deltah [m]")
        grid on
        axis tight

    figure(3)
    plot3(t, -p(3,:)  -h(i), rho_atm(h(i)) - rho_atm(-p(3,:)),   '-',  "Color", C(i,:) ), hold on
    plot3(t, -peq(3,:)-h(i), rho_atm(h(i)) - rho_atm(-peq(3,:)), '--', "Color", C(i,:) ), hold on
    xlabel("time of flight [s]"), ylabel("\Deltah [m]"), zlabel("\Delta\rho_{atm} [Pa]")
    grid on

end
figure(1)
legend(lh, ll, 'location', 'southeast')

%% simulation dynamics 

function [a, Fa, Fd, Fg] = dynamics(AS, mars, v_air)
    Fa = liftForce(AS, mars);
    Fd = dragForce(AS, v_air);
%     Fd = zeros(3,1);
    Fg = (AS.mass + AS.ballonnet.ballast) * [0;0;mars.g];

    a = (Fa + Fd + Fg)/(AS.mass + AS.ballonnet.ballast + addedMass(AS));
end
