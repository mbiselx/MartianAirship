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

v_air   = [10; 0; 0];               % [m/s]

p0      = [0;0;3000];               % [m] initial position
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

theta(:,1)  = theta0;

% useful functions 
r_CoM_b = @(theta) (z_b * [sin(theta); 0; cos(theta)]);
r_CoM_n = @(theta) (z_n * [sin(theta); 0; cos(theta)]);

integrate   = @(x, i) (.5*(x(:,i) + x(:,i-1))*dt);  % trapezoidal integration

%% simulation loop


p(:,1) = p0;
F      = dragForce(v_air-zeros(3,1), p(:,1)) ...
         - RotMat(theta(1), 2) * propulsionForce('get', v_air - v(:,1));
a(:,1) = F/(m+addedMass(p(:,1)));
wb = waitbar(0);
ii = 0;
for i = 2:length(t)

    % forces
    v_b = v(:,i-1) + [z_b*omega(i-1);0;0];          % balloon veloctiy in ground frame
    Fd  = dragForce(v_air - v_b, p(:,i-1));         % drag force in ground frame
    Fp = -RotMat(theta(i-1), 2) * propulsionForce('get', v_air - v(:,i-1), p(:,i-1)); % propulsion force in ground frame

    % moments
    M_b = cross(r_CoM_b(theta(i-1)), (Fd + Fa + Fg(m_b))) ...
          + dragTorque(omega(i-1), alpha(1:i-1), dt);
    M_n = cross(r_CoM_n(theta(i-1)), (Fp + Fg(m_n)));

    % CoM dynamics
    a(:,i)      = (Fp + Fd + Fa + Fg(m))/(m+addedMass(p(:,i-1)));
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
% figure(), plot(tmp.')
% t = t(1:i);
% alpha = alpha(1:i);
% a = a(:,1:i);
% v = v(:,1:i);

figure()
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


figure()
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
    % plot([t(1), t(end)], rad2deg(mean(theta))*[1,1])
    N = ceil(14.5/dt);
    plot(t, rad2deg(filter(ones(1,N)/N, 1, theta)), 'k', 'LineWidth', 1)
    legend("inst.", "mean")
    xlabel("time [s]"), ylabel('\theta [deg]')
    grid on
    axis tight
