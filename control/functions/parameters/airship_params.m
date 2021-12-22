%% planet

g       = [0; 0; 3.71];     % [m/s^2]
Fg      = @(m) (m*g);       % [N] gravity in the ground frame


%% position

lat     = -10;              % [°]
lon     = -70;              % [°]
z0      = -3000;            % [m]


%% balloon
SPF     = 1.5;              % super-pressure factor

r_b     = 23;               % [m]
m_env   = 300 + 13;         % [kg]
m_g     = 39;               % [kg]
m_b     = m_env + m_g;      % [kg]  % balloon mass
I_b     = 2*(m_env/3 + m_g/5)*r_b^2;% [kg m^2]

% m_a     = 2/3*pi*r_b^3 * rho_atm(); % [kg]  % nominal added mass
% I_a     = 0;                % [kg m^2] added inertia (is 0 for a sphere ?)


%% ballonnet 

r_bb    = 23/2;             % [m] radius of the ballonnet
m_env_bb = 45;              % [kg] mass of the ballonnet envelope
m_bb    = @(p) (4/3*pi*r_bb^3*rho_atm(-p(3)));


%% gondola

h_n     = 1;                % [m]
d_n     = 2;                % [m]
l_t     = 0;                % [m]
m_n     = 500;              % [kg]
I_n     = m_n/12 * (3/4*d_n^2 + h_n^2);% [kg m^2]


%% airship

m       = m_b + m_n;        % [kg]
