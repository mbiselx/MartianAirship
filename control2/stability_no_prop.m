%% paternoster
close all
clc
clear

addpath("functions\utilities\")
addpath("functions\parameters\")
addpath("functions\aerodynamics\")
addpath("functions\plotting\")
addpath("data\")

%% 

load("data\airship.mat")
load("data\mars.mat")

v_air   = [-10; 0; 0];       % [m/s]

dt = .005;                          % [s] simulation timestep
t = 0:dt:400;                       % [s] simulation duration

% allocate memory 
theta       = zeros(1, length(t));
omega       = zeros(1, length(t));
alpha       = zeros(1, length(t));
a           = zeros(3, length(t));
v           = zeros(3, length(t));
p           = zeros(3, length(t));
Fa          = zeros(3, length(t));
Fd          = zeros(3, length(t));
Fg          = zeros(3, length(t));
Fp          = zeros(3, length(t));

% find equilibrium position
heq = equilibrium_altitude(airship);

% initialize 
airship.state.p     = [0; 0; -heq];
airship.state.v     = [0; 0; 0];
airship.state.a     = [0; 0; 0];
airship.state.alpha = 0;
airship.state.omega = 0;
airship.state.theta = 0;

% expected frequency 
L = airship.balloon.radius + airship.gondola.height/2;
I = airship.balloon.inertia + airship.gondola.inertia + airship.gondola.mass * L^2;
T_exp = 2*pi*sqrt(I/(airship.mass* mars.g * L))

% meff = airship.mass + addedMass(airship);
% rho_as = airship.mass/(4/3 * pi * airship.balloon.radius^3);
% k = abs(rho_as/rho_atm(heq) - 1);
% 
% T_exp = 2*pi/sqrt(meff/k * L/mars.g)


% P0 = propulsionForce('init', airship.propulsion.nb_plant * airship.propulsion.plant.power_in, ...
%                 airship.propulsion.plant.propeller.diameter, ...
%                 airship.propulsion.nb_plant * airship.propulsion.plant.nb_prop);
P0 = propulsionForce('init', airship.propulsion.nb_plant * 0, ...
                airship.propulsion.plant.propeller.diameter, ...
                airship.propulsion.nb_plant * airship.propulsion.plant.nb_prop);


assert(all(abs(liftForce(airship) + (airship.mass + airship.ballonnet.ballast) * [0;0;mars.g]) < 1))


wb = waitbar(0);
kk = 0;
for k = 1:length(t)
    
    if k == 1
        [a(:,k), alpha(:,k), F] = dynamics(airship, mars, v_air, 0, dt);
    else
        [a(:,k), alpha(:,k), F] = dynamics(airship, mars, v_air, alpha(:,1:k-1), dt);
    end
    v(:, k)     = airship.state.v       + integrate(a, dt, k);
    p(:, k)     = airship.state.p       + integrate(v, dt, k);
    omega(k)    = airship.state.omega   + integrate(alpha, dt, k);
    theta(k)    = airship.state.theta   + integrate(omega, dt, k);

    Fp(:,k) = F{1};
    Fd(:,k) = F{2};
    Fa(:,k) = F{3};
    Fg(:,k) = F{4};

    airship.state.a = a(:, k);
    airship.state.v = v(:, k);
    airship.state.p = p(:, k);
    airship.state.alpha = alpha(k);
    airship.state.omega = omega(k);
    airship.state.theta = theta(k);

    kk = kk + 1;
    if kk > 50
        waitbar(k/length(t), wb)
        kk = 0;
    end

end
disp("simulation done")
close(wb)

%% plot

figure(1)
sgtitle("horizontal dynamics")
subplot(3,1,1)
    plot(t, a(1,:))
    xlabel("time [s]"), ylabel("a [m / s^2]")
    grid on
    axis tight
subplot(3,1,2)
    plot(t, v(1,:))
    xlabel("time [s]"), ylabel("v [m / s]")
    grid on
    axis tight
subplot(3,1,3)
    plot(t, p(1,:))
    xlabel("time [s]"), ylabel("p [m]")
    grid on
    axis tight

figure(2)
sgtitle("vertical dynamics")
subplot(3,1,1)
    plot(t, a(3,:))
    xlabel("time [s]"), ylabel("a [m / s^2]")
    grid on
    axis tight
subplot(3,1,2)
    plot(t, v(3,:))
    xlabel("time [s]"), ylabel("v [m / s]")
    grid on
    axis tight
subplot(3,1,3)
    plot(t, -p(3,:))
    xlabel("time [s]"), ylabel("p [m]")
    grid on
    axis tight

figure(3), clf
sgtitle("angular dynamics")
subplot(3,1,1)
    plot(t, alpha)
    xlabel("time [s]"), ylabel('\alpha [rad / s^2]')
    grid on
    axis tight
subplot(3,1,2)
    plot(t, rad2deg(omega))
    xlabel("time [s]"), ylabel('\omega [deg / s]')
    grid on
    axis tight
subplot(3,1,3)
    plot(t, rad2deg(theta))
    hold on
    N = ceil(17.3/dt);
    plot(t, rad2deg(filter(ones(1,N)/N, 1, theta)), 'k', 'LineWidth', 1)
    legend("inst.", "mean")
    xlabel("time [s]"), ylabel('\theta [deg]')
    grid on
    axis tight

figure(4) 
title("Forces")
plot(t, Fp(1,:)); hold on
plot(t, -Fd(1,:))
grid on

% figure(5)
% title("trajectory")
%     plot3(t, p(1,:), -p(3,:))
%     xlabel("time [s]")
%     zlabel("\Delta h [m]")
%     axis equal
%     grid on

%% dynamics

function [a_p, alpha_p, F] = dynamics(AS, mars, v_air, alpha, dt)

    % kinematics 
    r_b = [sin(AS.state.theta); 0; cos(AS.state.theta)] * (AS.CoM - AS.balloon.radius - AS.gondola.height/2) ;
    r_n = [sin(AS.state.theta); 0; cos(AS.state.theta)] * (AS.CoM);
    v_n = AS.state.v + cross([0;AS.state.omega;0], r_n);

    % forces
    Fa  = liftForce(AS, mars);              % [N] lift in the ground frame
    Fg  = (AS.mass + AS.ballonnet.ballast) * [0;0;mars.g];
    Fd  = dragForce(AS, v_air);             % drag force in ground frame
    Fp  = RotMat(AS.state.theta, 2) * ...
          propulsionForce('get', v_air - v_n, AS.state.p); % propulsion force in ground frame

    F   = Fp + Fd + Fa + Fg;                % sum of forces

    % moments
    M_b = cross(r_b, (Fd + Fa + AS.balloon.mass * [0;0;mars.g])) ...
        + dragTorque(AS.state.omega, alpha, dt);
    M_n = cross(r_n, (Fp      + AS.gondola.mass * [0;0;mars.g]));
    M   = M_b + M_n;

    % dynamics 
    a_p     = F/(AS.mass + AS.ballonnet.ballast + addedMass(AS));
    alpha_p = M(2)/(AS.inertia);    % HACK: we only look at the in-plane rotations

    % ouputs
    F = {Fp, Fd, Fa, Fg};

end

