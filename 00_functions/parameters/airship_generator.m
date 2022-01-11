%% utilities 

S = @(r) (4   * pi * r^2);
V = @(r) (4/3 * pi * r^3);


%% balloon

balloon             = struct();
balloon.radius      = 23;                   % [m]

m_env               = 345;                  % [kg] envelope mass
m_s                 = 99.4;                 % [kg] solar panel mass
m_g                 = 31;                   % [kg] lifting gas mass


balloon.mass        = m_env + m_g + m_s;
balloon.inertia     = 2*((m_env+m_s)/3 + m_g/5)*balloon.radius^2;

balloon.superpressure = 1.2;


%% ballonnet 

ballonnet           = struct();
ballonnet.radius    = 10;                   % [m]
ballonnet.mass      = 50;                   % [kg]
ballonnet.ballast   = 0;                    % [kg]
ballonnet.inertia   = 0;
% ballonnet.inertia   = 2*(ballonnet.mass/3 + ballonnet.ballast/5)*ballonnet.radius^2;


%% propulsion

propeller           = struct();
propeller.diameter  = 1.5;                  % [m]
propeller.mass      = 4;                    % [kg]
propeller.rpm       = 2000;                 % [rpm]

plant               = struct();
plant.nb_prop       = 2;
plant.propeller     = propeller;
plant.mass          = plant.nb_prop * plant.propeller.mass + 0.65 + 0.078 + 0.4;
plant.power_in      = 0.50 * 4000;          % [W] (mechanical power -> after gearbox)

propulsion          = struct();
propulsion.nb_plant = 4;
propulsion.plant    = plant;
propulsion.mass     = propulsion.nb_plant * propulsion.plant.mass + 1.5 + 20;


%% gondola 

batteries           = struct();
batteries.capacity  = 17000; % [Wh]
batteries.mass      = 133.8; % [kg]

gondola             = struct();
gondola.height      = 1;                    % [m]
gondola.diameter    = 1;                    % [m]
gondola.mass        = 300;                  % [kg]
gondola.inertia     = gondola.mass/12 * (3/4*gondola.diameter^2 + gondola.height^2);
gondola.batteries   = batteries;


%% airship

state               = struct();
state.p             = zeros(3,1);
state.v             = zeros(3,1);
state.a             = zeros(3,1);
state.theta         = 0;
state.omega         = 0;
state.alpha         = 0;


airship             = struct();
airship.balloon     = balloon;
airship.ballonnet   = ballonnet;
airship.propulsion  = propulsion;
airship.gondola     = gondola;
airship.state       = state;

airship.mass        = airship.balloon.mass + airship.ballonnet.mass + airship.gondola.mass; 
% airship.CoM         = ((airship.balloon.radius + airship.gondola.height/2) * airship.balloon.mass + ...
%                        (airship.gondola.height/2) * airship.ballonnet.mass) / airship.mass;
% airship.mass        = airship.balloon.mass + airship.gondola.mass; 
airship.CoM         = ((airship.balloon.radius + airship.gondola.height/2) * airship.balloon.mass) / airship.mass;

I_b_CoM             = airship.balloon.inertia + ...         % [kg m^2] I of the balloon
                      airship.balloon.mass * (airship.balloon.radius + airship.gondola.height/2 - airship.CoM)^2;        
I_bb_CoM            = airship.ballonnet.inertia + ...
                      airship.ballonnet.mass * (airship.gondola.height/2 - airship.CoM )^2;
I_n_CoM             = airship.gondola.inertia + ...         % [kg m^2] I of the gondola
                      airship.gondola.mass * airship.CoM^2 ; 

% airship.inertia     = I_b_CoM + I_bb_CoM + I_n_CoM;          % [kg m^2] total inertia
airship.inertia     = I_b_CoM + I_n_CoM;          % [kg m^2] total inertia



%% save airship for later retrieval

if exist("data_path", "var")
    save([data_path, 'airship.mat'], "airship")
    fprintf("airship saved to : '%airship.mat'\n", data_path)
end