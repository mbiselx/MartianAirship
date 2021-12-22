close all
clc
clear

addpath("functions\utilities\")
addpath("functions\parameters")
addpath("functions\aerodynamics")
addpath("functions\plotting")

%% set parameters

airship_params
dt = .01;

T0      = 0;                        % [N] % nominal total propulsion 
D       = 4;                        % [m] % propeller diameter
nb_prop = 4;        
P0      = 0;                        % [W] % nominal total power
propulsionForce('init', P0, D, nb_prop);


% center of mass
z_b = -(r_b + l_t + h_n/2) * (1-m_b/m); % [m] CoM of the balloon
z_n =  (r_b + l_t + h_n/2) * (1-m_n/m); % [m] CoM of the gondola

% intertias around CoM
I_b_CoM = I_b + m_b * z_b^2;            % [kg m^2] I of the balloon
I_n_CoM = I_n + m_n * z_n^2;            % [kg m^2] I of the gondola
I       = I_b_CoM + I_n_CoM;            % [kg m^2] total inertia

integrate   = @(x_in, x) (.5*(x_in + x)*dt);  % trapezoidal integration


%% set up the system
dt   = .001;
a_in = 0;
alpha_in = zeros(1,4);
p_in = [0; 0; 3000];
v_in = zeros(3,1);
m_a  = addedMass(p_in);

% propulsionForce('init', T0, 10, D, nb_prop, p_in);

N = 20;
theta_in = linspace(-deg2rad(10), deg2rad(10), N);
omega_in = linspace(-deg2rad(4),  deg2rad(4),  N);

irange = length(theta_in);
jrange = length(omega_in);

[theta_in, omega_in] = meshgrid(theta_in, omega_in);

theta_out = zeros(size(theta_in));
omega_out = zeros(size(omega_in));    
for i = 1:irange
    for j = 1:jrange

    [F, M] = forces(p_in, v_in, a_in, theta_in(i,j), omega_in(i,j), alpha_in, dt);

    %dynamics 
    % CoM dynamics
    a      = F(1)/(m + m_a);
    v      = v_in + integrate(a_in, a);
    p      = p_in + integrate(v_in, v);
    
    % angular dynamics
    alpha  = M(2)/I;              
    omega  = omega_in(i,j) + integrate(alpha_in(end), alpha);
    theta  = theta_in(i,j) + integrate(omega_in(i,j), omega);

    theta_out(i,j) = omega;
    omega_out(i,j) = alpha;
    end
end

figure()

quiver(theta_in, omega_in, theta_out, omega_out, 'k')
% xlabel('\theta [rad]'), 
% xticks([-2*pi, -pi*3/2, -pi, -pi/2, 0, pi/2, pi, pi*3/2, 2*pi])
% xticklabels(["-2\pi", "-1.5\pi", "-\pi", "-.5\pi", "0", ".5\pi", "\pi", "1.5\pi", "2\pi"])
xlabel('\theta [deg]'), 
xticks(deg2rad([-10, -5, 0, 5, 10]))
xticklabels(["-10°", "-5°", "0°", "5°", "10°"])


ylabel('\omega [rad / s]')
axis tight
xlim([min(theta_in, [], 'all'), max(theta_in, [], 'all')])
ylim([min(omega_in, [], 'all'), max(omega_in, [], 'all')])
grid on

theta0 = deg2rad(-10);
v_air  = [0; 0; 0];
stability

figure(1)
hold on
plot(theta, omega)







function [F, M] = forces(p, v, a, theta, omega, alpha, dt)
    airship_params
    v_air = [0; 0; 0];

    % center of mass
    z_b = -(r_b + l_t + h_n/2) * (1-m_b/m); % [m] CoM of the balloon
    z_n =  (r_b + l_t + h_n/2) * (1-m_n/m); % [m] CoM of the gondola

    r_CoM_b = @(theta) (z_b * [sin(theta); 0; cos(theta)]);
    r_CoM_n = @(theta) (z_n * [sin(theta); 0; cos(theta)]);
   
    Fg      = @(m) (m*g);                   % [N] gravity in the ground frame
    v_b = v + [z_b*omega;0;0];              % balloon veloctiy in ground frame
    
    % forces
    Fa  = -Fg(m);                           % [N] lift in the ground frame
    Fd  = dragForce(v_air - v_b, p);        % drag force in ground frame
    Fpf = -RotMat(theta, 2) * propulsionForce('get', v_air - v, p); % propulsion force in ground frame
    F   = Fpf + Fd + Fa + Fg(m);            % sum of forces

    % moments
    M_b = cross(r_CoM_b(theta), (Fd + Fa + Fg(m_b))) ...
        + dragTorque(omega, alpha(1:end), dt);
    M_n = cross(r_CoM_n(theta), (Fpf + Fg(m_n)));
    M = M_b + M_n;
end