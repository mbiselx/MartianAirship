if length(dbstack) <= 1
    % the script is being run in stand-alone: clear the workspace 
    close all
    clc
    clear
    
    addpath("functions\utilities\")
    addpath("functions\parameters")
    addpath("functions\aerodynamics")
    addpath("functions\plotting")

%% set parameters

airship_params

v_air   = [-10; 0; 0];               % [m/s]

p0      = [0;0;3000];               % [m] initial position
v0      = [0; 0; 0];
T0      = 200;                        % [N] % nominal total propulsion 
D       = 4;                        % [m] % propeller diameter
nb_prop = 4;        
P0      = 3.5e3;                      % [W] % nominal total power
% P0      = 0;                        % [W] % nominal total power

theta0 = 0;

end

% propulsionForce('init', T0, 10, D, nb_prop, p0);
propulsionForce('init', P0, D, nb_prop);
        
Fa      = -Fg(m);                   % [N] lift in the ground frame
        
dt = .005;                          % [s] simulation timestep
t = 0:dt:400;                       % [s] simulation duration


% center of mass
z_b = -(r_b + l_t + h_n/2) * (1-m_b/m); % [m] CoM of the balloon
z_n =  (r_b + l_t + h_n/2) * (1-m_n/m); % [m] CoM of the gondola

% intertias around CoM
I_b_CoM = I_b + m_b * z_b^2;        % [kg m^2] I of the balloon
I_n_CoM = I_n + m_n * z_n^2;        % [kg m^2] I of the gondola
I       = I_b_CoM + I_n_CoM;        % [kg m^2] total inertia

% allocate memory 
theta       = zeros(1, length(t));
omega       = zeros(1, length(t));
alpha       = zeros(1, length(t));
a           = zeros(3, length(t));
v           = zeros(3, length(t));
p           = zeros(3, length(t));
Fd          = zeros(3, length(t));
Fp          = zeros(3, length(t));

theta(:,1)  = theta0;

% useful function
integrate   = @(x, i) (.5*(x(:,i) + x(:,i-1))*dt);  % trapezoidal integration

%% simulation loop


p(:,1) = p0;
v(:,1) = v0;
F      = dragForce(v_air-zeros(3,1), p(:,1)) ...
         + RotMat(theta(1), 2) * propulsionForce('get', v_air - v(:,1));
a(:,1) = F/(m+addedMass(p(:,1)));
wb = waitbar(0);
ii = 0;
for i = 2:length(t)

    % kinematics
    r_CoM_b = (z_b * [sin(theta(i-1)); 0; cos(theta(i-1))]);
    r_CoM_n = (z_n * [sin(theta(i-1)); 0; cos(theta(i-1))]);

    v_b = v(:,i-1) + cross([0; omega(i-1); 0], r_CoM_b);  
    v_n = v(:,i-1) + cross([0; omega(i-1); 0], r_CoM_n);  

    % forces
    Fd(:,i)  = dragForce(v_air - v_b, p(:,i-1));         % drag force in ground frame
    Fp(:,i)  = RotMat(theta(i-1), 2) * propulsionForce('get', v_air - v_n, p(:,i-1)); % propulsion force in ground frame

    % moments
    M_b = cross(r_CoM_b, (Fd(:,i) + Fa + Fg(m_b))) ...
          + dragTorque(omega(i-1), alpha(1:i-1), dt);
    M_n = cross(r_CoM_n, (Fp(:,i) + Fg(m_n)));

    % CoM dynamics
    a(:,i)      = (Fp(:,i) + Fd(:,i) + Fa + Fg(m))/(m+addedMass(p(:,i-1)));
    v(:,i)      = v(:,i-1) + integrate(a, i);
    p(:,i)      = p(:,i-1) + integrate(v, i);

    % angular dynamics
    alpha(i)    = (M_b(2) + M_n(2))/I;              % HACK: we only look at the in-plane rotations
    omega(i)    = omega(i-1) + integrate(alpha, i);
    theta(i)    = theta(i-1) + integrate(omega, i);

    ii = ii + 1;
    if ii > 50
        waitbar(i/length(t), wb)
        ii = 0;
    end
end
disp("simulation done")
close(wb)

%% plots 
figure(1)
sgtitle("horizontal dynamics (old)")
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
sgtitle("vertical dynamics (old)")
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

% figure(3)
%     sgtitle("angular dynamics (old)")
% subplot(3,1,1)
%     plot(t, alpha)
%     xlabel("time [s]"), ylabel('\alpha [rad / s^2]')
%     grid on
%     axis tight
% subplot(3,1,2)
%     plot(t, rad2deg(omega))
%     xlabel("time [s]"), ylabel('\omega [deg / s]')
%     grid on
%     axis tight
% subplot(3,1,3)
%     plot(t, rad2deg(theta))
%     hold on
%     N = ceil(14.5/dt);
%     plot(t, rad2deg(filter(ones(1,N)/N, 1, theta)), 'k', 'LineWidth', 1)
%     legend("inst.", "mean")
%     xlabel("time [s]"), ylabel('\theta [deg]')
%     grid on
%     axis tight


figure(4) 
title("Forces (old)")
plot(t(2:end),  Fp(1,2:end)); hold on
plot(t(2:end), -Fd(1,2:end))
grid on
