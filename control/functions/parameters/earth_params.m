

% call constants to make sure we have a definition of AU 
constants

% create planet struct
earth = struct();
earth.name = 'Earth';
earth.cmap =  .9*ones(40,3) - ([.9;.5;.2] * linspace(0,1,40))';

% mars orbtial parameters
earth.A       = 1.00000261 * AU;      % [m] orbit around the sun
earth.Adot    = 0.00000562 * AU;      % [m / century]
earth.E       = 0.01671123;           % [-] eccentricity
earth.Edot    = -0.00004392;
earth.I       = deg2rad(-0.00001531); % [rad] orbital inclination
earth.Idot    = deg2rad(-0.01294668);
earth.RAAN    = deg2rad(0);           % [rad] Longitude of ascending node J2000 
earth.RAANdot = deg2rad(0);
earth.LP      = deg2rad(102.93768193);% [rad] Longitude of perihelion J2000 
earth.LPdot   = deg2rad(0.32327364);
earth.L0      = deg2rad(100.46457166);% [rad] Mean Longitude J2000 
earth.L0dot   = deg2rad(35999.37244981);


%  planetary parameters
earth.M       = 5.9724e24;            % [kg] mass of the planet
earth.r       = 6378.137e3;           % [m] equatorial radius
earth.e       = 0.003353;             % [-] ellipsiscity of earth 
earth.i       = deg2rad(23.44);       % [rad] inclination of the equator
earth.g       = 9.798;                % [m s^-2] surface gravity
earth.sol     = 24*60*60; % [s] length of a martian solar day
earth.omega   = 2*pi/earth.sol;        % [rad s^-1] rotation rate of mars
      
S_earth = 1361;                 % [W m^-2] solar irradiance

% earth surface parameters 


sol_earth = 24*60*60;           % [s] length of a earth solar day
yr_earth  = 365.256*sol_earth;  % [s] earth "solar" year
h_earth = 60*60;                % [s]
min_earth = 60;                 % [s]
s_earth = 1;                    % [s]