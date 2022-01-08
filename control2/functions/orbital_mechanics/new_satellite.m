function sat = new_satellite(varargin)
% function sat = new_satellite(planet, height, e, i, RAAN, LP, L0)
    
    % set physical constants
    constants

    % create planet struct
    sat = struct();
    sat.name =  'Satellite';
    sat.cmap =  [1,0,0];
    
    % mars orbtial parameters
    sat.A       = varargin{1}.r + varargin{2}; % [m] orbit around the planet
    sat.Adot    = 0;                      % [m / century]
    
    if nargin > 2                         % [-] eccentricity
        sat.E = varargin{3};
    else
        sat.E   = 0;
    end
    sat.Edot    = 0;
    
    if nargin > 3                         % [rad] orbital inclination
        sat.I   = varargin{4};
    else
        sat.I   = 0;
    end
    sat.Idot    = deg2rad(0);
    
    if nargin > 4                         % [rad] Longitude of ascending node J2000
        sat.RAAN = varargin{5};
    else
        sat.RAAN = 0;
    end 
    
    f = (1 - sqrt(1-varargin{1}.e^2));                                   % [-] oblateness
    J2 = (2*f  - (varargin{1}.r*varargin{1}.omega)^3/G/varargin{1}.M)/3; % second dynamic form factor
    T = orbital_period(sat.A, varargin{1}.M)/(60*60*24*356.25*100);      % [cy] orbital period
    sat.RAANdot = - 3*pi/T * J2 * (varargin{1}.r/sat.A/(1-sat.E^2))^2 * cos(sat.I); % Nodal precession
    
    if nargin > 5                         % [rad] Longitude of perihelion J2000
        sat.LP  = varargin{6};
    else
        sat.LP  = 0;
    end
    sat.LPdot   = deg2rad(0);
    
    if nargin > 6                         % [rad] Mean Longitude J2000 
        sat.L0  = varargin{7};
    else
        sat.L0  = 0;
    end
    sat.L0dot   = 2*pi/T;


end

