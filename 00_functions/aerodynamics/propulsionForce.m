function [varargout] = propulsionForce(step, varargin)
%PROPULSIONFORCE calculate the propulsion force for simulation
%   [P] = propulsionForce('init', P0, D, nb_prop)
%       param P0      : nominal propulsion power
%       param D       : diameter of propellers
%       param nb_prop : number of propellers
%   [P] = propulsionForce('init', T0, v0, D, nb_prop, p0)
%       param T0      : nominal total thrust
%       param v0      : nominal air velocity away from propeller
%       param D       : diameter of propellers
%       param nb_prop : number of propellers
%   [Fp] = propulsionForce('get', v, p, u)
%       param  v      : air velocity
%       param  p      : position in NED
%       param  u      : control signal (% of nominal power)
persistent P D nb_prop T0

    switch step
        case 'init'
            
            if nargin == 4
                D       = varargin{2};
                nb_prop = varargin{3};
                P       = varargin{1} / nb_prop;    % power per propeller

                T0      = Thrust(P, 10, D, 0);      % thrust per propeller

            else 
                v0      = varargin{2};
                D       = varargin{3};
                nb_prop = varargin{4};
                T0      = varargin{1} / nb_prop;    % thrust per propeller
                if nargin > 5
                    p0      = varargin{5};
                else
                    p0      = [0, 0, 3000];
                end
        
                % set the nominal power per propeller
                P  = T0*v0/2 * (1 + sqrt( 1 + 8*T0/(pi*rho_atm(-p0(3))*(D*v0)^2)));
            end

            varargout = {nb_prop*P};
    
        case 'get'
            if nargin < 3
                Fp = nb_prop*Thrust(P, vecnorm(varargin{1}), D, T0);
            else
                if nargin < 4
                    Fp = nb_prop*Thrust(P, vecnorm(varargin{1}), D, T0, -varargin{2}(3));
                else
                    Fp = nb_prop*Thrust(varargin{3}*P, vecnorm(varargin{1}), D, T0, -varargin{2}(3));
                end
            end
            varargout = {[Fp; 0; 0]};

        otherwise
            error("no such step")
    
    end


end