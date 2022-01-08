
% definition of AU 
AU = 1.495978707e11;                 % [m]

% create planet struct
mars = struct();
mars.name =  'Mars';
mars.cmap =  .9*ones(40,3) - ([.2;.5;.9] * linspace(0,1,40))';

% mars orbtial parameters
mars.A       = 1.52366231 * AU;      % [m] orbit around the sun
mars.Adot    = 0.00000097 * AU;      % [m / century]
mars.E       = 0.09341233;           % [-] eccentricity
mars.Edot    = 0.00009149;
mars.I       = deg2rad(1.85061);     % [rad] orbital inclination
mars.Idot    = deg2rad(-0.00724757);
mars.RAAN    = deg2rad(49.57854);    % [rad] Longitude of ascending node J2000 
mars.RAANdot = deg2rad(-0.26852431);
mars.LP      = deg2rad(336.04084);   % [rad] Longitude of perihelion J2000 
mars.LPdot   = deg2rad(0.45223625);
mars.L0      = deg2rad(355.45332);   % [rad] Mean Longitude J2000 
mars.L0dot   = deg2rad(19140.29934243);


% mars planetary parameters
mars.M       = 6.393e23;             % [kg] mass of the planet
mars.r       = 3396.2e3;             % [m] equatorial radius
mars.e       = 0.00589;              % [-] ellipsiscity of mars 
mars.i       = deg2rad(25.19);       % [rad] inclination of the equator
mars.g       = 3.721;                % [m s^-2] surface gravity
mars.sol     = (24*60 + 39)*60 + 35.24; % [s] length of a martian solar day
mars.omega   = -2*pi/mars.sol;       % [rad s^-1] rotation rate of mars (mars turns backwards!)

S_mars      = 586.2;                 % [W m^-2] solar irradiance

yr_mars     = 668.5921 * mars.sol;   % [s] martian "solar" year
h_mars      = mars.sol/24;           % [s]
min_mars    = mars.sol/24/60;        % [s]
s_mars      = mars.sol/24/60^2;      % [s]


